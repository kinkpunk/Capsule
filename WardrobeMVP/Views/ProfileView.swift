import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var wardrobeItems: [ClothingItem]
    @Query(sort: \Outfit.createdAt, order: .reverse) private var outfits: [Outfit]

    var body: some View {
        NavigationStack {
            List {
                Section("Stats") {
                    statRow(title: "Total items", value: "\(wardrobeItems.count)")
                    statRow(title: "Saved outfits", value: "\(outfits.count)")
                    statRow(title: "Not worn 30+ days", value: "\(staleItems.count)")
                }

                Section("Stale items") {
                    if staleItems.isEmpty {
                        Text("All items are used regularly")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(staleItems) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text(item.category.title)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    private var staleItems: [ClothingItem] {
        let border = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        return wardrobeItems.filter {
            guard let lastWornAt = $0.lastWornAt else { return true }
            return lastWornAt < border
        }
    }

    @ViewBuilder
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
