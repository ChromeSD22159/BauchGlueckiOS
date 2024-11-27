//
//  HomeWeightMockCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct HomeWeightMockCard: View {
    @Environment(\.theme) private var theme
    
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
                     
                    FootLineText(isAscendingTrend ? "Aufsteigender" : "Absteigender" + " Trend")
                     
                    Spacer()
                }   .foregroundStyle(theme.color.onBackground)
                
                HStack(alignment: .bottom, spacing: 15) {
                    ForEach(mockList, id: \.week) { week in
                        VStack(spacing: 30) {
                            Spacer()
                            
                            HStack(alignment: .bottom) {
                                Capsule()
                                    .frame(width: 25, height: WeightChartUtil.calculateHeight(input: week.avgValue) )
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
            .background(theme.color.chartBackgroundGradient)
            .cornerRadius(theme.layout.radius)
            
            VStack {
                Text("In einigen Tagen siehst du hier deine Statistik") 
                    .foregroundStyle(theme.color.onBackground)
            }
        }
        .onAppLifeCycle(appearAndActive: {
            mockList = WeightChartUtil.mockChartData()
        })
    } 
}

#Preview {
    HomeWeightMockCard()
        .padding(.horizontal, 10)
}
