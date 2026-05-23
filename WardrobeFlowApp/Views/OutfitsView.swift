import SwiftUI
import SwiftData

struct OutfitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Outfit.createdAt, order: .reverse) private var outfits: [Outfit]
    @Query(sort: \OutfitPlan.date, order: .forward) private var plans: [OutfitPlan]

    @State private var isBuilderPresented = false
    @State private var isAssignPresented = false
    @State private var assignDate = Date()
    @State private var assignOutfit: Outfit?

    var body: some View {
        NavigationStack {
            Group {
                if outfits.isEmpty {
                    ContentUnavailableView(
                        "No outfits yet",
                        systemImage: "square.grid.2x2",
                        description: Text("Create a few outfits so you can plan them on the calendar.")
                    )
                    .padding()
                } else {
                    List {
                        ForEach(outfits) { outfit in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(outfit.name)
                                    .font(.headline)
                                Text(outfit.items.map(\.name).joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Button("Assign date…") {
                                    assignOutfit = outfit
                                    assignDate = .now
                                    isAssignPresented = true
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier(AccessibilityID.Outfits.assignButtonPrefix + outfit.id.uuidString)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Outfits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isBuilderPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier(AccessibilityID.Outfits.addButton)
                }
                if outfits.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            isBuilderPresented = true
                        } label: {
                            Label("New outfit", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier(AccessibilityID.Outfits.emptyAddButton)
                    }
                }
            }
            .sheet(isPresented: $isBuilderPresented) {
                OutfitBuilderView()
            }
            .sheet(isPresented: $isAssignPresented) {
                assignSheet
            }
        }
    }

    private func assign(_ outfit: Outfit, to date: Date) {
        if let existing = plans.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            existing.outfit = outfit
            existing.isCompleted = false
        } else {
            let plan = OutfitPlan(date: date, outfit: outfit)
            modelContext.insert(plan)
        }
        try? modelContext.save()
    }

    private var assignSheet: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $assignDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            .navigationTitle("Assign outfit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isAssignPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let outfit = assignOutfit {
                            assign(outfit, to: assignDate)
                        }
                        isAssignPresented = false
                    }
                    .accessibilityIdentifier(AccessibilityID.Outfits.assignSheetSave)
                    .disabled(assignOutfit == nil)
                }
            }
        }
    }
}
