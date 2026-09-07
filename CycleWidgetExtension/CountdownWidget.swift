import WidgetKit
import SwiftUI

struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), daysUntil: 5, nextDateString: "Apr 15")
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        completion(CountdownEntry(
            date: Date(),
            daysUntil: SharedData.daysUntilNextPeriod,
            nextDateString: SharedData.nextPeriodDateString ?? ""
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let entry = CountdownEntry(
            date: Date(),
            daysUntil: SharedData.daysUntilNextPeriod,
            nextDateString: SharedData.nextPeriodDateString
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let daysUntil: Int?
    let nextDateString: String?
}

struct CountdownWidgetView: View {
    var entry: CountdownEntry

    var body: some View {
        VStack(spacing: 4) {
            if let days = entry.daysUntil, days >= 0 {
                Image(systemName: "drop.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: 0xD4A0A0))
                Text("\(days)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0xD4A0A0))
                Text(days == 1 ? "day until period" : "days until period")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: 0xD4A0A0))
                Text("Not enough data")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct CountdownWidget: Widget {
    let kind = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Period Countdown")
        .description("Days until your next predicted period.")
        .supportedFamilies([.systemSmall])
    }
}
