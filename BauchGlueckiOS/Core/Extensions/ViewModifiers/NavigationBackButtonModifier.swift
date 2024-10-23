//
//  NavigationBackButtonModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//

import SwiftUI

struct NavigationBackButton<T: View>: ViewModifier {
    var color: Color
    var icon: String
    var destination: Destination
    var firebase: FirebaseService
    var onDismissAction: () -> Void
    var showSettingButton: Bool
    @ViewBuilder var toolbarItems: () -> T

    @Environment(\.dismiss) var dismiss
    @State var isSettingSheet: Bool = false
    
    let theme: Theme = Theme.shared
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Image(systemName: icon)
                            .font(.body)
                        Text(destination.screen.title)
                            .font(.callout)
                    }
                    .onTapGesture {
                        onDismissAction()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing, content: {
                    HStack(spacing: theme.padding) {
                        toolbarItems()
                        
                        if showSettingButton {
                            Image(systemName: "gear")
                                .onTapGesture {
                                    isSettingSheet = !isSettingSheet
                                }
                        }
                    }
                })
            }
            .settingSheet(isSettingSheet: $isSettingSheet, authManager: firebase, onDismiss: {})
    }
}
