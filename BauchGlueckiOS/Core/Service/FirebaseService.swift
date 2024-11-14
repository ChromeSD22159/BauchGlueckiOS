//
//  FirebaseRepository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseDatabaseInternal
import FirebaseFirestore
import FirebaseStorage

class FirebaseService: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var user: User? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var error: Error? = nil
    @Published var userProfileImage = UIImage()
    
    let firebaseAuth = Auth.self.auth()
    let firebaseDatabase = Firestore.firestore()
    let storage = Storage.storage()
    
    var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private var currentNonce: String?
    private let deviceTokenService = DeviceTokenService.shared
    
    func login(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, (any Error)?) -> Void
    ) {
        firebaseAuth.signIn(withEmail: email.lowercased(), password: password) { result ,error in
            if let user = result?.user {
                self.user = user
                self.readUserProfileById(userId: user.uid, completion: { prof in
                    self.userProfile = prof
                })
            }
            self.error = error
            
            completion(result, error)
        }
    }
    
    func register(
        userProfile: UserProfile,
        password: String,
        completion: @escaping (AuthDataResult?, (any Error)?) -> Void
    ) {
        firebaseAuth.createUser(withEmail: userProfile.email, password: password) { authResult, error in
            guard let uid = authResult?.user.uid else { return }
            
            var newUser = userProfile
            newUser.uid = uid
            
            self.user = authResult?.user
            self.saveUserProfile(userProfile: newUser) { error in
                if (error == nil) {
                    self.userProfile = newUser
                }
            }
            
            completion(authResult, error)
        }
    }
    
    func signOut() {
        Task {
            do {
                try firebaseAuth.signOut()
                try await Authentication().logout()
            } catch {
                throw error
            }
        }
    }
    
    func forgotPassword(email: String) {
        firebaseAuth.sendPasswordReset(withEmail: email)
    }
    
    func signInWithGoogle(onComplete: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                try await Authentication().googleOauth()
                
                self.authListener { auth , error in
                    if let user = auth?.currentUser {
                        self.user = user
                        self.readUserProfileById(userId: user.uid) { userProfile in
                           
                            if let userProf =  userProfile {
                                self.userProfile = userProf
                            }
                        }
                        
                        onComplete(.success(user))
                    }
                }
            } catch {
                onComplete(.failure(error))
                throw error
            }
        }
    }

    func signInWithApple(onComplete: @escaping (Result<User, Error>) -> Void) {
        let request = createAppleIDRequest()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        self.authListener { (auth: Auth? , user: User?) in
            if let user = auth?.currentUser {
                self.user = user
                self.readUserProfileById(userId: user.uid) { userProfile in
                   
                    if let userProf =  userProfile {
                        self.userProfile = userProf
                    }
                }
                
                onComplete(.success(user))
            } else {
                onComplete(.failure(FirebaseAuthenticationError.runtimeError("User not Found")))
            }
        }
    }

    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        return request
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Firebase Auth mit Apple Credentials
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenString,
                rawNonce: nonce,
                accessToken: nil  // Hier kannst du optional auch den accessToken hinzufügen, falls vorhanden
            )
            
            firebaseAuth.signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.error = error
                    print("Error authenticating: \(error.localizedDescription)")
                    return
                }
                
                // Benutzer erfolgreich angemeldet
                self.user = authResult?.user
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.error = error
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    func authListener(completion: @escaping (Auth?, User?) -> Void) {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            
            if (user != nil) {
                self.readUserProfileById(userId: user!.uid) { userProfile in
                    self.userProfile = userProfile
                }
            }
            
            completion(auth, user)
        }
    }
    
    func saveUserProfile(userProfile: UserProfile, completion: @escaping (Error?) -> Void) {
        guard
            let currentUser = Auth.auth().currentUser,
            let userNotifierToken = deviceTokenService.getSavedDeviceToken()
        else {
            return
        }

        if let error = error {
            print("Error retrieving push token: \(error)")
            completion(error)
            return
        }
        
        var updatedUserProfile = userProfile
        updatedUserProfile.userNotifierToken = userNotifierToken

        let db = Firestore.firestore()
        do {
            try db.collection("UserProfile").document(currentUser.uid).setData(from: updatedUserProfile) { error in
                
                if error == nil {
                    self.userProfile = userProfile
                }
                
                completion(error)
            }
        } catch let error {
            print("Error saving user profile: \(error)")
            completion(error)
        }
    }
    
    func readUserProfileById(userId: String, completion: @escaping (UserProfile?) -> Void) {
        let documentRef = firebaseDatabase.collection(FirebaseCollection.UserProfile.rawValue).document(userId)
        documentRef.getDocument { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    completion(userProfile)
                } catch {
                    print("Error decoding \(FirebaseCollection.UserProfile.rawValue): \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func observeOnlineUserCount(onUserCountChange: @escaping (Int) -> Void) -> DatabaseHandle? {
        let onlineUsersReference = Database.database().reference(withPath: "OnlineUsers")

        let handle = onlineUsersReference.observe(.value) { snapshot in
            let count = snapshot.childrenCount
            onUserCountChange(Int(count))
        }
        
        return handle
    }
    
    func removeOnlineUserObserver(handle: DatabaseHandle?) {
        guard let handle = handle else { return }
        let onlineUsersReference = Database.database().reference(withPath: FirebaseCollection.OnlineUsers.rawValue)
        onlineUsersReference.removeObserver(withHandle: handle)
    }
    
    func getOnlineUserCount(onUserCount: @escaping (Int) -> Void) async throws {
        let onlineUsersReference = Database.database().reference(withPath: FirebaseCollection.OnlineUsers.rawValue)
        
        let snapshot = try await onlineUsersReference.getData()
        let count = snapshot.childrenCount
        onUserCount(Int(count))
    }
    
    func markUserOnline() async throws {
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard
            let userId = Auth.auth().currentUser?.uid,
            let token = deviceTokenService.getSavedDeviceToken(),
            let user = userProfile
        else { return
            print("Token: \(deviceTokenService.getSavedDeviceToken() ?? "No TOKEN") User: \(userProfile?.uid ?? "")")
        }
        
        let userReference = Database.database().reference(withPath: "\(FirebaseCollection.OnlineUsers.rawValue)/\(userId)")
        
        let appUser = AppUser(name: user.firstName, email: user.email, appToken: token)
        do {
            try await userReference.setValue(appUser.toDictionary())
            
            try await userReference.onDisconnectRemoveValue()
        } catch {
            print(error)
        }
       
    }
    
    func markUserOffline() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userReference = Database.database().reference(withPath: "\(FirebaseCollection.OnlineUsers.rawValue)/\(userId)")
        
        // Entferne den Benutzer
        do {
            try await userReference.removeValue()
        } catch {
            print(error)
        }
    }
    
    func isAuthenticated() -> Bool {
        return firebaseAuth.currentUser != nil ? true : false
    }
    
    // image
    func uploadAndSaveProfileImage(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: -2, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let imageName = "\(user.uid)_profile_image.jpg"
        let storageRef = storage.reference(withPath: "profile_images/\(imageName)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        guard let scaledImage = userProfileImage.resizedAndCropped(to: CGSize(width: 512, height: 512)), let imageData = scaledImage.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "ImageError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Image compression or resizing failed"])))
            return
        }
        
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                
                storageRef.downloadURL { result in
                    switch result {
                    case .success(let url):
                        self.userProfile?.profileImageURL = URLCacheManager.shared.generateUniqueUrl(for: url.absoluteString).absoluteString
                        self.userProfileImage = scaledImage
                        
                        if let profile = self.userProfile {
                            self.saveUserProfile(userProfile: profile) {_ in }
                            completion( .success(profile) )
                        }
                    case .failure(let error): completion(.failure(error)) }
                }
            }
        }
    }
        
    func downloadProfileImage(imageURL: String) {
        guard let url = URL(string: imageURL), url.scheme == "https" else {
            print("Invalid image URL")
            return
        }
           
        let storageRef = storage.reference(forURL: imageURL)
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in // 1 MB max size
            if let error = error {
                print(error)
            } else {
                if let imageData = data, let image = UIImage(data: imageData) {
                    self.userProfileImage = image
                } else {
                    print(String(describing: error?.localizedDescription))
                }
            }
        }
    }
    
    func readAppSettings(completion: @escaping (Result<FirebaseAppSettings, Error>) -> Void) {
        let documentRef = firebaseDatabase.collection(FirebaseCollection.AppSettings.rawValue).document("v1")
        
        documentRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("Document does not exist")
                return
            }
            
            do {
                // Decodiere das Dokument in das `FirebaseAppSettings`-Modell
                let appSettings = try document.data(as: FirebaseAppSettings.self) 

                completion(.success(appSettings))
            } catch {
                completion(.failure(AuthErrorCode.internalError))
                print("Error decoding \(FirebaseCollection.AppSettings.rawValue): \(error)")
            }
        }
    }
}
 
extension FirebaseService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("Unable to retrieve the window for presentation")
        }
        return window
    }
}

struct Authentication {
    @MainActor
    func googleOauth() async throws {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firbase clientID found")
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController
        else {
            fatalError("There is no root view controller!")
        }
        
        //google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw FirebaseAuthenticationError.runtimeError("Unexpected error occurred, please retry")
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }

    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}
  
extension UIImage {
    func resizedAndCropped(to size: CGSize) -> UIImage? {
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let width = self.size.width * scale
        let height = self.size.height * scale
        let x = (size.width - width) / 2.0
        let y = (size.height - height) / 2.0
        let cropRect = CGRect(x: x, y: y, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: cropRect)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
}
