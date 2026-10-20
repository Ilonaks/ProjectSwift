//
//  RecipeRowView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 9/10/26.
//
import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    var isGrid: Bool = false

    var body: some View {
        if isGrid {
            gridLayout
        } else {
            listLayout
        }
    }

    private var listLayout: some View {
        HStack(spacing: 12) {
            RecipeImageView(imageData: recipe.imageData, symbol: recipe.imageName, width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)

                HStack(spacing: 6) {
                    Text(recipe.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    difficultyBadge
                }

                HStack(spacing: 10) {
                    Label(recipe.cookingTimeLabel, systemImage: "clock")
                    Label(recipe.ratingLabel, systemImage: "star.fill")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private var gridLayout: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                RecipeImageView(imageData: recipe.imageData, symbol: recipe.imageName, height: 100)

                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .padding(5)
                        .background(.white.opacity(0.85), in: Circle())
                        .padding(6)
                }
            }

            Text(recipe.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            difficultyBadge

            HStack(spacing: 10) {
                Label(recipe.cookingTimeLabel, systemImage: "clock")
                Label(recipe.ratingLabel, systemImage: "star.fill")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private var difficultyBadge: some View {
        Text(recipe.difficulty.rawValue)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(difficultyColor.opacity(0.15))
            .foregroundStyle(difficultyColor)
            .clipShape(Capsule())
    }

    private var difficultyColor: Color {
        switch recipe.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

#Preview {
    RecipeRowView(
        recipe: Recipe(
            name: "Chicken Adobo",
            category: "Main Dish",
            difficulty: .easy,
            cookingTimeMinutes: 45,
            rating: 4.5,
            ingredients: [],
            steps: [],
            isFavorite: true
        )
    )
}
