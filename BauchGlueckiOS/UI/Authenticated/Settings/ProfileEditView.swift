//
//  ProfileEditView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import Foundation
import SwiftUI

struct ProfileEditView: View {
    @StateObject var viewModel: SettingViewModel

    var theme: Theme = Theme()
    
    var body: some View {
        Form {
            List {
                ChangeImage()
                
                PersonalData()
                
                MealsData()
                
                WaterIntake()
            }
        }
        .onAppear {
            viewModel.loadUserProfileAndImage()
        }
    }
    
    @ViewBuilder func ChangeImage() -> some View {
        Section {
            HStack(spacing: 20) {

                if let image = viewModel.userProfileImage {
                    Image(uiImage: image)
                            .resizable()
                            .cornerRadius(50)
                            .padding(.all, 4)
                            .frame(width: 100, height: 100)
                            .background(theme.backgroundGradient)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .padding(8)
                } else {
                    ZStack{
                        Image(uiImage: .placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .cornerRadius(50)
                    .padding(.all, 4)
                    .frame(width: 100, height: 100)
                    .background(theme.backgroundGradient)
                    .clipShape(Circle())
                    .padding(8)
                }
                
                
                Button(action: {
                    viewModel.showImageSheet.toggle()
                }, label: {
                    Text("Bild ändern")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(theme.backgroundGradient)
                            .cornerRadius(16)
                            .foregroundColor(.white)
                })
            }
            .sheet(isPresented: $viewModel.showImageSheet, onDismiss: {
                // upload
                viewModel.authManager.uploadAndSaveProfileImage { result in
                    switch result {
                        
                    case .success(let url):
                        print(url)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                // reload vm
                viewModel.loadUserProfileAndImage()
            } ) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.authManager.userProfileImage)
            }
        } header: {
            Text("Profil Bild")
        }
    }
    
    @ViewBuilder func PersonalData() -> some View {
        Section {
            HStack(spacing: 20) {
                Text("Vorname:")
                
                TextField("Max", text: viewModel.firstNameBinding)
                    .textFieldClearButton(text: viewModel.firstNameBinding)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity)
            
            VStack(alignment: .leading) {
                Text(
                    String(
                        format: NSLocalizedString(
                            "Startgewicht: %dkg",
                            comment: "Label for starting weight with placeholder"
                        ),
                        Int(viewModel.startWeigtBinding.wrappedValue)
                    )
                )
                
                Slider(
                    value: viewModel.startWeigtBinding,
                    in: 40...300,
                    step: 1,
                    label: {
                        Text(String(format: NSLocalizedString("Hauptmahlzeiten: %d", comment: ""), viewModel.mainMealsBinding.wrappedValue))
                    }
                ).accentColor(theme.primary)
                
            }
        } header: {
            Text("Persönliche Daten")
        }
        
    }
    
    @ViewBuilder func MealsData() -> some View {
        Section {
            
            Stepper(
                value: viewModel.mainMealsBinding,
                in: 3...10,
                step: 1,
                label: {
                    Text(String(format: NSLocalizedString("Hauptmahlzeiten: %d", comment: ""), viewModel.mainMealsBinding.wrappedValue))
                }
            )
            
            Stepper(
                value: viewModel.betweenMealsBinding,
                in: 3...10,
                step: 1,
                label: {
                    Text(String(format: NSLocalizedString("Zwischenmahlzeiten: %d", comment: ""), viewModel.betweenMealsBinding.wrappedValue))
                }
            )
            
            Text(String(format: NSLocalizedString("Mahlzeiten total: %d", comment: ""), viewModel.betweenMealsBinding.wrappedValue + viewModel.mainMealsBinding.wrappedValue))
        } header: {
            Text("Mahlzeiten")
        }
    }
    
    @ViewBuilder func WaterIntake() -> some View {
        Section {
            VStack(alignment: .leading) {
                Text(
                    String(
                        format: NSLocalizedString(
                            "Wasseraufnahme pro Tag: %.1fl",
                            comment: "Label for starting weight with placeholder"
                        ),
                        viewModel.waterDayIntakeBinding.wrappedValue
                    )
                )
                
                Slider(
                    value: viewModel.waterDayIntakeBinding,
                    in: 1.5...3.5,
                    step: 0.5,
                    label: {
                        Text(String(format: NSLocalizedString("Wasseraufnahme pro Tag: %.1f", comment: ""), viewModel.waterDayIntakeBinding.wrappedValue))
                    }
                ).accentColor(theme.primary)
            }
        } header: {
            Text("Flüssigkeitszufuhr")
        }
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    @State private var iconName: String = "xmark.seal.fill"
    
    private var isValidTxt: Bool {
        text.count >= 3
    }
    
    private var dynamicImage: String {
        isValidTxt ? "checkmark.seal.fill" : "xmark.seal.fill"
    }
    
    private var dynamicColor: Color {
        isValidTxt ? Theme().primary : Color(UIColor.opaqueSeparator)
    }
    
    func body(content: Content) -> some View {
        HStack {
            content
                
            Spacer()
            
            Image(systemName: dynamicImage)
                .foregroundColor(dynamicColor)
            
        }
    }
}
