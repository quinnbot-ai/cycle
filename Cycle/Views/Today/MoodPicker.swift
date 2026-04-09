import SwiftUI

struct MoodPicker: View {
    @Binding var selected: Mood

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood")
                .font(CycleTheme.subheaderFont)
                .foregroundStyle(CycleTheme.textColor)

            HStack(spacing: 8) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        selected = mood
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.system(size: 22))
                            Text(mood.label)
                                .font(CycleTheme.captionFont)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(
                            selected == mood ? CycleTheme.primaryColor : CycleTheme.textColor.opacity(0.6)
                        )
                        .background(
                            selected == mood
                                ? CycleTheme.primaryColor.opacity(0.12)
                                : CycleTheme.textColor.opacity(0.04)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
