//
//  RegisterScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct RegisterScreen: View, Navigable {
    var navigate: (Screen) -> Void
    var theme: Theme = Theme()
    @EnvironmentObject var firebase: FirebaseRepository
    
    @FocusState private var focusedField: FocusedField?
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifyPassword: String = ""

    var body: some View {
        AppBackground(color: theme.background) {
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
                    
                    
                    HStack(spacing: theme.padding) {
                        Spacer()
                        IconTextButton(
                            text: "Zur Anmeldung",
                            onEditingChanged: {
                                withAnimation {
                                    navigate(Screen.Login)
                                }
                            }
                        )
                        
                        IconButton(icon: "arrow.right") {
                            guard !email.isEmpty,
                                  !password.isEmpty,
                                  !verifyPassword.isEmpty,
                                  password == verifyPassword
                            else { return }
                            
                            firebase.register(
                                userProfile: UserProfile(
                                    firstName: name,
                                    email: email
                                    // TODO: surgeryDateTimeStamp: timeStamp
                                ),
                                password: password
                            ) {_,_ in 
                                // wenn user eingeloggt ist
                                
                                // dann lade userProfile von firebase
                                
                                // wenn es kein userProfil für die userId gibt
                                // navigiere zum onboarding
                            }
                        }
                    }
                    
                    SignInWithGoogle(firebase: firebase)
                    
                }
                .padding(.horizontal, theme.padding)
            }
        }
        .onSubmit {
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
    }
    
    enum FocusedField {
        case name, email, password, verifyPassword
    }
}

#Preview("Light") {
    RegisterScreen(navigate: {_ in })
        .environmentObject(FirebaseRepository())
}
