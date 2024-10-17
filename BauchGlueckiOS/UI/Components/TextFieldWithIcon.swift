//
//  CustomTextField.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct TextFieldWithIcon: View {
    var placeholder: String
    var title: String
    var input: Binding<String>
    var onEditingChanged: (String) -> Void
    var type: FieldType
    var theme = Theme()
    var footnote: String?
    @State var focusedField: FocusState<LoginScreen.FocusedField?>.Binding
    var fieldType: LoginScreen.FocusedField
    var icon: String
    
    init(
        placeholder: String,
        icon: String = "person.fill",
        title: String,
        input: Binding<String>,
        footnote: String? = nil,
        type: FieldType = .text,
        focusedField: FocusState<LoginScreen.FocusedField?>.Binding,
        fieldType: LoginScreen.FocusedField,
        onEditingChanged: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        self.title = title
        self.input = input
        self.icon = icon
        self.onEditingChanged = onEditingChanged
        self.type = type
        self.focusedField = focusedField
        self.fieldType = fieldType
        self.footnote = footnote
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Section {
                HStack(spacing: theme.padding) {
                      Image(systemName: icon)
                        .frame(width: 24, height: 24)
                    
                      switch type {
                        case .text:
                            TextField(
                                placeholder,
                                text: input,
                                onEditingChanged: { newValue in
                                    onEditingChanged(input.wrappedValue)
                                },
                                onCommit: {
                                    onEditingChanged(input.wrappedValue)
                                }
                            )
                            .focused(focusedField, equals: fieldType)
                            .disableAutocorrection(true)
                        case .secure:
                            SecureField(
                                placeholder,
                                text: input,
                                onCommit: {
                                    onEditingChanged(input.wrappedValue)
                                }
                            )
                            .focused(focusedField, equals: fieldType)
                            .disableAutocorrection(true)
                        
                      }
                }
                .padding(10)
                .background(theme.surface.opacity(0.9))
                .cornerRadius(theme.radius)
            } header:  {
                Text(title)
                    .font(.footnote)
                    .padding(.leading, theme.padding)
            } footer: {
                if (footnote != nil) {
                    Text(footnote!)
                       .font(.footnote)
                       .padding(.leading, theme.padding)
                }
            }
           
        }
    }
    
    enum FieldType {
       case text, secure
    }
}
