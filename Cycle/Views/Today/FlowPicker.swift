import SwiftUI

struct FlowPicker: View {
    @Binding var selected: FlowLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flow")
                .font(CycleTheme.subheaderFont)
                .foregroundStyle(CycleTheme.textColor)

            HStack(spacing: 8) {
                ForEach(FlowLevel.allCases.filter { $0 != .none }) { level in
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        selected = (selected == level) ? .none : level
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: level.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(CycleTheme.flowColor(for: level))
                            Text(level.label)
                                .font(CycleTheme.captionFont)
                                .foregroundStyle(CycleTheme.textColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selected == level
                                ? CycleTheme.flowColor(for: level).opacity(0.15)
                                : CycleTheme.textColor.opacity(0.04)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    selected == level ? CycleTheme.flowColor(for: level).opacity(0.4) : .clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
