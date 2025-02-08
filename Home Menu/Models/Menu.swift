import Foundation
import SwiftUI

enum FoodCategory: String, Codable, CaseIterable {
    case vegetable = "Vegetable"
    case meat = "Meat"
    case soup = "Soup"
    case mixed = "Mixed"
    
    var icon: String {
        switch self {
        case .vegetable: return "leaf"
        case .meat: return "fork.knife"
        case .soup: return "cup.and.saucer"
        case .mixed: return "square.grid.2x2"
        }
    }
}

struct MenuItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var category: FoodCategory
    var isAvailable: Bool = true
}

struct Menu: Identifiable, Codable {
    var id = UUID()
    var ownerName: String
    var title: String
    var items: [MenuItem]
    var roomNumber: String? // Room number for sharing
    var lastUpdated: Date = Date()
} 