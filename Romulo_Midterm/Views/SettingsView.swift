//
//  SettingsView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/8/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }

                Section("Notifications") {
                    Toggle("Daily Recipe Reminder (5:00 PM)", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, isOn in
                            updateReminder(enabled: isOn)
                        }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    Text("Kusina Ko — your simple recipe companion.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func updateReminder(enabled: Bool) {
        Task {
            let center = UNUserNotificationCenter.current()

            guard enabled else {
                center.removePendingNotificationRequests(withIdentifiers: ["dailyRecipeReminder"])
                return
            }

            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            guard granted else {
                notificationsEnabled = false
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Kusina Ko"
            content.body = "What are you cooking today? Pick a recipe!"

            var time = DateComponents()
            time.hour = 17
            time.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyRecipeReminder", content: content, trigger: trigger)
            try? await center.add(request)
        }
    }
}

#Preview {
    SettingsView()
}
