import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var imageName: String
    @Attribute(.externalStorage) var imageData: Data?
    var difficulty: Difficulty
    var cookingTimeMinutes: Int
    var rating: Double
    var baseServings: Int
    var ingredients: [RecipeIngredient]
    var steps: [String]
    var notes: String
    var isFavorite: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CookingLog.recipe) var cookingLogs: [CookingLog] = []

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        imageName: String = "fork.knife.circle.fill",
        imageData: Data? = nil,
        difficulty: Difficulty,
        cookingTimeMinutes: Int,
        rating: Double = 0,
        baseServings: Int = 4,
        ingredients: [RecipeIngredient],
        steps: [String],
        notes: String = "",
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.imageName = imageName
        self.imageData = imageData
        self.difficulty = difficulty
        self.cookingTimeMinutes = cookingTimeMinutes
        self.rating = rating
        self.baseServings = baseServings
        self.ingredients = ingredients
        self.steps = steps
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    var cookingTimeLabel: String {
        "\(cookingTimeMinutes) mins"
    }

    var ratingLabel: String {
        rating > 0 ? String(format: "%.1f", rating) : "New"
    }
}

struct RecipeDraft {
    var name: String
    var category: String
    var difficulty: Difficulty
    var cookingTimeMinutes: Int
    var baseServings: Int
    var ingredients: [RecipeIngredient]
    var steps: [String]
    var notes: String
    var imageData: Data?
}

nonisolated enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }
}

nonisolated struct RecipeIngredient: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: String

    init(id: UUID = UUID(), name: String, amount: Double, unit: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }

    func displayText(scaledBy ratio: Double) -> String {
        let scaled = amount * ratio
        let amountText: String
        if scaled.truncatingRemainder(dividingBy: 1) == 0 {
            amountText = String(Int(scaled.rounded()))
        } else {
            amountText = String(format: "%.1f", scaled)
        }
        let unitText = unit.isEmpty ? "" : " \(unit)"
        return "\(amountText)\(unitText) \(name)"
    }
}
