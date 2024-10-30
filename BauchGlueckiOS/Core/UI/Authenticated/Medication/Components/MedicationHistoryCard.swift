//
//  MedicationHistoryCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct MedicationHistoryCard: View {
    let theme = Theme.shared
    
    var medication: Medication
    
    var calendarDates: [[Date]] = DateRepository().lastSixteenWeeks.reversed()

    var body: some View {
        GeometryReader { geo in
            VStack {
                Header()
                CalendarView(cellSize: geo.size.width / 20)
                Legend(cellSize: geo.size.width / 20, steps: medication.intakeTimes.count)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(theme.padding)
            .background(theme.surface)
            .cornerRadius(theme.radius)
            .shadow(radius: 3)
        }
    }
    
    @ViewBuilder func Header() -> some View {
        HStack(spacing: 20) {
            Image(systemName: "pills.fill")
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(medication.name)
                    .font(theme.headlineTextSmall)
                
                Text(medication.dosage)
                    .font(.footnote)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder func CalendarView(cellSize: CGFloat) -> some View {
        HStack(spacing: 3) {
            ForEach(calendarDates, id: \.self) { (week: [Date]) in
                VStack(spacing: 3) {
                    ForEach(week, id: \.self) { (day: Date) in
                        GridDayItem(
                            cellSize: cellSize,
                            timesCount: medication.intakeTimes.count,
                            intakeCount: intakeStatus(for: day)
                        )
                        .opacity(day > Date() ? 0.0 : 1.0)
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
                    GridDayItem(cellSize: cellSize, percent: percent)
                }
            }
        }
    }
    
    private func intakeStatus(for date: Date) -> Int {
        medication.intakeTimes.reduce(0) { count, intakeTime in
            count + intakeTime.intakeStatuses.filter { status in
                status.isTaken &&
                !status.isDeleted &&
                Calendar.current.isDate(status.date.toDate, inSameDayAs: date)
            }.count
        }
    }
}


