//
//  LoginScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct LoginScreen: View {
    var theme: Theme = Theme()
    
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
                    .submitLabel(.done)
                    
                    HStack(spacing: theme.padding) {
                        Spacer()
                        IconTextButton(
                            text: "Zur Registierung",
                            onEditingChanged: {}
                        )
                        
                        IconButton(icon: "arrow.right") {
                            
                        }
                    }
                    
                    HStack {
                        Text("Passwort vergessen?")
                            .font(.footnote)
                    }.padding(.top, theme.padding * 2)
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
    LoginScreen()
}
