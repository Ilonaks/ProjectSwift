//
//  Romulo_MidtermApp.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 9/10/26.
//

import SwiftUI
import SwiftData

@main
struct Romulo_MidtermApp: App {
    @StateObject private var recipeController: RecipeController

    init() {
        do {
            let container = try ModelContainer(for: Recipe.self, CookingLog.self, ShoppingItem.self)
            _recipeController = StateObject(wrappedValue: RecipeController(container: container))
        } catch {
            fatalError("Could not create database: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(recipeController)
        }
    }
}
