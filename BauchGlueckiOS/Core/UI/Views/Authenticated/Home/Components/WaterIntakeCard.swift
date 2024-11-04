//
//  WaterIntakeCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//

import SwiftUI
import SwiftData 
import FirebaseAuth

struct OLDWaterIntakeCard: View {
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var services: Services
    
    let glassSize = 0.25
    let theme: Theme
    var minGlassesForToday: Int
    
    @State var intakeTarget: Double = 0.0
    
    @Query(
        transaction: .init(animation: .bouncy)
    ) var intakes: [WaterIntake]
    
    var totalIntakeInLiter: Double {
        if intakesToday.isEmpty {
            return 0.0
        }
        
        return intakesToday.map { $0.value }.reduce(0, +)
    }
    
    var drunkenGlasses: Int {
       Int(totalIntakeInLiter / glassSize)
    }
    
    init(
        intakeTarget: Double
    ) {
        self.theme = Theme.shared
        self.intakeTarget = intakeTarget
        minGlassesForToday = Int(intakeTarget / glassSize)
    }

    var intakesToday: [WaterIntake] {
        intakes.filter {
            Calendar.current.isDateInToday($0.updatedAtOnDevice.toDate)
        }
    }

    var totalFilledGlasses: Int {
        intakesToday.count
    }
    
    var filledAndEmptyGlasses: [Bool] {
        let filledGlasses = Array(repeating: true, count: totalFilledGlasses)
        let emptyGlasses = Array(repeating: false, count: minGlassesForToday - totalFilledGlasses)

        return filledGlasses + emptyGlasses
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            VStack(spacing: 20) {
                
                VStack(spacing: theme.padding) {
                    Text("Wassereinnahme")
                        .font(theme.headlineTextSmall)
                    
                    Text(String(format: "Dein Ziel: %.1f L Wasser", intakeTarget))
                        .font(.footnote)
                    
                    Text(String(format: "%.2fL", totalIntakeInLiter))
                        .font(theme.headlineTextSmall)
                }
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 50))],
                    alignment: .center,
                    spacing: 10
                ) {

                    ForEach(Array(filledAndEmptyGlasses.enumerated()), id: \.offset) { index, isFilled in
                        FillableGlassView(
                            bgColor: theme.surface,
                            isActive: .constant(index == totalFilledGlasses),
                            isFilled: .constant(isFilled),
                            onClick: {
                                if !isFilled {
                                    services.waterIntakeService.insertGLass()
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
        .foregroundStyle(theme.onBackground)
        .background(theme.surface)
        .cornerRadius(theme.radius)
        .padding(.horizontal, 10)
    }
    
    private func customPredicateForToday(intake: WaterIntake) -> Bool {
        return Calendar.current.isDateInToday(intake.updatedAtOnDevice.toDate)
    }
}


struct WaterIntakeCard: View {
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var services: Services
    
    let glassSize = 0.25
    let theme: Theme
    var minGlassesForToday: Int
    
    @State var intakeTarget: Double = 0.0
    
    @Query() var intakes: [WaterIntake]
    
    var totalIntakeInLiter: Double {
        if intakesToday.isEmpty {
            return 0.0
        }
        
        return intakesToday.map { $0.value }.reduce(0, +)
    }
    
    var drunkenGlasses: Int {
       Int(totalIntakeInLiter / glassSize)
    }
    
    init(
        intakeTarget: Double
    ) {
        self.theme = Theme.shared
        self.intakeTarget = intakeTarget
        minGlassesForToday = Int(intakeTarget / glassSize)
    }

    var intakesToday: [WaterIntake] {
        intakes.filter {
            Calendar.current.isDateInToday($0.updatedAtOnDevice.toDate)
        }
    }

    var totalFilledGlasses: Int {
        intakesToday.count
    }
    
    var filledAndEmptyGlasses: [Bool] {
        let filledGlasses = Array(repeating: true, count: totalFilledGlasses)
        let emptyGlasses = Array(repeating: false, count: minGlassesForToday - totalFilledGlasses)

        return filledGlasses + emptyGlasses
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            VStack(spacing: 20) {
                
                VStack(spacing: theme.padding) {
                    Text("Wassereinnahme")
                        .font(theme.headlineTextSmall)
                        .onTapGesture {
                            intakes.forEach {
                                modelContext.delete($0)
                            } 
                        }
                    
                    Text(String(format: "Dein Ziel: %.1f L Wasser", intakeTarget))
                        .font(.footnote)
                    
                    Text(String(format: "%.2fL", totalIntakeInLiter))
                        .font(theme.headlineTextSmall)
                }
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 50))],
                    alignment: .center,
                    spacing: 10
                ) {
                    ForEach(Array(filledAndEmptyGlasses.enumerated()), id: \.offset) { index, isFilled in
                        FillableGlassView(
                            bgColor: theme.surface,
                            isActive: .constant(index == totalFilledGlasses),
                            isFilled: .constant(isFilled),
                            onClick: {
                                if !isFilled {
                                    services.waterIntakeService.insertGLass()
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
        .foregroundStyle(theme.onBackground)
        .background(theme.surface)
        .cornerRadius(theme.radius)
        .padding(.horizontal, 10)
    }
    
    private func customPredicateForToday(intake: WaterIntake) -> Bool {
        return Calendar.current.isDateInToday(intake.updatedAtOnDevice.toDate)
    }
}
