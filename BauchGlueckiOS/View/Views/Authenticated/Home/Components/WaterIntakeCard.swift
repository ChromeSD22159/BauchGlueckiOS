//
//  WaterIntakeCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//

import SwiftUI
import SwiftData 
import FirebaseAuth

struct WaterIntakeCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var services: Services
    
    let glassSize = 0.25
    var minGlassesForToday: Int
    
    @State var intakeTarget: Double = 0.0
    
    @Query() var intakes: [WaterIntake]
     
    init(
        intakeTarget: Double
    ) { 
        self.intakeTarget = intakeTarget
        minGlassesForToday = Int(intakeTarget / glassSize)
        
        let userID = Auth.auth().currentUser?.uid ?? ""
                
        let predicate = #Predicate<WaterIntake> { weight in
            weight.userId == userID && weight.isDeleted == false
        }
        
        _intakes = Query(filter: predicate)
    }
    
    var totalIntakeInLiter: Double {
        if intakesToday.isEmpty {
            return 0.0
        }
        
        return intakesToday.map { $0.value }.reduce(0, +)
    }
    
    var drunkenGlasses: Int {
       Int(totalIntakeInLiter / glassSize)
    }

    var intakesToday: [WaterIntake] {
        let todayIntakes = intakes.filter {
            Calendar.current.isDateInToday($0.updatedAtOnDevice.toDate)
        }
        
        return todayIntakes
    }

    var totalFilledGlasses: Int {
        return intakesToday.count
    }
    
    var filledAndEmptyGlasses: [Bool] {
        let emptyGlassesCount = max(0, minGlassesForToday - totalFilledGlasses)

        let filledGlasses = Array(repeating: true, count: totalFilledGlasses)
        var emptyGlasses = Array(repeating: false, count: emptyGlassesCount)

        // Wenn Ziel erreicht oder überschritten, füge ein zusätzliches Glas hinzu
        if totalFilledGlasses >= minGlassesForToday {
            emptyGlasses.append(false) // Ein zusätzliches leeres Glas anzeigen
        }

        return filledGlasses + emptyGlasses
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 20) {
                
                VStack(spacing: theme.layout.padding) {
                    Text("Wassereinnahme")
                        .font(theme.font.headlineTextSmall)
                    
                    Text(String(format: "Dein Ziel: %.1f L Wasser", intakeTarget))
                        .font(.footnote)
                    
                    Text(String(format: "%.2fL", totalIntakeInLiter))
                        .font(theme.font.headlineTextSmall)
                }
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 50))],
                    alignment: .center,
                    spacing: 10
                ) {
                    ForEach(Array(filledAndEmptyGlasses.enumerated()), id: \.offset) { index, isFilled in
                        FillableGlassView(
                            bgColor: theme.color.surface,
                            isActive: .constant(index == totalFilledGlasses),
                            isFilled: .constant(isFilled),
                            onClick: {
                                if !isFilled && totalIntakeInLiter < 3.0 {
                                    try services.waterIntakeService.insertGLass()
                                }
                            },
                            animationDelay: index
                        )
                        .frame(width: 50, height: 50)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(10)
        .foregroundStyle(theme.color.onBackground)
        .background(theme.color.surface)
        .cornerRadius(theme.layout.radius)
        .padding(.horizontal, 10)
    }
}
