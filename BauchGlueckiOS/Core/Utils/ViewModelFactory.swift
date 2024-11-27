//
//  ViewModelFactory.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.11.24.
//

import SwiftData

@MainActor
class ViewModelFactory {

    static func makeWeightViewModel(startWeight: Double, services: Services) -> WeightViewModel {
        return WeightViewModel(startWeight: startWeight, services: services)
    }

    @MainActor static func makeMealPlanViewModel(services: Services) -> MealPlanViewModel {
        return MealPlanViewModel(service: services)
    }

    static func makeUserViewModel() -> UserViewModel {
        return UserViewModel()
    }
    
    static func makeSettingsViewModel(userViewModel: UserViewModel) -> SettingViewModel {
        return SettingViewModel(userViewModel: userViewModel)
    }
    
    static func makeRecipeListViewModel(context: ModelContext) -> RecipeListViewModel {
        return RecipeListViewModel(modelContext: context)
    }

    static func makeMedicationListViewModel(services: Services) -> MedicationViewModel {
        return MedicationViewModel(services: services)
    }

    static func makeHomeViewModel(context: ModelContext) -> HomeViewModel {
        return HomeViewModel(context: context)
    }

    static func makeEditNoteViewModel(note: Node, allMoods: [Mood], maxCharacters: Int) -> EditNodeViewModel {
        return EditNodeViewModel(note: note, allMoods: allMoods, maxCharacters: maxCharacters)
    }

    static func makeAddNoteViewModel(context: ModelContext) -> AddNodeViewModel {
        return AddNodeViewModel(modelContext: context)
    }
}
