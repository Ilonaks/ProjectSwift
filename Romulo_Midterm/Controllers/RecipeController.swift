//
//  RecipeController.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 9/10/26.
//
import Foundation
import Combine
import SwiftData

@MainActor
final class RecipeController: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var cookingLogs: [CookingLog] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var sortOption: SortOption = .name
    @Published var isGridView: Bool = false

    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private static let seededKey = "kusinako_seeded_swiftdata"

    init(container: ModelContainer, seedOnce: Bool = true) {
        self.container = container
        if !seedOnce || !UserDefaults.standard.bool(forKey: Self.seededKey) {
            for recipe in sampleRecipes() {
                context.insert(recipe)
            }
            saveContext()
            if seedOnce {
                UserDefaults.standard.set(true, forKey: Self.seededKey)
            }
        }
        fetchRecipes()
        fetchShoppingItems()
        fetchCookingLogs()
    }

    convenience init() {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Recipe.self, CookingLog.self, ShoppingItem.self,
            configurations: configuration
        )
        self.init(container: container, seedOnce: false)
    }

    var categories: [String] {
        ["All"] + Set(recipes.map { $0.category }).sorted()
    }

    var filteredRecipes: [Recipe] {
        var result = recipes

        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch sortOption {
        case .name:
            result.sort { $0.name < $1.name }
        case .rating:
            result.sort { $0.rating > $1.rating }
        case .cookingTime:
            result.sort { $0.cookingTimeMinutes < $1.cookingTimeMinutes }
        }

        return result
    }

    var favoriteRecipes: [Recipe] {
        recipes.filter { $0.isFavorite }
    }

    func recipe(withId id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }

    func toggleFavorite(for recipe: Recipe) {
        recipe.isFavorite.toggle()
        saveContext()
    }

    func setRating(_ rating: Double, for recipe: Recipe) {
        recipe.rating = rating
        saveContext()
    }

    func addRecipe(from draft: RecipeDraft) {
        let recipe = Recipe(
            name: draft.name,
            category: draft.category,
            imageData: draft.imageData,
            difficulty: draft.difficulty,
            cookingTimeMinutes: draft.cookingTimeMinutes,
            baseServings: draft.baseServings,
            ingredients: draft.ingredients,
            steps: draft.steps,
            notes: draft.notes
        )
        context.insert(recipe)
        saveContext()
        fetchRecipes()
    }

    func updateRecipe(_ recipe: Recipe, from draft: RecipeDraft) {
        recipe.name = draft.name
        recipe.category = draft.category
        recipe.difficulty = draft.difficulty
        recipe.cookingTimeMinutes = draft.cookingTimeMinutes
        recipe.baseServings = draft.baseServings
        recipe.ingredients = draft.ingredients
        recipe.steps = draft.steps
        recipe.notes = draft.notes
        recipe.imageData = draft.imageData
        saveContext()
        fetchRecipes()
    }

    func deleteRecipe(_ recipe: Recipe) {
        context.delete(recipe)
        saveContext()
        fetchRecipes()
        fetchCookingLogs()
    }

    func fetchRecipes() {
        let descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.createdAt)])
        recipes = (try? context.fetch(descriptor)) ?? []
        if !categories.contains(selectedCategory) {
            selectedCategory = "All"
        }
    }

    func fetchShoppingItems() {
        let descriptor = FetchDescriptor<ShoppingItem>(sortBy: [SortDescriptor(\.createdAt)])
        shoppingItems = (try? context.fetch(descriptor)) ?? []
    }

    func fetchCookingLogs() {
        let descriptor = FetchDescriptor<CookingLog>(sortBy: [SortDescriptor(\.cookedAt, order: .reverse)])
        cookingLogs = (try? context.fetch(descriptor)) ?? []
    }

    @discardableResult
    func addIngredientsToShoppingList(from recipe: Recipe, servings: Int) -> Int {
        let ratio = Double(servings) / Double(max(recipe.baseServings, 1))
        var added = 0

        for ingredient in recipe.ingredients {
            let text = ingredient.displayText(scaledBy: ratio)
            let alreadyListed = shoppingItems.contains {
                !$0.isChecked && $0.name.caseInsensitiveCompare(text) == .orderedSame
            }
            if alreadyListed { continue }

            context.insert(ShoppingItem(name: text, recipeName: recipe.name))
            added += 1
        }

        saveContext()
        fetchShoppingItems()
        return added
    }

    func addShoppingItem(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        context.insert(ShoppingItem(name: trimmed))
        saveContext()
        fetchShoppingItems()
    }

    func toggleShoppingItem(_ item: ShoppingItem) {
        item.isChecked.toggle()
        saveContext()
    }

    func deleteShoppingItem(_ item: ShoppingItem) {
        context.delete(item)
        saveContext()
        fetchShoppingItems()
    }

    func clearCheckedShoppingItems() {
        for item in shoppingItems where item.isChecked {
            context.delete(item)
        }
        saveContext()
        fetchShoppingItems()
    }

    func logCooked(_ recipe: Recipe) {
        let log = CookingLog()
        context.insert(log)
        log.recipe = recipe
        saveContext()
        fetchCookingLogs()
    }

    func deleteCookingLog(_ log: CookingLog) {
        context.delete(log)
        saveContext()
        fetchCookingLogs()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func sampleRecipes() -> [Recipe] {
        [
            Recipe(
                name: "Chicken Adobo",
                category: "Main Dish",
                imageName: "fork.knife.circle.fill",
                difficulty: .easy,
                cookingTimeMinutes: 45,
                rating: 4.5,
                baseServings: 4,
                ingredients: [
                    RecipeIngredient(name: "chicken", amount: 1, unit: "kg"),
                    RecipeIngredient(name: "soy sauce", amount: 0.5, unit: "cup"),
                    RecipeIngredient(name: "vinegar", amount: 0.25, unit: "cup"),
                    RecipeIngredient(name: "garlic cloves", amount: 6, unit: ""),
                    RecipeIngredient(name: "bay leaves", amount: 2, unit: ""),
                    RecipeIngredient(name: "peppercorns", amount: 1, unit: "tsp")
                ],
                steps: ["Combine all ingredients in a pot.", "Marinate for 30 minutes.", "Simmer for 30–40 minutes until tender.", "Serve hot with rice."],
                notes: "Add extra garlic for more flavor, and let it marinate longer if you have time."
            ),
            Recipe(
                name: "Sinigang na Baboy",
                category: "Soup",
                imageName: "flame.circle.fill",
                difficulty: .medium,
                cookingTimeMinutes: 60,
                rating: 4.8,
                baseServings: 6,
                ingredients: [
                    RecipeIngredient(name: "pork ribs", amount: 1, unit: "kg"),
                    RecipeIngredient(name: "sinigang mix", amount: 1, unit: "pack"),
                    RecipeIngredient(name: "kangkong", amount: 1, unit: "bunch"),
                    RecipeIngredient(name: "radish", amount: 1, unit: "pc"),
                    RecipeIngredient(name: "tomatoes", amount: 2, unit: "pcs"),
                    RecipeIngredient(name: "onion", amount: 1, unit: "pc")
                ],
                steps: ["Boil pork until tender.", "Add vegetables.", "Add sinigang mix.", "Simmer and serve."],
                notes: "Adjust the sourness by adding more or less sinigang mix to taste."
            ),
            Recipe(
                name: "Pancit Canton",
                category: "Noodles",
                imageName: "takeoutbag.and.cup.and.straw.fill",
                difficulty: .easy,
                cookingTimeMinutes: 30,
                rating: 4.2,
                baseServings: 4,
                ingredients: [
                    RecipeIngredient(name: "canton noodles", amount: 1, unit: "pack"),
                    RecipeIngredient(name: "cabbage", amount: 1, unit: "cup"),
                    RecipeIngredient(name: "carrots", amount: 1, unit: "cup"),
                    RecipeIngredient(name: "chicken breast", amount: 0.5, unit: "kg"),
                    RecipeIngredient(name: "soy sauce", amount: 3, unit: "tbsp"),
                    RecipeIngredient(name: "oyster sauce", amount: 2, unit: "tbsp")
                ],
                steps: ["Sauté chicken and vegetables.", "Add sauces and broth.", "Add noodles and toss.", "Serve with calamansi."],
                notes: "Don't overcook the noodles — add them last so they stay firm."
            ),
            Recipe(
                name: "Leche Flan",
                category: "Dessert",
                imageName: "birthday.cake.fill",
                difficulty: .medium,
                cookingTimeMinutes: 75,
                rating: 4.9,
                baseServings: 8,
                ingredients: [
                    RecipeIngredient(name: "egg yolks", amount: 10, unit: ""),
                    RecipeIngredient(name: "condensed milk", amount: 1, unit: "can"),
                    RecipeIngredient(name: "evaporated milk", amount: 1, unit: "can"),
                    RecipeIngredient(name: "sugar", amount: 1, unit: "cup")
                ],
                steps: ["Caramelize sugar in a llanera.", "Mix remaining ingredients.", "Pour over caramel.", "Steam for 45 minutes."],
                notes: "Strain the egg mixture for an extra-smooth texture."
            )
        ]
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case rating = "Rating"
    case cookingTime = "Cooking time"

    var id: String { rawValue }
}
