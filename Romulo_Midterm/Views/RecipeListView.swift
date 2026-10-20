import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject var controller: RecipeController
    @State private var showingAddRecipe = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                categoryChips
                sortAndViewToolbar
                content
            }
            .searchable(text: $controller.searchText, prompt: "Search recipes")
            .navigationTitle("Kusina Ko")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddRecipe = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddEditRecipeView()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let recipes = controller.filteredRecipes

        if recipes.isEmpty {
            ContentUnavailableView(
                "No recipes found",
                systemImage: "magnifyingglass",
                description: Text("Try a different search or category, or tap + to add a recipe.")
            )
        } else if controller.isGridView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(recipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                            RecipeRowView(recipe: recipe, isGrid: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        } else {
            List(recipes, id: \.id) { recipe in
                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                    RecipeRowView(recipe: recipe)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        controller.deleteRecipe(recipe)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        controller.toggleFavorite(for: recipe)
                    } label: {
                        Label(recipe.isFavorite ? "Unfavorite" : "Favorite", systemImage: "heart")
                    }
                    .tint(.red)
                }
            }
            .listStyle(.plain)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(controller.categories, id: \.self) { category in
                    Text(category)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(controller.selectedCategory == category ? Color.orange : Color.orange.opacity(0.12))
                        .foregroundStyle(controller.selectedCategory == category ? .white : .orange)
                        .clipShape(Capsule())
                        .onTapGesture {
                            controller.selectedCategory = category
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var sortAndViewToolbar: some View {
        HStack {
            Menu {
                Picker("Sort by", selection: $controller.sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("Sort: \(controller.sortOption.rawValue)", systemImage: "arrow.up.arrow.down")
                    .font(.caption)
            }

            Spacer()

            Button {
                controller.isGridView.toggle()
            } label: {
                Image(systemName: controller.isGridView ? "list.bullet" : "square.grid.2x2")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    RecipeListView()
        .environmentObject(RecipeController())
}
