import WidgetKit
import SwiftUI

struct CycleDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> CycleDayEntry {
        CycleDayEntry(date: Date(), cycleDay: 14)
    }

    func getSnapshot(in context: Context, completion: @escaping (CycleDayEntry) -> Void) {
        completion(CycleDayEntry(date: Date(), cycleDay: SharedData.currentCycleDay))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CycleDayEntry>) -> Void) {
        let entry = CycleDayEntry(date: Date(), cycleDay: SharedData.currentCycleDay)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct CycleDayEntry: TimelineEntry {
    let date: Date
    let cycleDay: Int?
}

struct CycleDayWidgetView: View {
    var entry: CycleDayEntry

    var body: some View {
        VStack(spacing: 4) {
            if let day = entry.cycleDay {
                Text("Day")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("\(day)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0xD4A0A0))
            } else {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: 0xD4A0A0))
                Text("No data")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct CycleDayWidget: Widget {
    let kind = "CycleDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CycleDayProvider()) { entry in
            CycleDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Cycle Day")
        .description("Shows your current cycle day.")
        .supportedFamilies([.systemSmall])
    }
}
