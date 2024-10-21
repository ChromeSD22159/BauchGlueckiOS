//
//  Repository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import SwiftUI
import SwiftData

@MainActor
class Repository {
    let firebase: FirebaseRepository
    let countdownRepository: CountdownRepository
    
    init() {
        let context: ModelContext = localDataScource.mainContext
        self.firebase = FirebaseRepository()
        self.countdownRepository = CountdownRepository(context: context)
    }
}
