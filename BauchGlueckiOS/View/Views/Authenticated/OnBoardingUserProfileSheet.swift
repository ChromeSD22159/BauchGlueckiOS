//
//  OnBoardingUserProfileSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 26.10.24.
//

import SwiftUI

struct OnBoardingUserProfileSheet: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    
    @Binding var isUserProfileSheet: Bool
    
    // FormStates
    @FocusState private var focusedField: FocusedField?
    @State private var name: String = ""
    @State var email: String = ""
    @State var surgeryDateBinding: Date = Date()
    @State var startWeight: Double = 100.0
    
    var body: some View {
        AppBackground(color: theme.color.background) {
            theme.bubbleBackground {
                
                VStack(spacing: 32) {
                    
                    // Header
                    HStack {
                        Spacer()
                        Button( action: {
                            closeSheet()
                        }, label:  {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundStyle(theme.color.onBackground)
                                //.opacity( isValitInputs ? 1 : 0 )
                        })
                    }
                    .padding(.horizontal, theme.layout.padding)
                    .padding(.bottom, 32)
                    
                    HStack(spacing: 15) {
                        Image(uiImage: .magen)
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) { 
                            HeadLineText("Hallo!", color: theme.color.primary)
                             
                            FootLineText("Du hast dich mit deinem Google oder Apple Account registriert.\n\nBitte schließe die Registrierung ab!", color: theme.color.onBackground)
                        }
                    }

                    
                    VStack(spacing: 32) {
                        TextFieldWithIcon<FocusedField>(
                            placeholder: "Max Musterman",
                            icon: "person.crop.square",
                            title: "Name:",
                            input: $name,
                            type: .text,
                            focusedField: $focusedField,
                            fieldType: .name,
                            onEditingChanged: { newValue in
                                name = newValue
                            }
                        )
                        .submitLabel(.done)
                        
                        DatePicker("Operiert seit:", selection: $surgeryDateBinding , displayedComponents: .date)
                            .font(.footnote)
                        
                        VStack(alignment: .leading) {
                            FootLineText(
                                String(
                                    format: NSLocalizedString(
                                        "Startgewicht: %dkg",
                                        comment: "Label for starting weight with placeholder"
                                    ),
                                    Int(startWeight)
                                )
                            ) 
                            
                            Slider(
                                value: $startWeight, // STATE INT
                                in: 40...300,
                                step: 1,
                                label: {
                                    FootLineText(String(format: "Hauptmahlzeiten: %d", startWeight))
                                }
                            ).accentColor(theme.color.primary)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        IconTextButton(
                            text: "Speichern",
                            onEditingChanged: {
                                do {
                                    try saveProfile()
                                } catch {
                                    errorHandling.handle(error: error)
                                }
                            }
                        )
                        .disabled(isValitInputs ? false : true)
                        .opacity( isValitInputs ? 1 : 0.2 )
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, theme.layout.padding * 3)
                
            }
        }
        .onSubmit {
            switch focusedField {
                case .name: break
                case .email: break
                default: break
            }
       }
    }
    
    var isValitInputs: Bool {
        withAnimation {
            name.count >= 3
        }
    }
    
    private func closeSheet() {
        isUserProfileSheet = false
    }
    
    private func saveProfile() throws {
        guard let user = userViewModel.user else {
            throw FirebaseError.userNotFound
        }
        
        if (userViewModel.userProfile != nil) {
            withAnimation {
                isUserProfileSheet = false
            }
        } else {
            let profile = UserProfile(
                uid: user.uid,
                firstName: name,
                email: email,
                surgeryDateTimeStamp: TimeInterval(surgeryDateBinding.timeIntervalSince1970Milliseconds),
                mainMeals: 3,
                betweenMeals: 3,
                profileImageURL: nil,
                startWeight: startWeight,
                userNotifierToken: DeviceTokenService.shared.getSavedDeviceToken() ?? ""
            )
            
            Task {
                try await FirebaseService.saveUserProfile(userProfile: profile)
            }
            
            withAnimation {
                isUserProfileSheet = false
            }
        }
    }
    
    enum FocusedField {
        case name, email
    }
}
