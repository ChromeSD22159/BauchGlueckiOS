//
//  TimerCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

import SwiftUI
import Combine

struct TimerCard: View {
    @EnvironmentObject var services: Services
    @Environment(\.modelContext) var modelContext
    
    @Bindable var timer: CountdownTimer
    @State var remainingTime: Int = 0
    @State var job: AnyCancellable?
    @State var showEditAlert = false
    @State var showDeleteAlert = false
    let theme = Theme.shared
    
    let options = [
        DropDownOption(icon: "pencil", displayText: "Bearbeiten"),
        DropDownOption(icon: "trash", displayText: "Löschen")
    ]
    
    @State private var notificationService = NotificationService.shared
    @State private var isEditSheet = false
    
    var body: some View {
        VStack {
            HStack{
                Text(timer.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(theme.headlineText)
                
                Spacer()
                
                LiveActtivityButton(timer: timer)
                
                DropDownComponent(options: options) { item in
                    if(item.displayText == "Löschen") {
                        if timer.toTimerState != .running {
                            timer.isDeleted = true
                            timer.update()
                        } else {
                            self.showDeleteAlert = true
                        }
                    }
                    if(item.displayText == "Bearbeiten") {
                        if timer.toTimerState != .running {
                            isEditSheet = true
                            remainingTime = timer.duration
                            timer.toTimerState = .notRunning
                            timer.startDate = nil
                            timer.endDate = nil
                        } else {
                            self.showEditAlert = true
                        }
                    }
                }
                .alert(isPresented: $showEditAlert) {
                    Alert(title: Text("Timer ist Aktive"), message: Text("Bitte stoppe den Timer, um ihn zu bearbeiten."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("Timer ist Aktive"), message: Text("Bitte stoppe den Timer, um ihn zu löschen."), dismissButton: .default(Text("OK")))
                }
            }
            HStack{

                HStack {
                    
                    switch(timer.toTimerState) {
                        case .notRunning:
                        
                        TimerControlButton(icon: "play.fill") {
                            start()
                        }
                            
                        case .running: HStack {
                            TimerControlButton(icon: "pause.fill") {
                                pause()
                            }
                            TimerControlButton(icon: "stop.fill") {
                                stop()
                            }
                        }
                        case .paused: HStack {
                            TimerControlButton(icon: "play.fill") {
                                resume()
                            }
                            TimerControlButton(icon: "stop.fill") {
                                stop()
                            }
                        }
                        case .completed: TimerControlButton(icon: "arrow.circlepath") {
                            reset()
                        }
                    }
                    
                }
                
                Spacer()
                
                Text(remainingTime.toTimeString())
                    .id(remainingTime)
                    .font(theme.headlineText(size: 50))
            }
        }
        .padding(theme.padding)
        .sectionShadow()
        .onAppear { setupInitialTimerState() }
        .onChange(of: timer.duration, {
            remainingTime = timer.duration
        })
        .onChange(of: timer.updatedAtOnDevice, {
            services.countdownService.sendUpdatedTimerToBackend()
            
            services.countdownService.fetchTimerFromBackend()
        })
        .sheet(isPresented: $isEditSheet, onDismiss: {}, content: {
            let config = AppConfig.shared.timerConfig 
            EditTimerSheetContent(
                timer: timer,
                durationRange: config.durationRange,
                stepsEach: config.stepsEach,
                steps: config.stepsInSeconds
            )
            .presentationDragIndicator(.visible)
        })
    }
    
    private func setupInitialTimerState() {
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
    
    func start() {
        let currentTime = Date().timeIntervalSince1970Milliseconds
        remainingTime = timer.duration
        timer.startDate = currentTime
        timer.endDate = currentTime + Int64(timer.duration * 1000)
        timer.timerState = TimerState.running.rawValue
        timer.update()
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
        timer.update()
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
        timer.update()
        job?.cancel()
        
        Task {
            await notificationService.liveActivityEnd()
            notificationService.removeTimerNotification(withIdentifier: timer.id)
        }
    }
    
    func pause() {
        timer.timerState = TimerState.paused.rawValue
        timer.update()
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
        timer.update()
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
        timer.toTimerState = TimerState.completed
        timer.update()
        job?.cancel()
    }
}


@ViewBuilder func LiveActtivityButton(
    theme: Theme = Theme.shared,
    @Bindable timer: CountdownTimer
) -> some View {
    Button(action: {
        timer.showActivity = !timer.showActivity
        timer.update()
    }, label: {
        Image(systemName: timer.showActivity ? "bolt" : "bolt.slash")
        
        Text("Live Activity").font(.caption)
    })
    .foregroundStyle(theme.primary)
    .padding(theme.padding)
    .overlay(
        RoundedRectangle(cornerRadius: theme.padding)
            .stroke(theme.primary, lineWidth: 1)
    )
}
