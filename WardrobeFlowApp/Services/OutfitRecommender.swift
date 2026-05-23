import Foundation

struct OutfitRecommender {
    func recommendedOutfits(
        wardrobe: [ClothingItem],
        weather: WeatherSnapshot,
        targetFormality: Formality = .casual,
        limit: Int = 3
    ) -> [[ClothingItem]] {
        let available = wardrobe.filter { $0.status == .clean }
        let tops = available.filter { $0.category == .top }
        let bottoms = available.filter { $0.category == .bottom }
        let shoes = available.filter { $0.category == .shoes }
        let layers = available.filter { $0.category == .outerwear }
        let includeLayer = weather.minTempC < 12

        var variants: [[ClothingItem]] = []
        for top in tops where top.formality == targetFormality || targetFormality == .casual {
            for bottom in bottoms where bottom.formality == targetFormality || targetFormality == .casual {
                for shoe in shoes where shoe.formality == targetFormality || targetFormality == .casual {
                    var combination = [top, bottom, shoe]
                    if includeLayer, let layer = layers.first(where: { $0.season == top.season || $0.season == .allSeason }) {
                        combination.append(layer)
                    }
                    if isSeasonCompatible(items: combination) {
                        variants.append(combination)
                    }
                    if variants.count >= limit {
                        return variants
                    }
                }
            }
        }
        return variants
    }

    private func isSeasonCompatible(items: [ClothingItem]) -> Bool {
        let seasons = Set(items.map(\.season).filter { $0 != .allSeason })
        return seasons.count <= 2
    }
}
