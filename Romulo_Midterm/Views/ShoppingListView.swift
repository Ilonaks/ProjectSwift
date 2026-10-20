//
//  ShoppingListView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/20/26.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var controller: RecipeController
    @State private var showingAddAlert = false
    @State private var newItemName = ""

    private var hasCheckedItems: Bool {
        controller.shoppingItems.contains { $0.isChecked }
    }

    var body: some View {
        NavigationStack {
            Group {
                if controller.shoppingItems.isEmpty {
                    ContentUnavailableView(
                        "Shopping list is empty",
                        systemImage: "cart",
                        description: Text("Open a recipe and tap \"Add to shopping list\", or tap + to add an item.")
                    )
                } else {
                    List {
                        ForEach(controller.shoppingItems, id: \.id) { item in
                            Button {
                                controller.toggleShoppingItem(item)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(item.isChecked ? .orange : .secondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name)
                                            .strikethrough(item.isChecked)
                                            .foregroundStyle(item.isChecked ? .secondary : .primary)
                                        if !item.recipeName.isEmpty {
                                            Text("For \(item.recipeName)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    controller.deleteShoppingItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if hasCheckedItems {
                        Button("Clear done") {
                            controller.clearCheckedShoppingItems()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Add item", isPresented: $showingAddAlert) {
                TextField("e.g. 2 kg rice", text: $newItemName)
                Button("Add") {
                    controller.addShoppingItem(named: newItemName)
                    newItemName = ""
                }
                Button("Cancel", role: .cancel) {
                    newItemName = ""
                }
            }
        }
    }
}

#Preview {
    ShoppingListView()
        .environmentObject(RecipeController())
}
