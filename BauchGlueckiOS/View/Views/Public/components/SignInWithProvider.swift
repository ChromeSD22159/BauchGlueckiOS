//
//  SignInWithProvider.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 14.11.24.
//
import SwiftUI
import FirebaseAuth

struct SignInWithProvider: View {
    @Environment(\.theme) private var theme
    
    @EnvironmentObject var errorHandling: ErrorHandling
    @EnvironmentObject var userViewModel: UserViewModel
    
    var result: (Result<User, any Error>) -> Void
    
    var body: some View {
        HStack(spacing: theme.layout.padding) {
            Button(action: { 
                Task {
                    FirebaseService.signInWithGoogle() { result in
                       switch result {
                           case .success(let user):
                               Task {
                                   userViewModel.user = user
                                   userViewModel.userProfile = try await FirebaseService.readUserProfileById(userId: user.uid)
                                   self.result(.success(user))
                               }
                           
                          
                           case .failure(let error): errorHandling.handle(error: error)
                       }
                    }
                }
            }) {
                Image(.google)
            }
            
            Button(action: {
                Task {
                    FirebaseService.signInWithApple() { result in
                       switch result {
                           case .success(let user):
                               Task {
                                   userViewModel.user = user
                                   userViewModel.userProfile = try await FirebaseService.readUserProfileById(userId: user.uid)
                                   self.result(.success(user))
                               }
                           
                           case .failure(let error): errorHandling.handle(error: error)
                       }
                    } 
                }
            }) {
                Image(.apple)
            }
        }.padding(.top, theme.layout.padding)
    }
}
