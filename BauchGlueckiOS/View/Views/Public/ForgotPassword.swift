//
//  test.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct ForgotPassword: View, Navigable {
    
    @Environment(\.theme) private var theme
    
    var navigate: (Screen) -> Void
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var errorHandling : ErrorHandling
    @FocusState private var focusedField: FocusedField?
    @State private var email: String = ""

    var body: some View {
        AppBackground(color: theme.color.background) {
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
                    
                    HStack(spacing: theme.layout.padding) {
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
                                
                                Task {
                                    do {
                                        try await FirebaseService.forgotPassword(email: email)
                                    } catch {
                                        errorHandling.handle(error: error)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, theme.layout.padding)
            }
        }
        .onTapGesture { focusedField = closeKeyboard(focusedField: focusedField) }
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
    
    private func closeKeyboard(focusedField: FocusedField?) -> FocusedField? {
        if focusedField != nil {
            return nil
        }
        
        return focusedField
    }
}
 
#Preview("Light") {
    ForgotPassword(navigate: {_ in }) 
}
