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
    
    init(env: EnvironmentVariables = .localFrederik, firebase: FirebaseService) {
        let context: ModelContext = localDataScource.mainContext
        self.firebase = firebase
        self.apiService = StrapiApiClient(environment: env)
        self.countdownService = CountdownService(context: context, apiService: self.apiService)
    }
}
