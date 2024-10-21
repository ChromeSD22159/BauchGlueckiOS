//
//  Repository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import SwiftUI
import SwiftData

@MainActor
class Services {
    
    let apiService = StrapiApiClient(environment: .production)
    let firebase: FirebaseService
    let countdownRepository: CountdownService
    
    init() {
        let context: ModelContext = localDataScource.mainContext
        self.firebase = FirebaseService()
        self.countdownRepository = CountdownService(context: context, apiService: apiService)
    }
}
