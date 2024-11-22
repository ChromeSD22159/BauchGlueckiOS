//
//  HomeWeightMockCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct HomeWeightMockCard: View {
    @Environment(\.theme) private var theme
    
    var gradient = LinearGradient(colors: [
        Theme.color.primary.opacity(0.55),
        Theme.color.primary.opacity(0.1)
    ], startPoint: .top, endPoint: .bottom)
    
    @State var mockList: [WeeklyAverage] = []

    var isAscendingTrend: Bool {
        guard mockList.count == 7 else {
            return false
        }
        
        var ascendingCount = 0
        var descendingCount = 0
 
        for i in 0..<mockList.count - 1 {
            if mockList[i].avgValue < mockList[i + 1].avgValue {
                ascendingCount += 1
            } else if mockList[i].avgValue > mockList[i + 1].avgValue {
                descendingCount += 1
            }
        }
 
        if ascendingCount > descendingCount {
            return true
        }  else {
            return false
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: isAscendingTrend ? "arrow.up.forward.circle.fill" : "arrow.down.forward.circle.fill")
                    
                    Text(isAscendingTrend ? "Aufsteigender" : "Absteigender" + " Trend")
                        .font(.footnote)
                     
                    Spacer()
                }   .foregroundStyle(theme.color.onBackground)
                
                HStack(alignment: .bottom, spacing: 15) {
                    ForEach(mockList, id: \.week) { week in
                        VStack(spacing: 30) {
                            Spacer()
                            
                            HStack(alignment: .bottom) {
                                Capsule()
                                    .frame(width: 25, height: calculateHeight(input: week.avgValue) )
                                    .foregroundStyle(theme.color.primary)
                            }
                            
                            HStack(alignment: .bottom) {
                                
                                Text(week.week.formatDateDDMM)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(theme.color.onBackground)
                                    .rotationEffect(Angle(degrees: -90))
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(height: 40)
                        }
                    }
                }
                .opacity(0.25)
                .frame(height: 300)
            }
            .padding(theme.layout.padding)
            .padding(theme.layout.padding)
            .background(gradient)
            .cornerRadius(theme.layout.radius)
            
            VStack {
                Text("In einigen Tagen siehst du hier deine Statistik") 
                    .foregroundStyle(theme.color.onBackground)
            }
        }
        .onAppLifeCycle(appearAndActive: {
            loadData()
        })
    }
    
    private func loadData() {
        mockList = []
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        for i in (0..<7).reversed() {
            if let newDate = calendar.date(byAdding: .day, value: -(i * 7), to: startOfWeek) {
                withAnimation(.easeIn) {
                    mockList.append(WeeklyAverage(avgValue: 10, week: newDate))
                }
            }
        }
        
        sleep(UInt32(0.5))
        
        for i in 0..<mockList.count {
           DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
               withAnimation(.easeIn(duration: 0.25)) {
                   mockList[i].avgValue = Double.random(in: 50...100)
               }
           }
       }
    }
    
    private func calculateHeight(input: Double) -> Double {
        // Definiere die Mindest- und Maximalhöhe
        let minHeight: Double = 0
        let maxHeight: Double = 200

        // Normalisiere den Eingabewert auf den Bereich 0 bis 300
        let normalizedHeight = (input / 100) * maxHeight

        // Stelle sicher, dass die Höhe innerhalb des Bereichs 0 bis 300 bleibt
        return min(maxHeight, max(minHeight, normalizedHeight))
    }
}

#Preview {
    HomeWeightMockCard()
        .padding(.horizontal, 10)
}
