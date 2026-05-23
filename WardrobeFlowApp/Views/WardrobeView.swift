import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var wardrobeItems: [ClothingItem]

    @State private var searchText = ""
    @State private var selectedCategory: ClothingCategory?
    @State private var isAddPresented = false
    @State private var isBatchPresented = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No items yet",
                        systemImage: "tshirt",
                        description: Text("Add a few items to start building outfits.")
                    )
                    .padding()
                } else {
                    ScrollView {
                        categoryFilters

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredItems) { item in
                                NavigationLink {
                                    ItemDetailView(item: item)
                                } label: {
                                    ItemCardView(item: item)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Mark clean") { updateStatus(item, .clean) }
                                    Button("Mark laundry") { updateStatus(item, .laundry) }
                                    Button("Mark repair") { updateStatus(item, .repair) }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .accessibilityIdentifier(AccessibilityID.Wardrobe.searchField)
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isAddPresented = true
                        } label: {
                            Label("Add item", systemImage: "plus")
                        }

                        Button {
                            isBatchPresented = true
                        } label: {
                            Label("Batch import photos", systemImage: "photo.on.rectangle.angled")
                        }
                        .accessibilityIdentifier(AccessibilityID.Wardrobe.batchImport)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier(AccessibilityID.Wardrobe.addButton)
                }
                if filteredItems.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            isAddPresented = true
                        } label: {
                            Label("Add item", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier(AccessibilityID.Wardrobe.emptyAddButton)
                    }
                }
            }
            .sheet(isPresented: $isAddPresented) {
                AddItemView()
            }
            .sheet(isPresented: $isBatchPresented) {
                BatchAddItemsView()
            }
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if selectedCategory == nil {
                    Button("All") { selectedCategory = nil }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier(AccessibilityID.Wardrobe.filterAll)
                } else {
                    Button("All") { selectedCategory = nil }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier(AccessibilityID.Wardrobe.filterAll)
                }

                ForEach(ClothingCategory.allCases) { category in
                    if selectedCategory == category {
                        Button(category.title) { selectedCategory = category }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier(AccessibilityID.Wardrobe.filterCategory(category.rawValue))
                    } else {
                        Button(category.title) { selectedCategory = category }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier(AccessibilityID.Wardrobe.filterCategory(category.rawValue))
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var filteredItems: [ClothingItem] {
        wardrobeItems.filter { item in
            let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            return matchesSearch && matchesCategory && item.status != .archived
        }
    }

    private func updateStatus(_ item: ClothingItem, _ status: ItemStatus) {
        item.status = status
        item.updatedAt = .now
        try? modelContext.save()
    }
}
