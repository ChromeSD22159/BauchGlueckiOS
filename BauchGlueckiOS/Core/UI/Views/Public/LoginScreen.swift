//
//  LoginScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import FirebaseAuth

struct LoginScreen: View, Navigable {
    
    let theme = Theme.shared
    var navigate: (Screen) -> Void
    @EnvironmentObject var firebase: FirebaseService
    @EnvironmentObject var services: Services
    
    // FormStates
    @FocusState private var focusedField: FocusedField?
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        AppBackground(color: theme.background) {
            theme.bubbleBackground {
                VStack(spacing: 16) {
                    AuthImageHeader(
                        headline: "Wilkommen zurück!",
                        description: "Mit deinem Konto anmelden!"
                    )
                    
                    TextFieldWithIcon<FocusedField>(
                        placeholder: "max.mustermann@gmail.com",
                        icon: "envelope.fill",
                        title: "Email:",
                        input: $email,
                        type: .email,
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
                    .submitLabel(.done)
                    
                    HStack(spacing: theme.padding) {
                        Spacer()
                        IconTextButton(
                            text: "Zur Registrierung",
                            onEditingChanged: {
                                withAnimation {
                                    navigate(Screen.Register)
                                }
                            }
                        )
                        
                        IconButton(icon: "arrow.right") {
                            withAnimation {
                                guard !email.isEmpty,
                                      !password.isEmpty
                                else { return }
                                
                                firebase.login(email: email, password: password) { auth, _error in
                                    if let _ = auth?.user.uid {
                                        Task {
                                            try await services.apiService.sendDeviceTokenToBackend()
                                            
                                            services.medicationService.setAllMedicationNotifications()
                                        }
                                    }
                                }
                            }
                        }
                    }
                     
                    ErrorText(text: firebase.error?.localizedDescription ?? "")
                    
                    HStack {
                        Text("Passwort vergessen?")
                            .font(.footnote)
                    }
                    .padding(.top, theme.padding * 2)
                    .onTapGesture {
                        withAnimation {
                            navigate(Screen.ForgotPassword)
                        }
                    }.padding(.top, theme.padding)
                    
                    
                    SignInWithProvider() { result in
                        switch result {
                            case .success: services.medicationService.setAllMedicationNotifications()
                            case .failure: break
                        }
                    }
                }
                .padding(.horizontal, theme.padding)
            }
        }
        .onSubmit {
            switch focusedField {
                case .email: focusedField = .password
                case .password: print("Login abgeschlossen")
                default: break
            }
       }
    }
    
    enum FocusedField {
        case email, password
    }
} 
#Preview("Light") {
    LoginScreen(navigate: {_ in })
    .environmentObject(FirebaseService())
}
