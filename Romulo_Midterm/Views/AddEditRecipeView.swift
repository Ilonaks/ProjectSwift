//
//  AddEditRecipeView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/8/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddEditRecipeView: View {
    @EnvironmentObject var controller: RecipeController
    @Environment(\.dismiss) private var dismiss

    var recipeToEdit: Recipe?

    @State private var name = ""
    @State private var category = ""
    @State private var cookingTime = ""
    @State private var servings = 4
    @State private var difficulty: Difficulty = .easy
    @State private var ingredientsText = ""
    @State private var stepsText = ""
    @State private var notes = ""
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    private var isEditing: Bool { recipeToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if let imageData {
                        RecipeImageView(imageData: imageData, height: 160)
                    }

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(imageData == nil ? "Choose photo" : "Change photo", systemImage: "photo")
                    }

                    if imageData != nil {
                        Button("Remove photo", role: .destructive) {
                            imageData = nil
                            selectedPhoto = nil
                        }
                    }
                }

                Section("Recipe Info") {
                    TextField("Recipe name", text: $name)
                    TextField("Category (e.g. Main Dish)", text: $category)
                    TextField("Cooking time (e.g. 30 mins)", text: $cookingTime)
                }

                Section("Servings") {
                    Stepper("Serves \(servings)", value: $servings, in: 1...20)
                }

                Section("Difficulty") {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Ingredients") {
                    TextEditor(text: $ingredientsText)
                        .frame(height: 100)
                    Text("One per line, e.g. \"1 kg chicken\" or \"6 garlic cloves\".")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Steps") {
                    TextEditor(text: $stepsText)
                        .frame(height: 100)
                    Text("Separate each step with a new line.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Chef's notes (optional)") {
                    TextField("e.g. Add extra garlic for more flavor", text: $notes)
                }
            }
            .navigationTitle(isEditing ? "Edit Recipe" : "Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: populateFieldsIfEditing)
            .onChange(of: selectedPhoto) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let jpeg = image.jpegData(compressionQuality: 0.7) {
                        imageData = jpeg
                    }
                }
            }
        }
    }

    private func populateFieldsIfEditing() {
        guard let recipe = recipeToEdit, name.isEmpty else { return }
        name = recipe.name
        category = recipe.category
        cookingTime = recipe.cookingTimeLabel
        servings = recipe.baseServings
        difficulty = recipe.difficulty
        ingredientsText = recipe.ingredients
            .map { ingredient -> String in
                let unitPart = ingredient.unit.isEmpty ? "" : " \(ingredient.unit)"
                return "\(formattedAmount(ingredient.amount))\(unitPart) \(ingredient.name)"
            }
            .joined(separator: "\n")
        stepsText = recipe.steps.joined(separator: "\n")
        notes = recipe.notes
        imageData = recipe.imageData
    }

    private func saveRecipe() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        let draft = RecipeDraft(
            name: trimmedName,
            category: trimmedCategory.isEmpty ? "Uncategorized" : trimmedCategory,
            difficulty: difficulty,
            cookingTimeMinutes: parseMinutes(from: cookingTime),
            baseServings: servings,
            ingredients: parseIngredients(from: ingredientsText),
            steps: parseLines(from: stepsText),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: imageData
        )

        if let recipeToEdit {
            controller.updateRecipe(recipeToEdit, from: draft)
        } else {
            controller.addRecipe(from: draft)
        }
        dismiss()
    }

    private func parseLines(from text: String) -> [String] {
        text.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func parseMinutes(from text: String) -> Int {
        let digits = text.filter { $0.isNumber }
        let value = Int(digits) ?? 30
        return value > 0 ? value : 30
    }

    private func parseIngredients(from text: String) -> [RecipeIngredient] {
        let knownUnits: Set<String> = ["kg", "g", "cup", "cups", "tbsp", "tsp", "pack", "pcs", "pc", "can", "bunch", "ml", "l"]

        return parseLines(from: text).map { line -> RecipeIngredient in
            let parts = line.split(separator: " ").map(String.init)

            guard let first = parts.first, let amount = Double(first), parts.count > 1 else {
                return RecipeIngredient(name: line, amount: 1, unit: "")
            }

            if parts.count > 2, knownUnits.contains(parts[1].lowercased()) {
                let unit = parts[1]
                let name = parts[2...].joined(separator: " ")
                return RecipeIngredient(name: name, amount: amount, unit: unit)
            } else {
                let name = parts[1...].joined(separator: " ")
                return RecipeIngredient(name: name, amount: amount, unit: "")
            }
        }
    }

    private func formattedAmount(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(format: "%.2f", value)
    }
}

#Preview {
    AddEditRecipeView()
        .environmentObject(RecipeController())
}
