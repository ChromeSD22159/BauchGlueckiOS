//
//  SettingViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import Foundation
import SwiftUI
import FirebaseAuth

class SettingViewModel: ObservableObject {
    var authManager: FirebaseService
    
    @Published var userProfile: UserProfile? = nil
    
    init(authManager: FirebaseService) {
        self.authManager = authManager
        
        loadUserProfile()
    }
    
    @FocusState var isFocused: Bool
    
    @Published var showImageSheet = false

    var greeting: LocalizedStringKey {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        let user = "\(authManager.userProfile?.firstName ?? "Unknown")!"
        
        let formattedString: String
        
        switch hour {
            case 2 ... 11 : formattedString = String(format: NSLocalizedString("Guten morgen, %@", comment: ""), user)
            case 11 ... 18 : formattedString = String(format: NSLocalizedString("Hallo, %@", comment: ""), user)
            case 18 ... 22 : formattedString = String(format: NSLocalizedString("Guten abend, %@", comment: ""), user)
            default: formattedString = String(format: NSLocalizedString("Hallo, %@", comment: ""), user)
        }
        
        return LocalizedStringKey(formattedString)
    }
    
    var timeSinceSurgery: LocalizedStringKey {
        guard let surgeryDate = authManager.userProfile?.surgeryDate else { return "Kein Operationsdatum" }

        let calendar = Calendar.current
        let today = Date()
        
        let components = calendar.dateComponents([.year, .month, .day], from: surgeryDate, to: today)

        let years: Int = abs(components.year ?? 0)
        let months: Int = abs(components.month ?? 0)
        let days: Int = abs(components.day ?? 0)

        if surgeryDate < today {
            let formattedString = String(format: NSLocalizedString("%d Jahre, %d Monate, %d Tage seit deinem Neustart.", comment: ""), years, months, days)
            return LocalizedStringKey(formattedString)
        } else {
            let formattedString: String
            
            if years > 0 {
                formattedString = String(format: NSLocalizedString("Nur %d Jahre, %d Monate, %d Tage seit deinem Neustart.", comment: ""), years, months, days)
            } else if months > 0 {
                formattedString = String(format: NSLocalizedString("Nur %d Monate, %d Tage seit deinem Neustart.", comment: ""), months, days)
            } else {
                formattedString = String(format: NSLocalizedString("Nur %d Tage bis zu deinem Neustart.", comment: ""), days)
            }
            
            return LocalizedStringKey(formattedString)
        }
    }

    var firstNameBinding: Binding<String> {
        Binding(
            get: { self.authManager.userProfile?.firstName ?? "" },
            set: { newValue in
                self.authManager.userProfile?.firstName = newValue
            }
        )
    }
    
    var surgeryDateBinding: Binding<Date> {
        Binding(
            get: { self.authManager.userProfile?.surgeryDate ?? Date() },
            set: { newValue in
                self.authManager.userProfile?.surgeryDate = newValue
            }
        )
    }
    
    var startWeigtBinding: Binding<Double> {
        Binding(
            get: { self.authManager.userProfile?.startWeight ?? 100 },
            set: { newValue in
                self.authManager.userProfile?.startWeight = newValue
            }
        )
    }

    var waterDayIntakeBinding: Binding<Double> {
        Binding(
            get: { self.authManager.userProfile?.waterDayIntake ?? 2.0 },
            set: { newValue in
                self.authManager.userProfile?.waterDayIntake = newValue
            }
        )
    }
    
    var mainMealsBinding: Binding<Int> {
        Binding(
            get: { self.authManager.userProfile?.mainMeals ?? 3 },
            set: { newValue in
                self.authManager.userProfile?.mainMeals = newValue
            }
        )
    }
    
    var betweenMealsBinding: Binding<Int> {
        Binding(
            get: { self.authManager.userProfile?.betweenMeals ?? 3 },
            set: { newValue in
                self.authManager.userProfile?.betweenMeals = newValue
            }
        )
    }
    
    var SyncingBinding: Binding<Bool> {
        Binding(
            get: { self.authManager.userProfile?.syncData ?? true },
            set: { newValue in
                self.authManager.userProfile?.syncData = newValue
            }
        )
    }
    
    func updateProfile() {
        guard
            let user = Auth.auth().currentUser
        else {
            return print("Cant updateProfile: Not logged In")
        }
        
        authManager.readUserProfileById(userId: user.uid, completion: { profile in
            
            if var new: UserProfile = profile {
                new.uid = user.uid
                new.firstName = self.firstNameBinding.wrappedValue
                new.surgeryDateTimeStamp = self.surgeryDateBinding.wrappedValue.timeIntervalSince1970 * 1000
                new.mainMeals = self.mainMealsBinding.wrappedValue
                new.betweenMeals = self.betweenMealsBinding.wrappedValue
                new.startWeight = self.startWeigtBinding.wrappedValue
                new.waterDayIntake = self.waterDayIntakeBinding.wrappedValue
                
                self.authManager.saveUserProfile(userProfile: new, completion: {_ in 
                    
                })
                
                self.loadUserProfile()
            }
        })
    }
    
    func updateProfileImage() {
        authManager.uploadAndSaveProfileImage {_ in }
    }
    
    func loadUserProfile() {
        if let user = Auth.auth().currentUser {
            authManager.readUserProfileById(userId: user.uid) { userProfile in
                var new = userProfile
                
                if let image = userProfile?.profileImageURL {
                    new?.profileImageURL = URLCacheManager.shared.generateUniqueUrl(for: image).absoluteString
                }
                
                self.userProfile = new
            }
        }
    } 
} 
