import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \PeriodEntry.date, order: .forward) private var allEntries: [PeriodEntry]

    let storeManager: StoreManager

    private var cycles: [CycleInfo] {
        CycleCalculator.deriveCycles(from: allEntries)
    }

    private var completedCycles: [CycleInfo] {
        cycles.filter { $0.isComplete }
    }

    private var avgCycleLength: Double? {
        let lengths = completedCycles.compactMap { $0.length }.map(Double.init)
        guard !lengths.isEmpty else { return nil }
        return lengths.reduce(0, +) / Double(lengths.count)
    }

    private var avgPeriodLength: Double? {
        let lengths = completedCycles.map { Double($0.periodLength) }
        guard !lengths.isEmpty else { return nil }
        return lengths.reduce(0, +) / Double(lengths.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if completedCycles.isEmpty {
                        emptyState
                    } else {
                        statsCards
                        cycleHistory
                        proSection
                    }
                }
                .padding()
            }
            .background(CycleTheme.backgroundColor)
            .navigationTitle("Insights")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(CycleTheme.textColor.opacity(0.3))
            Text("Log at least two complete cycles to see insights")
                .font(CycleTheme.bodyFont)
                .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var statsCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Avg cycle", value: avgCycleLength.map { String(format: "%.0f days", $0) } ?? "—")
            StatCard(title: "Avg period", value: avgPeriodLength.map { String(format: "%.0f days", $0) } ?? "—")
            StatCard(title: "Cycles tracked", value: "\(completedCycles.count)")
            StatCard(title: "Total entries", value: "\(allEntries.count)")
        }
    }

    private var cycleHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Cycles")
                .font(CycleTheme.subheaderFont)
                .foregroundStyle(CycleTheme.textColor)

            ForEach(completedCycles.suffix(6).reversed()) { cycle in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cycle.startDate.shortDateString)
                            .font(CycleTheme.bodyFont)
                            .foregroundStyle(CycleTheme.textColor)
                        Text("\(cycle.periodLength) day period")
                            .font(CycleTheme.captionFont)
                            .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                    }
                    Spacer()
                    if let length = cycle.length {
                        Text("\(length) days")
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundStyle(CycleTheme.primaryColor)
                    }
                }
                .padding(CycleTheme.cardPadding)
                .background(CycleTheme.textColor.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
            }
        }
    }

    private var proSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Analytics")
                    .font(CycleTheme.subheaderFont)
                ProBadge()
            }
            .foregroundStyle(CycleTheme.textColor)

            TrendChartView(cycles: completedCycles)
            PhaseEstimateView(cycles: cycles)
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(CycleTheme.primaryColor)
            Text(title)
                .font(CycleTheme.captionFont)
                .foregroundStyle(CycleTheme.textColor.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(CycleTheme.cardPadding)
        .background(CycleTheme.textColor.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
    }
}
