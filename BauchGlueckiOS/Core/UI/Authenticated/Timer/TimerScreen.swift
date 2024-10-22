//
//  TimerScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//

import Foundation
import SwiftUI

struct TimerScreen: View {
    let firebase: FirebaseService
    
    var body: some View {
        ScreenHolder(firebase: firebase) {
            let count = 1...10
            
            ForEach(count, id: \.self) { index in
                SectionImageCard(image: .icMealPlan,title: "MealPlaner",description: "Erstelle deinen MealPlan, indifiduell auf deine bedürfnisse.")
                    .navigateTo(
                        firebase: firebase,
                        destination: Destination.timer,
                        target: { TimerScreen(firebase: firebase) }
                    )
            }
            
        }
    }
}
