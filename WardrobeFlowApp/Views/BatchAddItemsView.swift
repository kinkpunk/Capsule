import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct BatchAddItemsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var drafts: [DraftItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var defaultCategory: ClothingCategory = .top
    @State private var defaultColor: ClothingColor = .black
    @State private var defaultSeason: Season = .allSeason
    @State private var defaultFormality: Formality = .casual
    @State private var defaultStatus: ItemStatus = .clean
    @State private var defaultTagsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Photos") {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 50,
                        matching: .images
                    ) {
                        Label("Select multiple photos", systemImage: "photo.on.rectangle.angled")
                    }
                    .accessibilityIdentifier(AccessibilityID.BatchImport.picker)

                    if isLoading {
                        ProgressView("Importing…")
                    }
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                if !drafts.isEmpty {
                    Section("Defaults") {
                        Picker("Category", selection: $defaultCategory) {
                            ForEach(ClothingCategory.allCases) { Text($0.title).tag($0) }
                        }
                        Picker("Color", selection: $defaultColor) {
                            ForEach(ClothingColor.allCases) { Text($0.title).tag($0) }
                        }
                        Picker("Season", selection: $defaultSeason) {
                            ForEach(Season.allCases) { Text($0.title).tag($0) }
                        }
                        Picker("Formality", selection: $defaultFormality) {
                            ForEach(Formality.allCases) { Text($0.title).tag($0) }
                        }
                        Picker("Status", selection: $defaultStatus) {
                            ForEach(ItemStatus.allCases) { Text($0.title).tag($0) }
                        }
                        TextField("Tags separated by comma", text: $defaultTagsText)
                    }
                    .accessibilityIdentifier(AccessibilityID.BatchImport.defaultsSection)

                    Section("Items (\(drafts.count))") {
                        ForEach($drafts) { $draft in
                            DraftRowView(draft: $draft)
                        }
                    }
                }
            }
            .navigationTitle("Batch import")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save all") {
                        saveAll()
                        dismiss()
                    }
                    .accessibilityIdentifier(AccessibilityID.BatchImport.saveAll)
                    .disabled(drafts.isEmpty || drafts.contains(where: { $0.nameTrimmed.isEmpty }))
                }

                if !drafts.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Clear") {
                            selectedPhotoItems = []
                            drafts = []
                            errorMessage = nil
                        }
                        .accessibilityIdentifier(AccessibilityID.BatchImport.clearAll)
                    }
                }
            }
            .onChange(of: selectedPhotoItems) { _, newValue in
                Task { await importPhotos(newValue) }
            }
        }
    }

    @MainActor
    private func importPhotos(_ items: [PhotosPickerItem]) async {
        isLoading = true
        errorMessage = nil
        drafts = []

        defer { isLoading = false }
        guard !items.isEmpty else { return }

        var nextDrafts: [DraftItem] = []
        nextDrafts.reserveCapacity(items.count)

        for (index, item) in items.enumerated() {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                continue
            }

            nextDrafts.append(
                DraftItem(
                    image: image,
                    name: "Item \(index + 1)",
                    category: defaultCategory,
                    color: defaultColor
                )
            )
        }

        if nextDrafts.isEmpty {
            errorMessage = "Could not load selected images."
        }
        drafts = nextDrafts
    }

    private func saveAll() {
        let defaultTags = defaultTagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for draft in drafts {
            let item = ClothingItem(
                name: draft.nameTrimmed,
                category: draft.category,
                color: draft.color,
                season: defaultSeason,
                formality: defaultFormality,
                status: defaultStatus,
                tags: defaultTags,
                imageData: draft.image.jpegData(compressionQuality: 0.85)
            )
            modelContext.insert(item)
        }
        try? modelContext.save()
    }
}

private struct DraftItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let image: UIImage
    var name: String
    var category: ClothingCategory
    var color: ClothingColor

    var nameTrimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
}

private struct DraftRowView: View {
    @Binding var draft: DraftItem

    var body: some View {
        HStack(spacing: 12) {
            Image(uiImage: draft.image)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                TextField("Name", text: $draft.name)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier(AccessibilityID.BatchImport.itemName(draft.id))

                HStack {
                    Picker("Category", selection: $draft.category) {
                        ForEach(ClothingCategory.allCases) { Text($0.title).tag($0) }
                    }
                    .labelsHidden()
                    .accessibilityIdentifier(AccessibilityID.BatchImport.itemCategory(draft.id))

                    Picker("Color", selection: $draft.color) {
                        ForEach(ClothingColor.allCases) { Text($0.title).tag($0) }
                    }
                    .labelsHidden()
                    .accessibilityIdentifier(AccessibilityID.BatchImport.itemColor(draft.id))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

