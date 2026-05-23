import SwiftUI
import SwiftData

struct PlannerView: View {
    @Query(sort: \OutfitPlan.date, order: .forward) private var plans: [OutfitPlan]
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)

                if let plan = selectedPlan, let outfit = plan.outfit {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Planned outfit")
                            .font(.headline)
                        Text(outfit.name)
                            .font(.title3.bold())
                        Text(outfit.items.map(\.name).joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    ContentUnavailableView(
                        "No outfit planned",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Open Outfits tab and assign one to this day.")
                    )
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Planner")
        }
    }

    private var selectedPlan: OutfitPlan? {
        plans.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
}
