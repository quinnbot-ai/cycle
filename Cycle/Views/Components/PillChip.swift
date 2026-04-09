import SwiftUI

struct PillChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(CycleTheme.captionFont)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? CycleTheme.primaryColor.opacity(0.25)
                    : CycleTheme.textColor.opacity(0.06)
            )
            .foregroundStyle(isSelected ? CycleTheme.primaryColor : CycleTheme.textColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? CycleTheme.primaryColor.opacity(0.4) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        PillChip(label: "Cramps", icon: "bolt.fill", isSelected: true) {}
        PillChip(label: "Headache", icon: "brain.head.profile", isSelected: false) {}
    }
    .padding()
}
