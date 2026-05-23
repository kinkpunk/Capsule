import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: ClothingItem

    @State private var editedName: String
    @State private var tagsText: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var isDeleteConfirmPresented = false

    init(item: ClothingItem) {
        self.item = item
        _editedName = State(initialValue: item.name)
        _tagsText = State(initialValue: item.tags.joined(separator: ","))
    }

    var body: some View {
        Form {
            Section("Photo") {
                HStack(spacing: 12) {
                    previewImage
                    VStack(alignment: .leading, spacing: 8) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Choose from gallery", systemImage: "photo")
                        }
                        .accessibilityIdentifier(AccessibilityID.ItemDetail.chooseFromGallery)

                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                isCameraPresented = true
                            } label: {
                                Label("Take photo", systemImage: "camera")
                            }
                            .accessibilityIdentifier(AccessibilityID.ItemDetail.takePhoto)
                        }
                    }
                }
                .onChange(of: selectedPhotoItem) { _, newValue in
                    Task {
                        guard let data = try? await newValue?.loadTransferable(type: Data.self),
                              let image = UIImage(data: data) else { return }
                        selectedImage = image
                    }
                }
                .onChange(of: selectedImage) { _, newValue in
                    guard let newValue else { return }
                    item.imageData = newValue.jpegData(compressionQuality: 0.85)
                    item.updatedAt = .now
                }
            }

            Section("Basics") {
                TextField("Item name", text: $editedName)
                    .accessibilityIdentifier(AccessibilityID.ItemDetail.nameField)

                Picker("Category", selection: $item.category) {
                    ForEach(ClothingCategory.allCases) { Text($0.title).tag($0) }
                }
                Picker("Color", selection: $item.color) {
                    ForEach(ClothingColor.allCases) { Text($0.title).tag($0) }
                }
            }

            Section("Attributes") {
                Picker("Season", selection: $item.season) {
                    ForEach(Season.allCases) { Text($0.title).tag($0) }
                }
                Picker("Formality", selection: $item.formality) {
                    ForEach(Formality.allCases) { Text($0.title).tag($0) }
                }
                Picker("Status", selection: $item.status) {
                    ForEach(ItemStatus.allCases) { Text($0.title).tag($0) }
                }

                TextField("Tags separated by comma", text: $tagsText)
            }

            Section("Actions") {
                if item.status != .archived {
                    Button {
                        item.status = .archived
                        item.updatedAt = .now
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        Label("Archive item", systemImage: "archivebox")
                    }
                    .foregroundStyle(.orange)
                    .accessibilityIdentifier(AccessibilityID.ItemDetail.archiveButton)
                } else {
                    Button {
                        item.status = .clean
                        item.updatedAt = .now
                        try? modelContext.save()
                    } label: {
                        Label("Unarchive item", systemImage: "arrow.uturn.left")
                    }
                    .accessibilityIdentifier(AccessibilityID.ItemDetail.unarchiveButton)
                }

                Button(role: .destructive) {
                    isDeleteConfirmPresented = true
                } label: {
                    Label("Delete item", systemImage: "trash")
                }
                .accessibilityIdentifier(AccessibilityID.ItemDetail.deleteButton)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    applyEditsAndSave()
                    dismiss()
                }
                .accessibilityIdentifier(AccessibilityID.ItemDetail.saveButton)
                .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .confirmationDialog("Delete item?", isPresented: $isDeleteConfirmPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(item)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraPickerView(image: $selectedImage)
        }
    }

    private var previewImage: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageData = item.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func applyEditsAndSave() {
        let cleanName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        item.name = cleanName
        item.tagsCSV = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ",")
        item.updatedAt = .now
        try? modelContext.save()
    }
}

