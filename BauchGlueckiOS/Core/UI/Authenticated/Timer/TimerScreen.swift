//
//  TimerScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import FirebaseAuth

struct TimerScreen: View {
    private let theme: Theme = Theme.shared

    let firebase: FirebaseService

    @Query( sort: \CountdownTimer.name, order: .reverse ) var countdownTimers: [CountdownTimer]

    var body: some View {
        ScreenHolder(
            firebase: firebase
        ) {
            VStack(spacing: theme.padding) {
                
                let groupedTimers = Dictionary(grouping: countdownTimers) { $0.name }
                let sortedTimers = groupedTimers.sorted { $0.key > $1.key }.flatMap { $0.value.sorted(by: { $0.name < $1.name }) }//.filter { $0.userID == firebase.user?.uid } 
                
                ForEach(sortedTimers) { timer in
                    @Bindable var currentTimer = timer
                    TimerCard(timer: currentTimer)
                }
            }.padding(.horizontal, theme.padding)
        }
    }
}





