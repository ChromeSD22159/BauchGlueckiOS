//
//  RegisterScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct RegisterScreen: View {
    var theme: Theme = Theme()
    
    @FocusState private var focusedField: FocusedField?
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    
    var navigate: (Screens) -> Void
    
    init(navigate: @escaping (Screens) -> Void) {
        self.navigate = navigate
    }
    
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
                                    navigate(Screens.Login)
                                }
                            }
                        )
                        
                        IconButton(icon: "arrow.right") {
                            // TO HOME
                        }
                    }
                    
                    HStack {
                        Text("Passwort vergessen?")
                            .font(.footnote)
                    }
                    .padding(.top, theme.padding * 2)
                    .onTapGesture {
                        withAnimation {
                            // TO HOME
                        }
                    }
                    
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

struct AuthImageHeader: View {
    var headline: String
    var description: String
    var theme: Theme = Theme()
    
    var body: some View {
        VStack {
            
            Image(uiImage: .magen)
                .resizable()
                .frame(width: 150, height: 150)
            
            VStack {
                Text(headline)
                    .font(theme.headlineText)
                    .foregroundStyle(theme.primary)
                
                Text(description)
                    .fontSytle(color: theme.onBackground)
            }
            
        }
    }
}

#Preview("Light") {
    RegisterScreen() {_ in
        
    }
}
