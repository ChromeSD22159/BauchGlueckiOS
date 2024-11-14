//
//  CustomTextField.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct TextFieldWithIcon<FieldTypes: Hashable>: View {
    private let theme = Theme.shared
    
    var placeholder: String
    var title: String
    var input: Binding<String>
    var onEditingChanged: (String) -> Void
    var type: FieldType
    var footnote: String?
    
    @FocusState.Binding var focusedField: FieldTypes?  // Verwende hier FocusState.Binding
    var fieldType: FieldTypes
    var icon: String
    var keyboardType: UIKeyboardType
    init(
        placeholder: String,
        icon: String = "person.fill",
        title: String,
        input: Binding<String>,
        footnote: String? = nil,
        type: FieldType,
        focusedField: FocusState<FieldTypes?>.Binding,  // Verwende FocusState.Binding 
        fieldType: FieldTypes,
        keyboardType: UIKeyboardType = .default,
        onEditingChanged: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        self.title = title
        self.input = input
        self.icon = icon
        self.onEditingChanged = onEditingChanged
        self.type = type
        self._focusedField = focusedField  // Zuweisung des FocusState
        self.fieldType = fieldType
        self.keyboardType = keyboardType
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
                            onEditingChanged: { _ in
                                onEditingChanged(input.wrappedValue)
                            },
                            onCommit: {
                                onEditingChanged(input.wrappedValue)
                            }
                        )
                        .focused($focusedField, equals: fieldType)
                        .disableAutocorrection(true)
                        .keyboardType(keyboardType)
                    case .email:
                        TextField(
                            placeholder,
                            text: input,
                            onEditingChanged: { _ in
                                onEditingChanged(input.wrappedValue)
                            },
                            onCommit: {
                                onEditingChanged(input.wrappedValue)
                            }
                        )
                        .focused($focusedField, equals: fieldType)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                    case .secure:
                        SecureField(
                            placeholder,
                            text: input,
                            onCommit: {
                                onEditingChanged(input.wrappedValue)
                            }
                        )
                        .focused($focusedField, equals: fieldType)  // Verwendung von FocusState
                        .disableAutocorrection(true)
                        
                    case .editText:
                        TextEditor(text: input)
                            .lineLimit(10, reservesSpace: true)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .padding(5)
                            .cornerRadius(Theme.shared.radius)
                            .border(Theme.shared.onBackground.opacity(0.2), width: 1)
                            .focused($focusedField, equals: fieldType)
                    }
                }
                .padding(10)
                .background(theme.surface.opacity(0.9))
                .cornerRadius(theme.radius)
            } header: {
                Text(title)
                    .font(.footnote)
                    .padding(.leading, theme.padding)
            } footer: {
                if let footnote = footnote {
                    Text(footnote)
                        .font(.footnote)
                        .padding(.leading, theme.padding)
                }
            }
        }
    }
    
    enum FieldType {
        case text, secure, email, editText
    }
}

#Preview {
    ZStack {
        HStack {
            TextEditor(text: .constant("asdds"))
                .lineLimit(10, reservesSpace: true)
                .frame(minHeight: 80)
                .scrollContentBackground(.hidden)
                .padding(5)
                .cornerRadius(Theme.shared.radius)
                .border(Theme.shared.onBackground.opacity(0.2), width: 1)
        }
        .padding(10)
        .background(Theme.shared.surface.opacity(0.9))
        .cornerRadius(Theme.shared.radius)
    }
}
