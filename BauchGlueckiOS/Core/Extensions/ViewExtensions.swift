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
    
    func navigateTo<Target: View, Toolbar: View>(
        destination: Destination,
        isActive: Binding<Bool>,
        showSettingButton: Bool,
        firebase: FirebaseService,
        @ViewBuilder target: @escaping () -> Target,
        @ViewBuilder toolbarItems: @escaping () -> Toolbar = { EmptyView() }
    ) -> some View {
        modifier(NavigateToModifier(
            destination: destination,
            isActive: isActive,
            firebase: firebase,
            target: target,
            toolbarItems: toolbarItems
        ))
    }
    
    func settingSheet(isSettingSheet: Binding<Bool>, authManager: FirebaseService, services: Services, onDismiss: @escaping () -> Void) -> some View {
        modifier(SettingSheet(isSettingSheet: isSettingSheet, authManager: authManager, services: services, onDismiss: onDismiss))
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
                toolbarItems: toolbarItems, color: color,
                icon: icon,
                destination: destination,
                firebase: firebase,
                onDismissAction: onDismissAction,
                showSettingButton: showSettingButton
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
    
    func sectionShadow(innerPadding: CGFloat = 0, margin: CGFloat = 0) -> some View {
        self.modifier(SectionShadow(margin: margin, innerPadding: innerPadding))
    }
    
    func onAppLifeCycle(
        appear: @escaping () -> Void,
        active: @escaping () -> Void = {},
        inactive: @escaping () -> Void = {},
        background: @escaping () -> Void = {}
    ) -> some View {
        modifier(AppLifeCycle(appear: appear, active: active, inactive: inactive, background: background))
    }
    
    func onAppLifeCycle(
        appearAndActive: @escaping () -> Void
    ) -> some View {
        modifier(AppLifeCycle(appear: appearAndActive, active: appearAndActive, inactive: {}, background: {}))
    }
    
    func onAppLifeCycle(
        inactive: @escaping () -> Void
    ) -> some View {
        modifier(AppLifeCycle(appear: {}, active: {}, inactive: inactive, background: {}))
    }
    
    func onAppLifeCycle(
        background: @escaping () -> Void
    ) -> some View {
        modifier(AppLifeCycle(appear: {}, active: {}, inactive: {}, background: background))
    }
    
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
     
    func viewSize(name: String, debugColor: Color = Color.clear) -> some View {
        modifier(ViewSize(name: name, debugColor: debugColor))
    }
}

struct NavigateToModifier<Target: View, Toolbar: View>: ViewModifier {
    let destination: Destination
    let isActive: Binding<Bool>
    let showSettingButton: Bool = true
    let firebase: FirebaseService
    let target: () -> Target
    let toolbarItems: () -> Toolbar
    
    func body(content: Content) -> some View {
        ZStack {
            content  
            NavigationLink(
                destination: target().navigationBackButton(
                    color: Theme.color.onBackground,
                    destination: destination,
                    firebase: firebase,
                    showSettingButton: showSettingButton,
                    toolbarItems: toolbarItems
                ),
                isActive: isActive
            ) {
                EmptyView()
            }
        }
    }
}
