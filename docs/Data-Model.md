# Data Model (SwiftData, Implemented)

## ClothingItem (`@Model`)
- `id: UUID` (unique)
- `name: String`
- `category: ClothingCategory`
- `color: ClothingColor`
- `season: Season`
- `formality: Formality`
- `status: ItemStatus`
- `tagsCSV: String` (computed access via `tags: [String]`)
- `wearCount: Int`
- `lastWornAt: Date?`
- `createdAt: Date`
- `updatedAt: Date`
- `imageData: Data?` (external storage)
- Relationship: many-to-many with `Outfit`

## Outfit (`@Model`)
- `id: UUID` (unique)
- `name: String`
- `season: Season`
- `formality: Formality`
- `isFavorite: Bool`
- `createdAt: Date`
- `updatedAt: Date`
- Relationship: `items: [ClothingItem]`
- Relationship: `plans: [OutfitPlan]`

## OutfitPlan (`@Model`)
- `id: UUID` (unique)
- `date: Date`
- `isCompleted: Bool`
- `createdAt: Date`
- Relationship: `outfit: Outfit?`

## WeatherSnapshot (runtime)
- `minTempC: Int`
- `maxTempC: Int`
- `condition: WeatherCondition`

## Business Rules
1. Only `clean` items are used for recommendations and outfit building.
2. Valid outfit must contain at least one `top`, one `bottom`, and one `shoes`.
3. Completing daily plan increments `wearCount` and updates `lastWornAt`.
4. `laundry`, `repair`, and `archived` states block normal outfit use.
