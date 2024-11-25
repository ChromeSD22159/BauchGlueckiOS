//
//  RegisterScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct RegisterScreen: View, Navigable {
    
    var navigate: (Screen) -> Void
    
    @Environment(\.theme) private var theme
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var services: Services
    
    @FocusState private var focusedField: FocusedField?
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifyPassword: String = ""

    var body: some View {
        AppBackground(color: theme.color.background) {
            theme.bubbleBackground {
                VStack(spacing: 16) {
                    AuthImageHeader(
                        headline: "Hallo!",
                        description: "Erstelle dein Konto!"
                    )
                    
                    TextFieldWithIcon<FocusedField>(
                        placeholder: "Max Musterman",
                        icon: "person.crop.square",
                        title: "Name:",
                        input: $name,
                        type: .text,
                        focusedField: $focusedField,
                        fieldType: .email,
                        onEditingChanged: { newValue in
                            name = newValue
                        }
                    )
                    .submitLabel(.next)
                    
                    TextFieldWithIcon<FocusedField>(
                        placeholder: "user.name@provider.de",
                        icon: "envelope.fill",
                        title: "Email:",
                        input: $email,
                        type: .text,
                        focusedField: $focusedField,
                        fieldType: .email,
                        onEditingChanged: { newValue in
                            email = newValue
                        }
                    )
                    .submitLabel(.next)
                    
                    TextFieldWithIcon(
                        placeholder: "* * * *",
                        icon: "lock.fill",
                        title: "Passwort",
                        input: $password,
                        type: .secure,
                        focusedField: $focusedField,
                        fieldType: .password,
                        onEditingChanged: { newValue in
                           password = newValue
                        }
                    )
                    .submitLabel(.next)
                
                    
                    TextFieldWithIcon(
                        placeholder: "* * * *",
                        icon: "lock.fill",
                        title: "Passwort wiederholen",
                        input: $verifyPassword,
                        type: .secure,
                        focusedField: $focusedField,
                        fieldType: .password,
                        onEditingChanged: { newValue in
                            verifyPassword = newValue
                        }
                    )
                    .submitLabel(.done)
                    
                    
                    HStack(spacing: theme.layout.padding) {
                        Spacer()
                        IconTextButton(
                            text: "Zur Anmeldung",
                            onEditingChanged: {
                                withAnimation {
                                    navigate(Screen.Login)
                                }
                            }
                        )
                        
                        TryButton(label: {
                            Label("", systemImage: "arrow.right").labelStyle(.iconOnly)
                        }, action: {
                            try await handleRegisterSubmit()
                        })
                        .buttonStyle(CapsuleButtonStyle())
                    }
                    
                    SignInWithProvider() { result in
                        
                    }
                    
                }
                .padding(.horizontal, theme.layout.padding)
            }
        }
        .withErrorPopover()
        .onTapGesture { focusedField = closeKeyboard(focusedField: focusedField) }
        .onSubmit { handleFocusState() }
    }
    
    enum FocusedField {
        case name, email, password, verifyPassword
    }
    
    private func closeKeyboard(focusedField: FocusedField?) -> FocusedField? {
        if focusedField != nil {
            return nil
        }
        
        return focusedField
    }
    
    private func handleFocusState() {
        switch focusedField {
            case .name:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = .verifyPassword
            case .verifyPassword: print("Login abgeschlossen")
            default: break
        }
    }
    
    private func handleRegisterSubmit() async throws {
        guard !email.isEmpty
        else { throw RegisterError.emailIsEmpty }
        
        guard !password.isEmpty
        else { throw RegisterError.passwordIsEmpty }
        
        guard !verifyPassword.isEmpty
        else { throw RegisterError.verifyPasswordIsEmpty }
        
        guard password == verifyPassword
        else { throw RegisterError.passwordsDoNotMatch }
         
        try await userViewModel.register(
            userProfile: UserProfile(
                firstName: name,
                email: email,
                userNotifierToken: DeviceTokenService.shared.getSavedDeviceToken() ?? ""
            ),
            password: password
        )
        
        try await services.apiService.sendDeviceTokenToBackend()
    }
}

#Preview("Light") {
    RegisterScreen(navigate: {_ in }) 
        .environmentObject(ErrorHandling())
}
