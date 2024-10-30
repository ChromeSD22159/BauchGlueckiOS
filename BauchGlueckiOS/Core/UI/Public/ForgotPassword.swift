//
//  test.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct ForgotPassword: View, Navigable {
    
    let theme = Theme.shared
    
    var navigate: (Screen) -> Void
    
    @EnvironmentObject var firebase: FirebaseService
    @FocusState private var focusedField: FocusedField?
    @State private var email: String = ""

    var body: some View {
        AppBackground(color: theme.background) {
            theme.bubbleBackground {
                VStack(spacing: 16) {
                    AuthImageHeader(
                        headline: "Passwort vergessen?",
                        description: "Lass dir einen Link schicken um,\n dein Passwort zurückzusetzen!"
                    )
                    
                    TextFieldWithIcon<FocusedField>(
                        placeholder: "max.mustermann@gmail.com",
                        icon: "envelope.fill",
                        title: "",
                        input: $email,
                        footnote: "",
                        type: .text,
                        focusedField: $focusedField,
                        fieldType: .email,
                        onEditingChanged: { newValue in
                            email = newValue
                        }
                    )
                    .submitLabel(.next)
                    
                    HStack(spacing: theme.padding) {
                        Spacer()
                        IconTextButton(
                            text: "zurück",
                            onEditingChanged: {
                                withAnimation {
                                    navigate(Screen.Login)
                                }
                            }
                        )
                        
                        IconTextButton(
                            text: "E-Mail anfordern!",
                            onEditingChanged: {
                                guard !email.isEmpty else { return }
                                firebase.forgotPassword(email: email)
                            }
                        )
                    }
                    
                    // TODO: REFACTOR
                    Text(firebase.error?.localizedDescription ?? "")
                        .font(.callout)
                        .foregroundStyle(Color.red)
                }
                .padding(.horizontal, theme.padding)
            }
        }
        .onSubmit {
            switch focusedField {
                case .email:
                    focusedField = .password
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
    ForgotPassword(navigate: {_ in })
        .environmentObject(FirebaseService())
}
