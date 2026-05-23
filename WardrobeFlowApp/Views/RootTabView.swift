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
                .accessibilityIdentifier(AccessibilityID.Tab.today)

            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "tshirt")
                }
                .accessibilityIdentifier(AccessibilityID.Tab.wardrobe)

            OutfitsView()
                .tabItem {
                    Label("Outfits", systemImage: "square.grid.2x2")
                }
                .accessibilityIdentifier(AccessibilityID.Tab.outfits)

            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }
                .accessibilityIdentifier(AccessibilityID.Tab.planner)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .accessibilityIdentifier(AccessibilityID.Tab.profile)
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
