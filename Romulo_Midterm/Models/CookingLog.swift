//
//  CookingLog.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/20/26.
//
import Foundation
import SwiftData

@Model
final class CookingLog {
    var id: UUID
    var cookedAt: Date
    var recipe: Recipe?

    init(cookedAt: Date = Date()) {
        self.id = UUID()
        self.cookedAt = cookedAt
    }
}
