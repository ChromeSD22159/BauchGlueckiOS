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
    private var userViewModel: UserViewModel
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        Task {
            try await loadUserProfile()
        }
    }
    
    var isFocused: Bool = false
    
    @Published var showImageSheet: Bool = false

    var greeting: LocalizedStringKey {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        let user = "\(userViewModel.userProfile?.firstName ?? "Unknown")!"
        
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
        guard let surgeryDate = userViewModel.userProfile?.surgeryDate else { return "Kein Operationsdatum" }

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
            get: { self.userViewModel.userProfile?.firstName ?? "" },
            set: { newValue in
                self.userViewModel.userProfile?.firstName = newValue
            }
        )
    }
    
    var surgeryDateBinding: Binding<Date> {
        Binding(
            get: { self.userViewModel.userProfile?.surgeryDate ?? Date() },
            set: { newValue in
                self.userViewModel.userProfile?.surgeryDate = newValue
            }
        )
    }
    
    var startWeigtBinding: Binding<Double> {
        Binding(
            get: { self.userViewModel.userProfile?.startWeight ?? 100 },
            set: { newValue in
                self.userViewModel.userProfile?.startWeight = newValue
            }
        )
    }

    var waterDayIntakeBinding: Binding<Double> {
        Binding(
            get: { self.userViewModel.userProfile?.waterDayIntake ?? 2.0 },
            set: { newValue in
                self.userViewModel.userProfile?.waterDayIntake = newValue
            }
        )
    }
    
    var mainMealsBinding: Binding<Int> {
        Binding(
            get: { self.userViewModel.userProfile?.mainMeals ?? 3 },
            set: { newValue in
                self.userViewModel.userProfile?.mainMeals = newValue
            }
        )
    }
    
    var betweenMealsBinding: Binding<Int> {
        Binding(
            get: { self.userViewModel.userProfile?.betweenMeals ?? 3 },
            set: { newValue in
                self.userViewModel.userProfile?.betweenMeals = newValue
            }
        )
    }
    
    var syncingBinding: Binding<Bool> {
        Binding(
            get: { self.userViewModel.userProfile?.syncData ?? true },
            set: { newValue in
                self.userViewModel.userProfile?.syncData = newValue
            }
        )
    }
    
    func updateProfile() async throws {
        guard
            let user = Auth.auth().currentUser
        else {
            return print("Cant updateProfile: Not logged In")
        }
        
        var profile = try await FirebaseService.readUserProfileById(userId: user.uid)
        
        profile.firstName = self.firstNameBinding.wrappedValue
        profile.surgeryDateTimeStamp = self.surgeryDateBinding.wrappedValue.timeIntervalSince1970 * 1000
        profile.mainMeals = self.mainMealsBinding.wrappedValue
        profile.betweenMeals = self.betweenMealsBinding.wrappedValue
        profile.startWeight = self.startWeigtBinding.wrappedValue
        profile.waterDayIntake = self.waterDayIntakeBinding.wrappedValue
        
        do {
            try await FirebaseService.saveUserProfile(userProfile: profile)
            
            try await loadUserProfile()
        } catch {
            throw error
        }
    }
    
    func uploadProfileImage() async throws {
        if self.userViewModel.userImage.cgImage != nil {
            let profile = try await FirebaseService.uploadAndSaveProfileImage(userProfileImage: self.userViewModel.userImage) 
        }
    }
    
    func loadUserProfile() async throws {
        guard let user = Auth.auth().currentUser else { throw FirebaseError.userNotFound }
        
        do {
            let profile = try await FirebaseService.readUserProfileById(userId: user.uid)
            DispatchQueue.main.async {
                self.userViewModel.userProfile = profile
            }
        } catch {
            throw error
        }
    }
}
