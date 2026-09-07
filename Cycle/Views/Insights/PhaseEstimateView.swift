import SwiftUI

struct PhaseEstimateView: View {
    let cycles: [CycleInfo]

    private var prediction: Prediction? {
        PredictionEngine.predict(from: cycles, windowSize: 6)
    }

    var body: some View {
        if let prediction {
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Cycle Phases")
                    .font(CycleTheme.captionFont)
                    .foregroundStyle(CycleTheme.textColor.opacity(0.6))

                if let current = cycles.last, !current.isComplete {
                    let cycleLength = Int(prediction.averageCycleLength.rounded())
                    let ovulationDay = cycleLength - 14

                    PhaseBar(
                        periodLength: current.periodLength,
                        ovulationDay: ovulationDay,
                        cycleLength: cycleLength
                    )
                }

                HStack(spacing: 16) {
                    PhaseLegend(color: CycleTheme.primaryColor, label: "Period")
                    PhaseLegend(color: CycleTheme.fertileColor, label: "Estimated fertile window")
                    PhaseLegend(color: CycleTheme.secondaryColor, label: "Luteal")
                }
                .font(CycleTheme.captionFont)

                Text("This is an estimate based on averages. Not a contraceptive method.")
                    .font(.system(size: 10))
                    .foregroundStyle(CycleTheme.textColor.opacity(0.4))
            }
            .padding(CycleTheme.cardPadding)
            .background(CycleTheme.textColor.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
        }
    }
}

private struct PhaseBar: View {
    let periodLength: Int
    let ovulationDay: Int
    let cycleLength: Int

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let dayWidth = width / CGFloat(cycleLength)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(CycleTheme.textColor.opacity(0.08))

                RoundedRectangle(cornerRadius: 6)
                    .fill(CycleTheme.primaryColor.opacity(0.6))
                    .frame(width: dayWidth * CGFloat(periodLength))

                let fertileStart = max(0, ovulationDay - 2)
                RoundedRectangle(cornerRadius: 6)
                    .fill(CycleTheme.fertileColor.opacity(0.5))
                    .frame(width: dayWidth * 5)
                    .offset(x: dayWidth * CGFloat(fertileStart))

                let lutealStart = ovulationDay + 1
                let lutealLength = cycleLength - lutealStart
                if lutealLength > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(CycleTheme.secondaryColor.opacity(0.3))
                        .frame(width: dayWidth * CGFloat(lutealLength))
                        .offset(x: dayWidth * CGFloat(lutealStart))
                }
            }
        }
        .frame(height: 24)
    }
}

private struct PhaseLegend: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundStyle(CycleTheme.textColor.opacity(0.6))
        }
    }
}
