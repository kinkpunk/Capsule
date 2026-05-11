import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var weatherViewModel: WeatherViewModel
    @State private var didSeed = false

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }

            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "tshirt")
                }

            OutfitsView()
                .tabItem {
                    Label("Outfits", systemImage: "square.grid.2x2")
                }

            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .task {
            guard !didSeed else { return }
            didSeed = true
            do {
                try DataSeeder.seedIfNeeded(context: modelContext)
            } catch {
                assertionFailure("Seeding failed: \(error)")
            }
            weatherViewModel.requestWeather()
        }
    }
}
