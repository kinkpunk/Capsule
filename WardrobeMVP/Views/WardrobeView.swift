import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var wardrobeItems: [ClothingItem]

    @State private var searchText = ""
    @State private var selectedCategory: ClothingCategory?
    @State private var isAddPresented = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                categoryFilters

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredItems) { item in
                        ItemCardView(item: item)
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
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddPresented) {
                AddItemView()
            }
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("All") { selectedCategory = nil }
                    .buttonStyle(.borderedProminent)
                ForEach(ClothingCategory.allCases) { category in
                    Button(category.title) { selectedCategory = category }
                        .buttonStyle(.bordered)
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
