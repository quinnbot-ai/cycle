import SwiftUI
import Charts

struct TrendChartView: View {
    let cycles: [CycleInfo]

    private var chartData: [(index: Int, length: Int)] {
        cycles.suffix(12).enumerated().compactMap { index, cycle in
            guard let length = cycle.length else { return nil }
            return (index: index + 1, length: length)
        }
    }

    var body: some View {
        if chartData.count >= 2 {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cycle Length Trend")
                    .font(CycleTheme.captionFont)
                    .foregroundStyle(CycleTheme.textColor.opacity(0.6))

                Chart(chartData, id: \.index) { item in
                    LineMark(
                        x: .value("Cycle", item.index),
                        y: .value("Days", item.length)
                    )
                    .foregroundStyle(CycleTheme.primaryColor)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Cycle", item.index),
                        y: .value("Days", item.length)
                    )
                    .foregroundStyle(CycleTheme.primaryColor)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }
            .padding(CycleTheme.cardPadding)
            .background(CycleTheme.textColor.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
        }
    }
}
