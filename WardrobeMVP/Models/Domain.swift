import Foundation
import SwiftData

enum ClothingCategory: String, CaseIterable, Identifiable, Codable {
    case top
    case bottom
    case outerwear
    case shoes
    case accessory

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum ClothingColor: String, CaseIterable, Identifiable, Codable {
    case black, white, gray, blue, green, red, beige, brown, multicolor

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum Season: String, CaseIterable, Identifiable, Codable {
    case spring
    case summer
    case autumn
    case winter
    case allSeason

    var id: String { rawValue }
    var title: String {
        switch self {
        case .allSeason: return "All Season"
        default: return rawValue.capitalized
        }
    }
}

enum Formality: String, CaseIterable, Identifiable, Codable {
    case casual
    case smartCasual
    case business
    case formal
    case sport

    var id: String { rawValue }
    var title: String {
        switch self {
        case .smartCasual: return "Smart Casual"
        default: return rawValue.capitalized
        }
    }
}

enum ItemStatus: String, CaseIterable, Identifiable, Codable {
    case clean
    case laundry
    case repair
    case archived

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum WeatherCondition: String, CaseIterable, Codable {
    case clear
    case cloudy
    case rain
    case snow
}

@Model
final class ClothingItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: ClothingCategory
    var color: ClothingColor
    var season: Season
    var formality: Formality
    var status: ItemStatus
    var tagsCSV: String
    var wearCount: Int
    var lastWornAt: Date?
    var createdAt: Date
    var updatedAt: Date
    @Attribute(.externalStorage) var imageData: Data?

    @Relationship(deleteRule: .nullify, inverse: \Outfit.items)
    var outfits: [Outfit]

    var tags: [String] {
        get {
            tagsCSV
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            tagsCSV = newValue.joined(separator: ",")
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: ClothingCategory,
        color: ClothingColor,
        season: Season,
        formality: Formality,
        status: ItemStatus = .clean,
        tags: [String] = [],
        wearCount: Int = 0,
        lastWornAt: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.color = color
        self.season = season
        self.formality = formality
        self.status = status
        self.tagsCSV = tags.joined(separator: ",")
        self.wearCount = wearCount
        self.lastWornAt = lastWornAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageData = imageData
        self.outfits = []
    }
}

@Model
final class Outfit {
    @Attribute(.unique) var id: UUID
    var name: String
    var season: Season
    var formality: Formality
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \ClothingItem.outfits)
    var items: [ClothingItem]

    @Relationship(deleteRule: .nullify, inverse: \OutfitPlan.outfit)
    var plans: [OutfitPlan]

    init(
        id: UUID = UUID(),
        name: String,
        items: [ClothingItem],
        season: Season,
        formality: Formality,
        isFavorite: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.season = season
        self.formality = formality
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.plans = []
    }
}

@Model
final class OutfitPlan {
    @Attribute(.unique) var id: UUID
    var date: Date
    var isCompleted: Bool
    var createdAt: Date

    @Relationship
    var outfit: Outfit?

    init(
        id: UUID = UUID(),
        date: Date,
        outfit: Outfit? = nil,
        isCompleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.outfit = outfit
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

struct WeatherSnapshot {
    var minTempC: Int
    var maxTempC: Int
    var condition: WeatherCondition

    static let fallback = WeatherSnapshot(minTempC: 10, maxTempC: 17, condition: .cloudy)
}
