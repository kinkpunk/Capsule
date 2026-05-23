import PhotosUI
import SwiftUI
import SwiftData
import UIKit

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var category: ClothingCategory = .top
    @State private var color: ClothingColor = .black
    @State private var season: Season = .allSeason
    @State private var formality: Formality = .casual
    @State private var status: ItemStatus = .clean
    @State private var tagsText = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var addAnotherAfterSave = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack(spacing: 12) {
                        previewImage
                        VStack(alignment: .leading, spacing: 8) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label("Choose from gallery", systemImage: "photo")
                            }
                            .accessibilityIdentifier(AccessibilityID.AddItem.chooseFromGallery)
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                Button {
                                    isCameraPresented = true
                                } label: {
                                    Label("Take photo", systemImage: "camera")
                                }
                                .accessibilityIdentifier(AccessibilityID.AddItem.takePhoto)
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
                }

                Section("Basics") {
                    TextField("Item name", text: $name)
                        .accessibilityIdentifier(AccessibilityID.AddItem.nameField)
                    Picker("Category", selection: $category) {
                        ForEach(ClothingCategory.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Color", selection: $color) {
                        ForEach(ClothingColor.allCases) { Text($0.title).tag($0) }
                    }
                }

                Section("Attributes") {
                    Picker("Season", selection: $season) {
                        ForEach(Season.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Formality", selection: $formality) {
                        ForEach(Formality.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Status", selection: $status) {
                        ForEach(ItemStatus.allCases) { Text($0.title).tag($0) }
                    }
                    TextField("Tags separated by comma", text: $tagsText)
                }

                Section {
                    Toggle("Add another after saving", isOn: $addAnotherAfterSave)
                        .accessibilityIdentifier(AccessibilityID.AddItem.addAnotherToggle)
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier(AccessibilityID.AddItem.cancelButton)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveItem()
                        if addAnotherAfterSave {
                            resetForm()
                        } else {
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier(AccessibilityID.AddItem.saveButton)
                }
            }
            .sheet(isPresented: $isCameraPresented) {
                CameraPickerView(image: $selectedImage)
            }
        }
    }

    private var previewImage: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
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

    private func saveItem() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let item = ClothingItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            color: color,
            season: season,
            formality: formality,
            status: status,
            tags: tags,
            imageData: selectedImage?.jpegData(compressionQuality: 0.85)
        )
        modelContext.insert(item)
        try? modelContext.save()
    }

    private func resetForm() {
        name = ""
        category = .top
        color = .black
        season = .allSeason
        formality = .casual
        status = .clean
        tagsText = ""
        selectedPhotoItem = nil
        selectedImage = nil
        isCameraPresented = false
    }
}
