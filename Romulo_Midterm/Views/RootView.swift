//
//  RootView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 9/10/26.
//
import SwiftUI

struct RootView: View {
    @State private var hasSeenWelcome = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some View {
        Group {
            if hasSeenWelcome {
                MainTabView()
            } else {
                WelcomeView {
                    withAnimation {
                        hasSeenWelcome = true
                    }
                }
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : nil)
    }
}

#Preview {
    RootView()
        .environmentObject(RecipeController())
}
