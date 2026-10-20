//
//  ShoppingItem.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/20/26.
//
import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var id: UUID
    var name: String
    var recipeName: String
    var isChecked: Bool
    var createdAt: Date

    init(name: String, recipeName: String = "", isChecked: Bool = false, createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.recipeName = recipeName
        self.isChecked = isChecked
        self.createdAt = createdAt
    }
}
