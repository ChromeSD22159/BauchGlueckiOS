//
//  ViewExtensions.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//

import SwiftUI

extension View {
    func navigateTo<Target: View, Toolbar: View>(
        firebase: FirebaseService,
        destination: Destination,
        showSettingButton: Bool = true,
        @ViewBuilder target: @escaping () -> Target = { EmptyView() },
        @ViewBuilder toolbarItems: @escaping () -> Toolbar = { EmptyView() }
    ) -> some View {
        modifier(
            NavigateTo<Target, Toolbar>(
                destination: destination,
                firebase: firebase,
                showSettingButton: showSettingButton,
                target: target,
                toolbarItems: toolbarItems
            )
        )
    }
    
    func settingSheet(isSettingSheet: Binding<Bool>, authManager: FirebaseService, onDismiss: @escaping () -> Void) -> some View {
        modifier(SettingSheet(isSettingSheet: isSettingSheet, authManager: authManager, onDismiss: onDismiss))
    }
    
    func textFieldClearButton(text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(text: text))
    }
    
    func navigationBackButton<T: View>(
        color: Color,
        icon: String = "arrow.backward",
        destination: Destination,
        firebase: FirebaseService,
        onDismissAction: @escaping () -> Void  = {},
        showSettingButton: Bool = true,
        @ViewBuilder toolbarItems: @escaping () -> T = { EmptyView() }
    ) -> some View {
        self.modifier(
            NavigationBackButton<T>(
                color: color,
                icon: icon,
                destination: destination,
                firebase: firebase,
                onDismissAction: onDismissAction,
                showSettingButton: showSettingButton,
                toolbarItems: toolbarItems
            )
        )
    }
    
    func fontSytle(fontSize: Font = Font.body, color: Color = Color.black) -> some View {
        modifier(TextStyle(fontSize: fontSize, color: color))
    }
    
    func onAppEnterForeground(perform action: @escaping () async throws -> Void) -> some View {
        self.modifier(OnAppEnterForeground(action: action))
    }
    
    func onAppEnterBackground(perform action: @escaping () async -> Void) -> some View {
        self.modifier(OnAppEnterBackground(action: action))
    }
    
    func sectionShadow(margin: CGFloat = 0) -> some View {
        self.modifier(SectionShadow(margin: margin))
    }
}
