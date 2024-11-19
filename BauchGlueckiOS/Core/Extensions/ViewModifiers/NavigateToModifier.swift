//
//  NavigateToModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//

import SwiftUI

struct NavigateTo<Target: View, Toolbar: View>: ViewModifier {
    
    var destination: Destination
    var firebase: FirebaseService
    var showSettingButton: Bool
    
    @Environment(\.theme) private var theme
    
    @ViewBuilder var target: () -> Target
    @ViewBuilder var toolbarItems: () -> Toolbar
    
    func body(content: Content) -> some View {
        NavigationLink {
            target()
                .navigationBackButton(
                    color: theme.color.onBackground,
                    destination: destination,
                    firebase: firebase,
                    showSettingButton: showSettingButton,
                    toolbarItems: toolbarItems
                )
        } label: {
            content
        }
    }
}
