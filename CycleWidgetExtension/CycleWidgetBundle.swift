import WidgetKit
import SwiftUI

@main
struct CycleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CycleDayWidget()
    }
}

struct CycleDayWidget: Widget {
    let kind = "CycleDayWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            Text("Day 1")
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Cycle Day")
        .description("Shows your current cycle day.")
        .supportedFamilies([.systemSmall])
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) { completion(SimpleEntry(date: Date())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .atEnd))
    }
}
