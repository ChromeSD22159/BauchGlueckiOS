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
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        Form {
            List {
                ChangeImage()
                
                PersonalData()
                
                MealsData()
                
                WaterIntake()
            }
        }
    }
    
    @ViewBuilder func ChangeImage() -> some View {
        Section {
            HStack(spacing: 20) {
                if let profile = userViewModel.userProfile, let imageUrl = profile.profileImageURL  {
                    
                    AsyncCachedImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .cornerRadius(50)
                            .padding(.all, 4)
                            .frame(width: 100, height: 100)
                            .background(theme.color.backgroundGradient)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .padding(8)
                    } placeholder: {
                        ZStack{
                            Image(uiImage: .placeholder)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .cornerRadius(50)
                        .padding(.all, 4)
                        .frame(width: 100, height: 100)
                        .background(theme.color.backgroundGradient)
                        .clipShape(Circle())
                        .padding(8)
                    }
                }
                
                Image(uiImage: userViewModel.userImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                
                Button(action: {
                    viewModel.showImageSheet.toggle()
                }, label: {
                    Text("Bild ändern")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(theme.color.backgroundGradient)
                            .cornerRadius(16)
                            .foregroundColor(.white)
                })
            }
            .sheet(isPresented: $viewModel.showImageSheet, onDismiss: {
                Task {
                    do {
                        try await viewModel.uploadProfileImage()
                    } catch {
                        print(error)
                    }
                }
            }) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $userViewModel.userImage)
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
                ).accentColor(theme.color.primary)
                
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
                ).accentColor(theme.color.primary)
            }
        } header: {
            Text("Flüssigkeitszufuhr")
        }
    }
}
