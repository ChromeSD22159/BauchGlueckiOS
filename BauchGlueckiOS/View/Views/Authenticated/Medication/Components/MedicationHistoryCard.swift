//
//  MedicationHistoryCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct MedicationHistoryCard: View {
    @Environment(\.theme) private var theme
    
    var medication: Medication
    
    var calendarDates: [[Date]] = DateHelper.lastSixteenWeeks.reversed()

    var body: some View {
        GeometryReader { geo in
            VStack {
                Header()
                CalendarView(cellSize: geo.size.width / 20)
                Legend(cellSize: geo.size.width / 20, steps: medication.intakeTimes.count)
            }
            .padding(theme.layout.padding)
            .frame(maxWidth: .infinity)
            .background(theme.color.surface)
            .cornerRadius(theme.layout.radius)
            .shadow(radius: 3)
        }.frame(height: 260)
    }
    
    @ViewBuilder func Header() -> some View {
        HStack(spacing: 20) {
            Image(systemName: "pills.fill")
                .font(.title)
            
            VStack(alignment: .leading) { 
                HeadLineText(medication.name)
                 
                FootLineText(medication.dosage)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder func CalendarView(cellSize: CGFloat) -> some View {
        HStack(spacing: 3) {
            ForEach(calendarDates, id: \.self) { (week: [Date]) in
                VStack(spacing: 3) {
                    ForEach(week, id: \.self) { (dayDate: Date) in
                        GridDayItem(
                            cellSize: cellSize,
                            percent: intakeStatusPercent(for: dayDate)
                        )
                        .opacity(dayDate > Date() ? 0.0 : 1.0)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func Legend(
        cellSize: CGFloat,
        steps: Int
    ) -> some View {
        let percents = Array(0..<(steps + 1)).map { Double($0) / Double(steps + 1) * 100 }.sorted()
        HStack{
            Spacer()
            
            HStack(spacing: 3) {
                ForEach(percents, id: \.self) { percent in
                    GridDayItem(cellSize: cellSize, percent: Int(percent))
                }
            }
        }
    }
    
    private func intakeStatusPercent(for date: Date) -> Int {
        let totalIntakes = medication.intakeTimes.count

        // Verhindere Division durch 0
        guard totalIntakes > 0 else {
            return 0
        }

        let takenIntakes = medication.intakeTimes.filter { intakeTime in
            intakeTime.intakeStatuses.contains { status in
                status.isTaken && !status.isDeleted && Calendar.current.isDate(status.date.toDate, inSameDayAs: date)
            }
        }

        let percentage = Double(takenIntakes.count) / Double(totalIntakes) * 100

        return Int(percentage)
    }
}
