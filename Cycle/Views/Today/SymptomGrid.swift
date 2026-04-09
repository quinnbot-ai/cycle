import SwiftUI

struct SymptomGrid: View {
    @Binding var selected: Set<Symptom>

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: CycleTheme.gridSpacing)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Symptoms")
                .font(CycleTheme.subheaderFont)
                .foregroundStyle(CycleTheme.textColor)

            LazyVGrid(columns: columns, spacing: CycleTheme.gridSpacing) {
                ForEach(Symptom.allCases) { symptom in
                    PillChip(
                        label: symptom.label,
                        icon: symptom.icon,
                        isSelected: selected.contains(symptom)
                    ) {
                        if selected.contains(symptom) {
                            selected.remove(symptom)
                        } else {
                            selected.insert(symptom)
                        }
                    }
                }
            }
        }
    }
}
