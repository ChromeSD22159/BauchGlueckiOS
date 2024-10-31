//
//  HomeWeightMockCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct HomeWeightMockCard: View {
    let theme: Theme = Theme.shared
    
    var gradient = LinearGradient(colors: [
        Theme.shared.primary.opacity(0.55),
        Theme.shared.primary.opacity(0.1)
    ], startPoint: .top, endPoint: .bottom)
    
    @State var mockList: [WeeklyAverage] = []
    
    let aufsteigend = true
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: aufsteigend ? "arrow.up.forward.circle.fill" : "arrow.down.forward.circle.fill")
                
                Text(aufsteigend ? "Aufsteigender" : "Absteigender" + " Trend")
                    .font(.footnote)
                 
                Spacer()
            }   .foregroundStyle(theme.onBackground)
            
            HStack(alignment: .bottom, spacing: 15) {
                ForEach(mockList, id: \.week) { week in
                    VStack(spacing: 15) {
                        Spacer()
                        
                        HStack(alignment: .bottom) {
                            Capsule()
                                .frame(width: 25, height: calculateHeight(input: week.avgValue) )
                                .foregroundStyle(theme.primary)
                        }
                        
                        HStack(alignment: .bottom) {
                            Text(DateRepository.formatDateDDMM(date: week.week))
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(theme.onBackground)
                                .rotationEffect(Angle(degrees: -90))
                        }
                        .frame(height: 40)
                    }
                }
            }
            .frame(height: 280)
            
            HStack {
                Text("In einigen Tagen siehst du hier deine Statistik")
                    .font(.footnote)
                    .foregroundStyle(theme.onBackground)
            }
        }
        .padding(theme.padding)
        .background(gradient)
        .cornerRadius(theme.radius)
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
