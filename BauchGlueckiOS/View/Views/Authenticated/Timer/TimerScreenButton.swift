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

struct TimerScreenButton: View {
    @EnvironmentObject var services: Services
    
    @Environment(\.theme) private var theme

    @Query(
        sort: \CountdownTimer.name,
        order: .forward,
        transaction: .init(animation: .bouncy)
    ) var countdownTimers: [CountdownTimer]

    init() {
        let user = Auth.auth().currentUser?.uid ?? ""
        self._countdownTimers = Query(filter: #Predicate<CountdownTimer> { timer in
            timer.isDeleted == false && timer.userID == user
        })
    }
    
    var body: some View {
       
        ScreenHolder() {
            VStack(spacing: theme.layout.padding) {
                
                let groupedTimers = Dictionary(grouping: countdownTimers) { $0.name }
                let sortedTimers = groupedTimers.sorted { $0.key > $1.key }.flatMap { $0.value.sorted(by: { $0.name < $1.name }) }
                
                if(sortedTimers.count > 0) {
                    ForEach(sortedTimers) { timer in
                        
                        @Bindable var timerBinding = timer
                        TimerCard(timer: timerBinding)
                          
                    }
                } else {
                    // TODO: No Timer Card from Android
                }
                
            }.padding(.horizontal, theme.layout.padding)
        }
        .onChange(of: countdownTimers.count, {
            services.countdownService.syncTimers()
        })
    }
}
