import SwiftUI
import SwiftData

struct OutfitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Outfit.createdAt, order: .reverse) private var outfits: [Outfit]
    @Query(sort: \OutfitPlan.date, order: .forward) private var plans: [OutfitPlan]

    @State private var isBuilderPresented = false
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            List {
                ForEach(outfits) { outfit in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(outfit.name)
                            .font(.headline)
                        Text(outfit.items.map(\.name).joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                .labelsHidden()
                            Button("Assign") {
                                assign(outfit, to: selectedDate)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
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
                }
            }
            .sheet(isPresented: $isBuilderPresented) {
                OutfitBuilderView()
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
}
