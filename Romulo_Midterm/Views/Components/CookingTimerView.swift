//
//  CookingTimerView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/20/26.
//

import SwiftUI
import Combine

struct CookingTimerView: View {
    let totalSeconds: Int
    @State private var remaining: Int
    @State private var isRunning = false
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(minutes: Int) {
        let seconds = max(minutes, 1) * 60
        totalSeconds = seconds
        _remaining = State(initialValue: seconds)
    }

    private var timeText: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "timer")
                .foregroundStyle(.orange)

            Text(timeText)
                .font(.title2.monospacedDigit().bold())

            Spacer()

            Button(isRunning ? "Pause" : "Start") {
                if remaining == 0 {
                    remaining = totalSeconds
                }
                isRunning.toggle()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Button("Reset") {
                isRunning = false
                remaining = totalSeconds
            }
            .buttonStyle(.bordered)
        }
        .onReceive(ticker) { _ in
            guard isRunning else { return }
            if remaining > 0 {
                remaining -= 1
            }
            if remaining == 0 {
                isRunning = false
            }
        }
    }
}

#Preview {
    CookingTimerView(minutes: 1)
        .padding()
}
