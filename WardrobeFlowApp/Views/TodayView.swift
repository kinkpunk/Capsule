import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var weatherViewModel: WeatherViewModel

    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var wardrobeItems: [ClothingItem]
    @Query(sort: \OutfitPlan.date, order: .forward) private var plans: [OutfitPlan]

    private let recommender = OutfitRecommender()
    @State private var isAddPresented = false
    @State private var isOutfitBuilderPresented = false
    @State private var isBatchPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    weatherCard
                    recommendationsBlock
                    planBlock
                }
                .padding()
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isAddPresented = true
                        } label: {
                            Label("Add item", systemImage: "tshirt")
                        }
                        .accessibilityIdentifier(AccessibilityID.Today.addItem)

                        Button {
                            isBatchPresented = true
                        } label: {
                            Label("Batch import photos", systemImage: "photo.on.rectangle.angled")
                        }
                        .accessibilityIdentifier(AccessibilityID.Today.batchImport)

                        Button {
                            isOutfitBuilderPresented = true
                        } label: {
                            Label("New outfit", systemImage: "square.grid.2x2")
                        }
                        .accessibilityIdentifier(AccessibilityID.Today.newOutfit)

                        Divider()

                        Button {
                            weatherViewModel.requestWeather()
                        } label: {
                            Label("Refresh weather", systemImage: "arrow.clockwise")
                        }
                        .accessibilityIdentifier(AccessibilityID.Today.refreshButton)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .accessibilityIdentifier(AccessibilityID.Today.addMenu)
                }
            }
            .sheet(isPresented: $isAddPresented) {
                AddItemView()
            }
            .sheet(isPresented: $isBatchPresented) {
                BatchAddItemsView()
            }
            .sheet(isPresented: $isOutfitBuilderPresented) {
                OutfitBuilderView()
            }
        }
    }

    private var weatherCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weather")
                .font(.headline)
            Text("\(weatherViewModel.snapshot.minTempC) to \(weatherViewModel.snapshot.maxTempC) C")
                .font(.largeTitle.bold())
            Text("Temperature range is used for layering recommendations.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if weatherViewModel.isLoading {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(colors: [.blue.opacity(0.8), .cyan.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recommendationsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.headline)
            let suggestions = recommender.recommendedOutfits(wardrobe: availableWardrobe, weather: weatherViewModel.snapshot)
            if suggestions.isEmpty {
                ContentUnavailableView(
                    "No recommendations yet",
                    systemImage: "wand.and.stars",
                    description: Text("Add a few clean items to generate outfit options.")
                )
            } else {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { idx, combo in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Option \(idx + 1)")
                            .font(.subheadline.bold())
                        Text(combo.map(\.name).joined(separator: " + "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var planBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan for today")
                .font(.headline)
            if let plan = todayPlan, let outfit = plan.outfit {
                Text(outfit.name)
                    .font(.title3.bold())
                if !plan.isCompleted {
                    Button("Mark as worn") {
                        complete(plan)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Outfit already marked as worn.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No outfit planned for today.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var todayPlan: OutfitPlan? {
        plans.first { Calendar.current.isDate($0.date, inSameDayAs: .now) }
    }

    private var availableWardrobe: [ClothingItem] {
        wardrobeItems.filter { $0.status != .archived }
    }

    private func complete(_ plan: OutfitPlan) {
        guard !plan.isCompleted, let outfit = plan.outfit else { return }
        plan.isCompleted = true
        for item in outfit.items {
            item.wearCount += 1
            item.lastWornAt = .now
            item.updatedAt = .now
        }
        try? modelContext.save()
    }
}
