//
//  HomeCountdownTimerWidgetCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//
import SwiftUI
import SwiftData

struct HomeCountdownTimerWidgetCard: View {
    @Query var timers: [CountdownTimer]
    let theme: Theme = Theme()

    var body: some View {
        VStack(alignment: .leading) {
            Label("Timer", systemImage: "gauge.with.dots.needle.33percent")
                .font(.caption)
                .padding(.horizontal, 15)
                .offset(y: 5)
        
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(timers.enumerated()), id: \.offset) { index, timer in
                        if timers.count > 0 {
                            VStack {
                                Text(timer.duration.toTimeString())
                                    .font(theme.headlineText)
                                Text(timer.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(.footnote)
                            }
                            .frame(width: 100, height: 80, alignment: .center)
                            .background(theme.surface)
                            .cornerRadius(theme.radius)
                            .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
                            .padding(.leading, index == 0 ? 10 : 0)
                        } else {
                            
                        }
                    }
                    
                    if timers.count > 0 {
                        VStack {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 100, height: 80, alignment: .center)
                        .background(theme.backgroundGradient)
                        .cornerRadius(theme.radius)
                        .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
                        .padding(.trailing, 10)
                    } else {
                        VStack {
                            Text("Noch keinen Timer!").font(.footnote)
                            Text("Trage dein ersten Timer ein.")    .font(.footnote)
                        }
                        .frame(width: 200, height: 80, alignment: .center)
                        .background(theme.surface)
                        .cornerRadius(theme.radius)
                        .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
                        .padding(.trailing, 10)
                    }
                }.frame(height: 100)
            }
        }.foregroundStyle(theme.onBackground)
    }
}

extension Int {
    // Converts seconds to a string in the format "HH:MM:SS"
    func toTimeString() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
