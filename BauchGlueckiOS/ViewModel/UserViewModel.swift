//
//  UserViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 25.11.24.
//
import SwiftUI
import FirebaseAuth
import GoogleSignIn
  
class UserViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var userImage: UIImage = UIImage()
    @Published var isUserProfileSheet: Bool = false
    
    init() {
        Task {
            do {
                try await checkIfUserIsLoggedIn()
            }
        }
    }
  
    func checkIfUserIsLoggedIn() async throws {
        if let user = Auth.auth().currentUser {
            let profile = try await FirebaseService.readUserProfileById(userId: user.uid)
            DispatchQueue.main.async {
                self.userProfile = profile
            }
        }
    }
    
    func login(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().signIn(withEmail: email.lowercased(), password: password)
        
        self.user = result.user
         
        let userProfile = try await FirebaseService.readUserProfileById(userId: result.user.uid)
        self.userProfile = userProfile
        
        return userProfile
    }
    
    func register(
        userProfile: UserProfile,
        password: String
    ) async throws {
        let result = try await Auth.auth().createUser(withEmail: userProfile.email, password: password)
        
        self.user = result.user
        
        var newUserProfile = userProfile
        newUserProfile.uid = result.user.uid
        
        self.userProfile = newUserProfile
        
        try await FirebaseService.saveUserProfile(userProfile: newUserProfile)
    }
    
    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
    
    func signOut() throws {
        try? Auth.auth().signOut()
        user = nil
        userImage = UIImage()
        GIDSignIn.sharedInstance.signOut() 
    } 
}
