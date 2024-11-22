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
    @EnvironmentObject var firebase: FirebaseService
    @EnvironmentObject var services: Services
    
    var result: (Result<User, any Error>) -> Void
    
    var body: some View {
        HStack(spacing: theme.layout.padding) {
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
        }.padding(.top, theme.layout.padding)
    }
}
