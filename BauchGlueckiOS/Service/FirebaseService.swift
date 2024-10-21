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

class FirebaseService: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var user: User? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var error: Error? = nil
    
    let firebaseAuth = Auth.self.auth()
    let firebaseDatabase = Firestore.firestore()
    
    var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private var currentNonce: String?
    
    func login(
        email: String,
        password: String
    ) {
        firebaseAuth.signIn(withEmail: email.lowercased(), password: password) { result ,error in
            self.user = result?.user
            self.error = error
            print("LOGIN USER: \(String(describing: result?.user))")
            print("LOGIN ERROR: \(String(describing: error))")
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
            
            self.saveUserProfile(userProfile: newUser) { error in
                if (error == nil) {
                    self.userProfile = newUser
                }
            }
        }
    }
    
    func logout() async throws {
        do {
            try firebaseAuth.signOut()
            try await Authentication().logout()
        } catch {
            throw error
        }
    }
    
    func forgotPassword(email: String) {
        firebaseAuth.sendPasswordReset(withEmail: email)
    }
    
    func signInWithGoogle() {
        Task {
            do {
                try await Authentication().googleOauth()
                
                authListener { auth , error in
                    self.user = auth?.currentUser
                }
            } catch {
                throw error
            }
        }
    }

    func signInWithApple() {
        let request = createAppleIDRequest()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
            let userNotifierToken = getSavedDeviceToken()
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
                completion(error)
            }
        } catch let error {
            print("Error saving user profile: \(error)")
            completion(error)
        }
    }
    
    func readUserProfileById(userId: String, completion: @escaping (UserProfile?) -> Void) {
        let documentRef = firebaseDatabase.collection(Collection.UserProfile.rawValue).document(userId)
        documentRef.getDocument { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    completion(userProfile)
                } catch {
                    print("Error decoding \(Collection.UserProfile.rawValue): \(error)")
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
        let onlineUsersReference = Database.database().reference(withPath: Collection.OnlineUsers.rawValue)
        onlineUsersReference.removeObserver(withHandle: handle)
    }
    
    func getOnlineUserCount(onUserCount: @escaping (Int) -> Void) async throws {
        let onlineUsersReference = Database.database().reference(withPath: Collection.OnlineUsers.rawValue)
        
        let snapshot = try await onlineUsersReference.getData()
        let count = snapshot.childrenCount
        onUserCount(Int(count))
    }
    
    func markUserOnline() async throws {
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard
            let userId = Auth.auth().currentUser?.uid,
            let token = getSavedDeviceToken(),
            let user = userProfile
        else { return
            print("Token: \(getSavedDeviceToken() ?? "No TOKEN") User: \(userProfile?.uid ?? "")")
        }
        
        let userReference = Database.database().reference(withPath: "\(Collection.OnlineUsers.rawValue)/\(userId)")

        
        
        let appUser = AppUser(name: user.firstName, email: user.email, appToken: token)
        print("Set Online: \(appUser)")
        // Setze den Benutzer online
        do {
            try await userReference.setValue(appUser.toDictionary())
            
            try await userReference.onDisconnectRemoveValue()
        } catch {
            print(error)
        }
       
    }
    
    func markUserOffline() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userReference = Database.database().reference(withPath: "\(Collection.OnlineUsers.rawValue)/\(userId)")
        
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
            throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
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

enum AuthenticationError: Error {
    case runtimeError(String)
}


enum Collection: String{
    case UserProfile = "UserProfile"
    case UserNode = "UserNode"
    case OnlineUsers = "bauchglueck-6c1cf/onlineUsers"
}

struct AppUser {
    var name: String = ""
    var email: String = ""
    var appToken: String = ""
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "appToken": appToken
        ]
    }
}
