import SwiftUI
import SwiftData

struct OutfitBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var wardrobeItems: [ClothingItem]

    @State private var outfitName = ""
    @State private var selectedIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List {
                Section("Outfit name") {
                    TextField("Example: Monday office", text: $outfitName)
                }

                Section("Choose items") {
                    ForEach(availableItems) { item in
                        Button {
                            toggle(item.id)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    Text("\(item.category.title) - \(item.formality.title)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedIDs.contains(item.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Outfit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveOutfit()
                        dismiss()
                    }
                    .disabled(!isValidOutfit)
                }
            }
        }
    }

    private var normalizedName: String {
        let clean = outfitName.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? "New Outfit" : clean
    }

    private var availableItems: [ClothingItem] {
        wardrobeItems.filter { $0.status == .clean && $0.status != .archived }
    }

    private var isValidOutfit: Bool {
        let selectedItems = wardrobeItems.filter { selectedIDs.contains($0.id) }
        let hasTop = selectedItems.contains(where: { $0.category == .top })
        let hasBottom = selectedItems.contains(where: { $0.category == .bottom })
        let hasShoes = selectedItems.contains(where: { $0.category == .shoes })
        return hasTop && hasBottom && hasShoes
    }

    private func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func saveOutfit() {
        let selectedItems = wardrobeItems.filter { selectedIDs.contains($0.id) }
        let season = selectedItems.first(where: { $0.season != .allSeason })?.season ?? .allSeason
        let formality = selectedItems.first?.formality ?? .casual
        let outfit = Outfit(name: normalizedName, items: selectedItems, season: season, formality: formality)
        modelContext.insert(outfit)
        try? modelContext.save()
    }
}
