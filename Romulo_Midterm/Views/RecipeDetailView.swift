//
//  RecipeDetailView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 9/10/26.
//
import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var controller: RecipeController
    @Environment(\.dismiss) private var dismiss
    let recipeId: UUID

    @State private var selectedServings: Int?
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingShoppingAlert = false
    @State private var showingCookedAlert = false
    @State private var addedCount = 0

    private var recipe: Recipe? {
        controller.recipe(withId: recipeId)
    }

    var body: some View {
        ScrollView {
            if let recipe {
                let servings = selectedServings ?? recipe.baseServings
                let ratio = Double(servings) / Double(max(recipe.baseServings, 1))

                VStack(alignment: .leading, spacing: 16) {
                    RecipeImageView(imageData: recipe.imageData, symbol: recipe.imageName, height: 200)

                    Text(recipe.name)
                        .font(.largeTitle.bold())

                    HStack(spacing: 10) {
                        Text(recipe.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(recipe.difficulty.rawValue, systemImage: "flame")
                        Label(recipe.cookingTimeLabel, systemImage: "clock")
                        Label(recipe.ratingLabel, systemImage: "star.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if !recipe.cookingLogs.isEmpty {
                        Label(cookedSummary(for: recipe), systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Divider()

                    HStack {
                        Text("Servings")
                            .font(.title2.bold())
                        Spacer()
                        Stepper(value: Binding(
                            get: { servings },
                            set: { selectedServings = $0 }
                        ), in: 1...20) {
                            Text("\(servings)")
                                .font(.headline)
                                .frame(minWidth: 24)
                        }
                        .fixedSize()
                    }

                    Text("Ingredients")
                        .font(.title2.bold())
                    ForEach(recipe.ingredients) { ingredient in
                        Label(ingredient.displayText(scaledBy: ratio), systemImage: "circle.fill")
                            .labelStyle(BulletLabelStyle())
                    }

                    Button {
                        addedCount = controller.addIngredientsToShoppingList(from: recipe, servings: servings)
                        showingShoppingAlert = true
                    } label: {
                        Label("Add to shopping list", systemImage: "cart.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Divider()

                    Text("Steps")
                        .font(.title2.bold())
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                    }

                    if !recipe.notes.isEmpty {
                        Divider()
                        Text("Chef's notes")
                            .font(.title2.bold())
                        Text(recipe.notes)
                            .font(.callout)
                            .italic()
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    Text("Cooking timer")
                        .font(.title2.bold())
                    CookingTimerView(minutes: recipe.cookingTimeMinutes)
                        .id(recipe.cookingTimeMinutes)

                    Button {
                        controller.logCooked(recipe)
                        showingCookedAlert = true
                    } label: {
                        Label("I cooked this", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    Divider()

                    Text("Rate this recipe")
                        .font(.title2.bold())
                    HStack(spacing: 6) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: starSymbol(star, rating: recipe.rating))
                                .font(.title2)
                                .foregroundStyle(.orange)
                                .onTapGesture {
                                    controller.setRating(Double(star), for: recipe)
                                }
                        }
                        Spacer()
                        Text(recipe.ratingLabel)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Button("Edit") {
                            showingEditSheet = true
                        }
                        .buttonStyle(.bordered)

                        Button("Delete", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top)
                }
                .padding()
            } else {
                Text("Recipe not found.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationTitle(recipe?.name ?? "Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let recipe {
                    ShareLink(item: shareText(for: recipe))
                    Button {
                        controller.toggleFavorite(for: recipe)
                    } label: {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let recipe {
                AddEditRecipeView(recipeToEdit: recipe)
            }
        }
        .confirmationDialog("Delete this recipe?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let recipe {
                    controller.deleteRecipe(recipe)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Shopping list", isPresented: $showingShoppingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(addedCount > 0 ? "\(addedCount) item(s) added to your shopping list." : "These ingredients are already on your list.")
        }
        .alert("Nice cooking!", isPresented: $showingCookedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Saved to your cooking history.")
        }
    }

    private func cookedSummary(for recipe: Recipe) -> String {
        let count = recipe.cookingLogs.count
        let last = recipe.cookingLogs.map(\.cookedAt).max() ?? Date()
        let lastText = last.formatted(date: .abbreviated, time: .omitted)
        return "Cooked \(count)x · Last: \(lastText)"
    }

    private func starSymbol(_ star: Int, rating: Double) -> String {
        if rating >= Double(star) { return "star.fill" }
        if rating >= Double(star) - 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }

    private func shareText(for recipe: Recipe) -> String {
        let ingredients = recipe.ingredients
            .map { "• " + $0.displayText(scaledBy: 1) }
            .joined(separator: "\n")
        let steps = recipe.steps.enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
        return "\(recipe.name) — shared from Kusina Ko\n\nIngredients:\n\(ingredients)\n\nSteps:\n\(steps)"
    }
}

struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 8) {
            configuration.icon
                .font(.system(size: 6))
                .padding(.top, 6)
            configuration.title
        }
    }
}

#Preview {
    let controller = RecipeController()
    return NavigationStack {
        RecipeDetailView(recipeId: controller.recipes[0].id)
            .environmentObject(controller)
    }
}
