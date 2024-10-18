//
//  HomeScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import FirebaseAuth

struct HomeScreen: View, Navigable {

    var navigate: (Screen) -> Void
    @EnvironmentObject var firebase: FirebaseRepository
    
    var body: some View {
        VStack {
            Button("Logout") {
                Task {
                    try await firebase.logout()
                }
            }
        }
    }
}
