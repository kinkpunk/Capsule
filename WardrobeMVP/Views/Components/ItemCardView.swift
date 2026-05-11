import SwiftUI
import UIKit

struct ItemCardView: View {
    let item: ClothingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageBlock

            Text(item.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text("\(item.category.title) - \(item.color.title)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(item.status.title)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }

    private var imageBlock: some View {
        Group {
            if let imageData = item.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        Image(systemName: iconName(for: item.category))
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    )
            }
        }
        .frame(height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusColor: Color {
        switch item.status {
        case .clean: return .green
        case .laundry: return .orange
        case .repair: return .red
        case .archived: return .gray
        }
    }

    private func iconName(for category: ClothingCategory) -> String {
        switch category {
        case .top: return "tshirt"
        case .bottom: return "figure.walk"
        case .outerwear: return "wind"
        case .shoes: return "shoeprints.fill"
        case .accessory: return "suitcase.fill"
        }
    }
}
