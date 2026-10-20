//
//  HistoryView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/20/26.
//
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var controller: RecipeController

    var body: some View {
        NavigationStack {
            Group {
                if controller.cookingLogs.isEmpty {
                    ContentUnavailableView(
                        "No cooking history yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Tap \"I cooked this\" on a recipe to log it here.")
                    )
                } else {
                    List {
                        Section("\(controller.cookingLogs.count) meals cooked") {
                            ForEach(controller.cookingLogs, id: \.id) { log in
                                HStack(spacing: 12) {
                                    RecipeImageView(
                                        imageData: log.recipe?.imageData,
                                        symbol: log.recipe?.imageName ?? "fork.knife.circle.fill",
                                        width: 48,
                                        height: 48
                                    )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.recipe?.name ?? "Deleted recipe")
                                            .font(.headline)
                                        Text(log.cookedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        controller.deleteCookingLog(log)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(RecipeController())
}
