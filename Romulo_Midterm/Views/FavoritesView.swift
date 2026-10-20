//
//  FavoritesView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/8/26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var controller: RecipeController

    var body: some View {
        NavigationStack {
            Group {
                if controller.favoriteRecipes.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "heart",
                        description: Text("Tap the heart icon on a recipe to add it here.")
                    )
                } else if controller.isGridView {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(controller.favoriteRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                                    RecipeRowView(recipe: recipe, isGrid: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                } else {
                    List(controller.favoriteRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(RecipeController())
}
