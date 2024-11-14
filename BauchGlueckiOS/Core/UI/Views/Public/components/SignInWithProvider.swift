//
//  SignInWithProvider.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 14.11.24.
//
import SwiftUI
import FirebaseAuth

struct SignInWithProvider: View {
    @EnvironmentObject var firebase: FirebaseService
    @EnvironmentObject var services: Services
    var result: (Result<User, any Error>) -> Void
    
    var body: some View {
        HStack(spacing: Theme.shared.padding) {
            Button(action: {
                firebase.signInWithGoogle(onComplete: result)
            }) {
                Image(.google)
            }
            
            Button(action: {
                firebase.signInWithApple(onComplete: result)
            }) {
                Image(.apple)
            }
        }.padding(.top, Theme.shared.padding)
    }
}
