import Foundation
import SwiftData

enum DataSeeder {
    static func seedIfNeeded(context: ModelContext) throws {
        let descriptor = FetchDescriptor<ClothingItem>()
        let count = try context.fetchCount(descriptor)
        guard count == 0 else { return }

        let whiteTee = ClothingItem(
            name: "White T-Shirt",
            category: .top,
            color: .white,
            season: .summer,
            formality: .casual
        )
        let blueJeans = ClothingItem(
            name: "Blue Jeans",
            category: .bottom,
            color: .blue,
            season: .allSeason,
            formality: .casual
        )
        let whiteSneakers = ClothingItem(
            name: "White Sneakers",
            category: .shoes,
            color: .white,
            season: .allSeason,
            formality: .casual
        )
        let grayCoat = ClothingItem(
            name: "Gray Coat",
            category: .outerwear,
            color: .gray,
            season: .autumn,
            formality: .smartCasual
        )

        context.insert(whiteTee)
        context.insert(blueJeans)
        context.insert(whiteSneakers)
        context.insert(grayCoat)

        let outfit = Outfit(
            name: "City Casual",
            items: [whiteTee, blueJeans, whiteSneakers],
            season: .summer,
            formality: .casual
        )
        context.insert(outfit)
        try context.save()
    }
}
