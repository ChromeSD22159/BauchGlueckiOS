//
//  WeightChart.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct WeightChart: View { 
    
    @Environment(\.theme) private var theme
    @EnvironmentObject var homeViewModel: HomeViewModel  
    
    var body: some View {
        ZStack {
            
            if homeViewModel.weights.count == 0 {
                HomeWeightMockCard()
                    .padding(.horizontal, theme.layout.padding)
            } else {
                VStack {
                    HStack {
                        Image(systemName: homeViewModel.isAscendingWeightTrend ? "arrow.up.forward.circle.fill" : "arrow.down.forward.circle.fill")
                        
                        Text(homeViewModel.isAscendingWeightTrend ? "Aufsteigender" : "Absteigender" + " Trend")
                            .font(.footnote)
                         
                        Spacer()
                    }
                    .foregroundStyle(theme.color.onBackground)
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(homeViewModel.animatedWeeklyAverage, id: \.week) { week in
                            VStack(spacing: 30) {
                                Spacer()
                                
                                HStack(alignment: .bottom) {
                                    Capsule()
                                        .frame(width: 25, height: WeightChartUtil.calculateHeight(input: week.avgValue) )
                                        .foregroundStyle(theme.color.primary)
                                }
                                
                                HStack(alignment: .bottom) { 
                                    Text(DateFormatteUtil.formatDateDDMM(week.week))
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
                    .opacity(0.5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                }
                .padding(theme.layout.padding)
                .padding(theme.layout.padding)
                .background(theme.color.chartBackgroundGradient)
                .cornerRadius(theme.layout.radius)
                .padding(.horizontal, theme.layout.padding)
                .onAppLifeCycle(appearAndActive: homeViewModel.calculateWeeklyAverage)
            }
        }
        .onAppear {
            homeViewModel.fetchWeights()
        }
    }
}

// TODO: REDACTOR
struct WeightChartUtil {
    static func calculateHeight(input: Double) -> Double {
        // Definiere die Mindest- und Maximalhöhe
        let minHeight: Double = 0
        let maxHeight: Double = 200

        // Normalisiere den Eingabewert auf den Bereich 0 bis 200
        let normalizedHeight = (input / 100) * maxHeight
        
        // Stelle sicher, dass die Höhe innerhalb des Bereichs 0 bis 200 bleibt
        return min(maxHeight, max(minHeight, normalizedHeight))
    }
    
    static func mockChartData() -> [WeeklyAverage] {
        var mockList: [WeeklyAverage] = []
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
        
        return mockList
    }
} 
