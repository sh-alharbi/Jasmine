//
//  NotificationManager.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 12/7/25.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("🔴 Notification permission error:", error.localizedDescription)
            return false
        }
    }

    func scheduleRoutineReminder() {
        let center = UNUserNotificationCenter.current()

        center.removePendingNotificationRequests(withIdentifiers: ["routine_reminder_12h"])

        let content = UNMutableNotificationContent()
        content.title = "Don’t forget your skincare routine !"
        content.body  = "Take a moment to complete your skin routine today."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 12 * 60 * 60,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "routine_reminder_12h",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("🔴 Failed to schedule reminder:", error.localizedDescription)
            } else {
                print("✅ 12h routine reminder scheduled")
            }
        }
    }

    func cancelRoutineReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["routine_reminder_12h"])
        print("⚪️ Routine reminder cancelled")
    }
}
