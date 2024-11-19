//
//  Repository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import SwiftUI
import SwiftData

@MainActor
class Services: ObservableObject {
    let apiService: StrapiApiClient
    let firebase: FirebaseService
    let countdownService: CountdownService
    let weightService: WeightService
    let waterIntakeService: WaterIntakeService
    let recipesService: RecipesDataService
    let mealPlanService: MealPlanService
    let medicationService: MedicationService
    let syncHistoryService: SyncHistoryService
    init(env: EnvironmentVariables = .localFrederik, firebase: FirebaseService, context: ModelContext) {
        let syncHistoryService = SyncHistoryService(context: context)
        self.firebase = firebase
        self.apiService = StrapiApiClient(environment: env)
        self.countdownService = CountdownService(context: context, apiService: self.apiService)
        self.weightService = WeightService(context: context, apiService: self.apiService, syncHistoryService: syncHistoryService)
        self.waterIntakeService = WaterIntakeService(context: context, apiService: self.apiService)
        self.recipesService = RecipesDataService(context: context, apiService: self.apiService)
        self.mealPlanService = MealPlanService(context: context)
        self.medicationService = MedicationService(context: context, apiService: self.apiService)
        self.syncHistoryService = syncHistoryService
    }
    
    func fetchFrombackend() {
        self.countdownService.fetchTimerFromBackend()
        self.weightService.fetchWeightsFromBackend()
        self.waterIntakeService.fetchWaterIntakesFromBackend()
        self.medicationService.fetchMedicationFromBackend()
    }
    
    func appStartOpenAd() {
        firebase.readAppSettings(completion: { result in
            switch result {
                case .success(let appSettings):
                
                if appSettings.showOpenAd {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        //GoogleAppOpenAd().requestAppOpenAd(adId: "ca-app-pub-3940256099942544/5575463023")
                    })
                }
                
                print("Firebase AdMob Status: \(appSettings.showOpenAd)")
                
                case .failure: break
            }
        })
    }
}
