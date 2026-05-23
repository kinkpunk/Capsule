import SwiftUI
import SwiftData

@main
struct WardrobeMVPApp: App {
    @StateObject private var weatherViewModel = WeatherViewModel()

    private var modelContainer: ModelContainer = {
        let schema = Schema([
            ClothingItem.self,
            Outfit.self,
            OutfitPlan.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(weatherViewModel)
        }
        .modelContainer(modelContainer)
    }
}
