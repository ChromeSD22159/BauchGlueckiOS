//
//  TimerScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

struct TimerScreen: View {
    private let theme: Theme = Theme.shared
    
    let firebase: FirebaseService
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \CountdownTimer.name, order: .reverse) var countdownTimers: [CountdownTimer]

    var body: some View {
        ScreenHolder(firebase: firebase) {
            VStack(spacing: theme.padding) {
                
                let groupedTimers = Dictionary(grouping: countdownTimers) { $0.name }
                let sortedTimers = groupedTimers.sorted { $0.key > $1.key }.flatMap { $0.value.sorted(by: { $0.name < $1.name }) }
                
                ForEach(sortedTimers) { timer in
                    @Bindable var currentTimer = timer
                    TimerCard(timer: currentTimer)
                }
            }.padding(.horizontal, theme.padding)
        }
    }
}


struct TimerCard: View {
    @Bindable var timer: CountdownTimer
    @State var remainingTime: Int = 0
    @State var job: AnyCancellable?
    
    let theme = Theme.shared
    
    let options = [
        DropDownOption(icon: "pencil", displayText: "Bearbeiten"),
        DropDownOption(icon: "trash", displayText: "Löschen")
    ]
    
    @State private var notificationService = NotificationService.shared
    
    var body: some View {
        VStack {
            HStack{
                Text(timer.name)
                    .font(theme.headlineText)
                
                Spacer()
                
                DropDownComponent(options: options) { item in
                    if(item.displayText == "Löschen") {}
                    if(item.displayText == "Bearbeiten") {}
                }
            }
            HStack{

                HStack {
                    
                    switch(timer.toTimerState) {
                        case .notRunning:
                        
                        ControlButton(icon: "play.fill") {
                            start()
                        }
                            
                        case .running: HStack {
                            ControlButton(icon: "pause.fill") {
                                pause()
                            }
                            ControlButton(icon: "stop.fill") {
                                stop()
                            }
                        }
                        case .paused: HStack {
                            ControlButton(icon: "play.fill") {
                                resume()
                            }
                            ControlButton(icon: "stop.fill") {
                                stop()
                            }
                        }
                        case .completed: ControlButton(icon: "arrow.circlepath") {
                            reset()
                        }
                    }
                    
                }
                
                Spacer()
                
                Text(remainingTime.toTimeString())
                    .font(theme.headlineText(size: 50))
            }
        }
        .padding(theme.padding)
        .sectionShadow()
        .onAppear {
            let currentTime = Date().timeIntervalSince1970Milliseconds
            
            switch (timer.toTimerState) {
                case .running:
                    if let endDate = timer.endDate, endDate >= currentTime {
                        remainingTime = Int((endDate - currentTime) / 1000)
                        self.startTicking()
                    } else {
                        self.completeInternal()
                    }
                case .paused:
                    if let endDate = timer.endDate, endDate >= currentTime {
                        remainingTime = Int((endDate - currentTime) / 1000)
                    }
                case .completed:
                    remainingTime = 0
                case .notRunning:
                    remainingTime = timer.duration
            }
        }
    }
    
    func start() {
        let currentTime = Date().timeIntervalSince1970Milliseconds
        remainingTime = timer.duration // secunden
        timer.startDate = currentTime
        timer.endDate = currentTime + Int64(timer.duration * 1000)
        timer.timerState = TimerState.running.rawValue
        
        startTicking()
        

        notificationService.sendTimerNotification(
            countdown: timer,
            timeStamp: currentTime + Int64(timer.duration * 1000)
        )
        
        Task {
            await notificationService.liveActivityStart(withTimer: timer, remainingDuration: remainingTime)
        }
    }
    
    func resume() {
        let currentTime = Date().timeIntervalSince1970Milliseconds

        timer.startDate = currentTime
        timer.endDate = currentTime + Int64(remainingTime)
        timer.timerState = TimerState.running.rawValue
        
        startTicking()
        
        notificationService.sendTimerNotification(
            countdown: timer,
            timeStamp: currentTime + Int64((remainingTime))
        )
    }
    
    func stop() {
       
        remainingTime = timer.duration
        timer.startDate = nil
        timer.endDate = nil
        timer.timerState = TimerState.notRunning.rawValue
        
        job?.cancel()
        
        Task {
            await notificationService.liveActivityEnd()
            notificationService.removeTimerNotification(withIdentifier: timer.id)
        }
    }
    
    func pause() {
        timer.timerState = TimerState.paused.rawValue
        job?.cancel()
        
        Task {
            await notificationService.liveActivityUpdate(timer: timer, remainingDuration: remainingTime)
            notificationService.removeTimerNotification(withIdentifier: timer.id)
        }
    }
    
    func reset() {
        timer.startDate = nil
        timer.endDate = nil
        remainingTime = timer.duration
        timer.timerState = TimerState.notRunning.rawValue

        job?.cancel()
    }
    
    private func startTicking() {
        self.job?.cancel()
        
        self.job = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { time in
                
                remainingTime -= 1
                
                if remainingTime <= 0 {
                   completeInternal()
                }
            }
    }
    
    private func completeInternal() {
        job?.cancel()
    }
}

@ViewBuilder func ControlButton(
    icon: String,
    onClick: @escaping () -> Void = {}
) -> some View {
    let theme = Theme.shared
    Button(
        action: {
            onClick()
        }, label: {
            Image(systemName: icon)
                .foregroundStyle(theme.onPrimary)
        }
    )
    .padding(theme.padding)
    .background(theme.backgroundGradient)
    .cornerRadius(100)
}
