//
//  FirebaseService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 25.11.24.
//

import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import FirebaseCore
import GoogleSignIn
import FirebaseStorage
import FirebaseDatabaseInternal

class FirebaseService: ObservableObject {
    private var user: User?
    
    static func getUser() async throws -> User {
        guard let user = Auth.auth().currentUser else { throw FirebaseError.userNotFound }
        return user
    }
    
    static func readCurrentUserProfile() async throws -> UserProfile {
        let user = try await FirebaseService.getUser()
        
        let documentRef = Firestore.firestore().collection(FirebaseCollection.UserProfile.rawValue).document(user.uid)
        
        do {
            let documentSnapshot = try await documentRef.getDocument()
             
            guard let data = documentSnapshot.data() else {
                throw NSError(domain: "UserProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
            }
            
            let userProfile = try Firestore.Decoder().decode(UserProfile.self, from: data)
            return userProfile
        } catch {
            throw error
        }
    }
    
    static func readUserProfileById(userId: String) async throws -> UserProfile {
        let documentRef = Firestore.firestore().collection(FirebaseCollection.UserProfile.rawValue).document(userId)
        
        do {
            let documentSnapshot = try await documentRef.getDocument()
             
            guard let data = documentSnapshot.data() else {
                throw NSError(domain: "UserProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
            }
            
            let userProfile = try Firestore.Decoder().decode(UserProfile.self, from: data)
            return userProfile
        } catch {
            throw error
        }
    }
    
    static func signInWithGoogle(onComplete: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                try await GoogleAuthentication().googleOauth()
                
                FirebaseService.authListener { auth , error in
                    if let user = auth?.currentUser {
                        onComplete(.success(user))
                    }
                }
            } catch {
                onComplete(.failure(error))
                throw error
            }
        }
    }

    static func signInWithApple(onComplete: @escaping (Result<User, Error>) -> Void) {
        let appleApplication = AppleAuthentication()
        appleApplication.signInWithApple { result in
            if case .success(let user) = result {
                onComplete(.success(user))
            } else {
                onComplete(.failure(FirebaseAuthenticationError.runtimeError("User not Found")))
            }
        }
    }
    
    static func uploadAndSaveProfileImage(userProfileImage: UIImage) async throws -> UserProfile {
        let user = try await getUser()
        
        // Bereite den Speicherort und die Metadaten vor
        let imageName = "\(user.uid)_profile_image.jpg"
        let storageRef = Storage.storage().reference(withPath: "profile_images/\(imageName)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Skaliere das Bild
        guard let scaledImage = userProfileImage.resizedAndCropped(to: CGSize(width: 512, height: 512)),
              let imageData = scaledImage.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Image compression or resizing failed"])
        }

        // Lade das Bild in Firebase Storage hoch
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)

        // Hole die herunterladbare URL
        let downloadURL = try await storageRef.downloadURL()

        // Lese das Benutzerprofil
        var profile = try await FirebaseService.readUserProfileById(userId: user.uid)

        // Aktualisiere das Profil mit der neuen Bild-URL
        profile.profileImageURL = URLCacheManager.shared.generateUniqueUrl(for: downloadURL.absoluteString).absoluteString

        // Speichere das aktualisierte Benutzerprofil
        try await FirebaseService.saveUserProfile(userProfile: profile)

        return profile
    }
    
    static func saveUserProfile(userProfile: UserProfile) async throws  {
        let user = try await getUser()
        
        let updatedUserProfile = try await readUserProfileById(userId: user.uid)

        let db = Firestore.firestore()
        do {
            try db.collection("UserProfile").document(user.uid).setData(from: updatedUserProfile) { error in }
        } catch let error {
            print("Error saving user profile: \(error)")
            throw error
        }
    }
    
    static func downloadProfileImage(imageURL: String, onComplete: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageURL), url.scheme == "https" else {
            print("Invalid image URL")
            return
        }
           
        let storageRef = Storage.storage().reference(forURL: imageURL)
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in // 1 MB max size
            if let error = error {
                print(error)
            } else {
                if let imageData = data, let image = UIImage(data: imageData) {
                    onComplete(image)
                } else {
                    print(String(describing: error?.localizedDescription))
                }
            }
        }
    }
    
    static func readAppSettings(completion: @escaping (Result<FirebaseAppSettings, Error>) -> Void) {
        let documentRef = Firestore.firestore().collection(FirebaseCollection.AppSettings.rawValue).document("v1")
        
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
    
    static func checkUserProfilExist() async throws -> Bool { 
        do {
            guard let userId = Auth.auth().currentUser?.uid else { throw FirebaseError.userNotFound }
            let _ = try await FirebaseService.readUserProfileById(userId: userId)
            return true
        } catch {
            return false
        }
    }
    
    static func forgotPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw error
        }
    }
}

extension FirebaseService {
    static func authListener(completion: @escaping (Auth?, User?) -> Void) {
        let _ = Auth.auth().addStateDidChangeListener { auth, user in
            
            if (user != nil) {
                completion(auth, user)
            }
            
            completion(auth, user)
        }
    }
    
    static func markUserOnline(user: User) async throws {
        guard let token = DeviceTokenService().getSavedDeviceToken() else { throw FirebaseError.noAPNSToken }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let userProfile = try await FirebaseService.readUserProfileById(userId: user.uid)
         
        let userReference = Database.database().reference(withPath: "\(FirebaseCollection.OnlineUsers.rawValue)/\(user.uid)")
        
        let appUser = AppUser(name: userProfile.firstName, email: userProfile.email, appToken: token)
        
        try await userReference.setValue(appUser.toDictionary())
        
        try await userReference.onDisconnectRemoveValue()
    }
}
