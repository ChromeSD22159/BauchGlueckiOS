//
//  NotificationManager.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

import Foundation
import UserNotifications
import SwiftUI
import ActivityKit

@Observable
class NotificationService {
    static var shared = NotificationService()
    
    var hasPermission = false

    init() {
        Task{
            await getAuthStatus()
        }
    }
    
    func request() async{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await getAuthStatus()
        } catch{
            print(error)
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }

    func requesterNoticication(title: String, subTitle: String, min: Int = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(min * 60), repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleRecurringMedicationNotification(medicationId: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: medicationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling recurring notification: \(error.localizedDescription)")
            } else {
                print("Recurring notification scheduled successfully for medication ID: \(medicationId)")
            }
        }
    }
}

// MARK: - CountdownTimer Notifications
extension NotificationService {
    func sendTimerNotification(countdown: CountdownTimer, timeStamp: Int64) {
        
        let content = UNMutableNotificationContent()
        content.title = "BauchGlück Timer"
        content.body = "Der \(countdown.name) Timer ist beeendet."
        content.sound = UNNotificationSound.default

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: timeStamp.toDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        print("Notification will be triggered at: \(dateComponents)")
        
        let currentTime = Date()
        if let triggerDate = Calendar.current.date(from: dateComponents), triggerDate > currentTime {
            print("Notification scheduled for: \(triggerDate)")
        } else {
            print("The trigger date is in the past.")
        }
        
        let request = UNNotificationRequest(identifier: countdown.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeTimerNotification(countdown: CountdownTimer) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [countdown.id.uuidString])
    }
}

// MARK: - MedicationNotifications
extension NotificationService {
    
    func checkAndUpdateRecurringNotification(forMedication medication: Medication, forIntakeTime intakeTime: IntakeTime) {
        let intakeTimeId = intakeTime.intakeTimeId

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let existingNotification = requests.first { $0.identifier == intakeTimeId }

            if existingNotification != nil {
                // Entferne die bestehende Benachrichtigung
                self.removeRecurringNotification(forIntakeTime: intakeTime)
            }

            // Füge die neue Benachrichtigung hinzu
            self.createRecurringMedicationNotifications(forMedication: medication, forIntakeTime: intakeTime)
        }
    }
    
    func createRecurringMedicationNotifications(forMedication: Medication, forIntakeTime: IntakeTime) {
        if let timeDate = convertHHMMToTimeDate(timeString: forIntakeTime.intakeTime) {
            let hour = Calendar.current.component(.hour, from: timeDate)
            let minute = Calendar.current.component(.minute, from: timeDate)
            
            NotificationService.shared.scheduleRecurringMedicationNotification(
                medicationId: forIntakeTime.intakeTimeId,
                title: "BauchGlück Reminder",
                body: "Erinnerung: \(forMedication.name) sollte jetzt (\(hour):\(minute) Uhr) eingenommen werden.",
                hour: hour,
                minute: minute
            )
            
            print("Created Recurring Notification for \(forIntakeTime.intakeTimeId)")
        }
    }
    
    func removeRecurringNotification(forIntakeTime: IntakeTime) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [forIntakeTime.intakeTimeId])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [forIntakeTime.intakeTimeId])
        
        print("Removed Recurring Notification for \(forIntakeTime.intakeTimeId)")
    }
}

// MARK: - Live Avtivity for CountdownTimer
extension NotificationService {
    func liveActivityStart(withTimer timer: CountdownTimer, remainingDuration: Int) async {
        guard timer.showActivity else { return }
        
        @AppStorage("activityID") var activityID: String = ""
        
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            guard let startDate = timer.startDate, let endDate = timer.endDate else {
                return
            }
            
            let contentState = BGWidgetExtentionAttributes.ContentState(
                state: timer.timerState,
                startDate: startDate.toDate,
                endDate: endDate.toDate,
                remainingDuration: remainingDuration
            )

            let activityAttributes = BGWidgetExtentionAttributes(name: timer.name)
            
            let activityContent = ActivityContent<BGWidgetExtentionAttributes.ContentState>(state: contentState, staleDate: nil)

            do {
                let activity = try Activity<BGWidgetExtentionAttributes>.request(
                    attributes: activityAttributes,
                    content: activityContent,
                    pushType: nil
                )
                
                print("Live Activity registered: \(activity)")
                
                activityID = activity.id
            } catch (let error) {
                print("Error starting Live Activity: \(error.localizedDescription)")
            }
        } else {
            // Handle the case where Live Activities are not enabled on the device.
            // You might want to prompt the user to enable them in Settings.
        }
    }
        
    func liveActivityEnd() async {
        @AppStorage("activityID") var activityID: String = ""
        for activity in Activity<BGWidgetExtentionAttributes>.activities {
            if activity.id == activityID {
                await activity.end(activity.content, dismissalPolicy: .immediate)
                activityID = ""
                
                break // Exit the loop once the activity is found
            }
        }
    }

    func liveActivityUpdate(timer: CountdownTimer, remainingDuration: Int) async {
        @AppStorage("activityID") var activityID: String = ""
        guard let startDate = timer.startDate, let endDate = timer.endDate else {
            return
        }

        let updatedContentState = BGWidgetExtentionAttributes.ContentState(
            state: timer.timerState,
            startDate: startDate.toDate,
            endDate: endDate.toDate,
            remainingDuration: remainingDuration
        )

        let updatedContent = ActivityContent<BGWidgetExtentionAttributes.ContentState>(state: updatedContentState, staleDate: nil) // Update staleDate if needed

        for activity in Activity<BGWidgetExtentionAttributes>.activities {
            if activity.id == activityID {
                await activity.update(updatedContent)
                break
            }
        }
    }
}

func convertHHMMToTimeDate(timeString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = TimeZone.current

    guard let timeDate = dateFormatter.date(from: timeString) else {
        return nil
    }

    // Füge Stunden und Minuten zum heutigen Datum hinzu
    let calendar = Calendar.current
    let currentDate = Date()

    var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
    components.hour = calendar.component(.hour, from: timeDate)
    components.minute = calendar.component(.minute, from: timeDate)

    return calendar.date(from: components)
}
