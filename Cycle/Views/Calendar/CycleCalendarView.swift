import SwiftUI
import SwiftData

struct CycleCalendarView: View {
    @Query(sort: \PeriodEntry.date, order: .forward) private var allEntries: [PeriodEntry]
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false

    private var calendar: Calendar { Calendar.current }

    private var entriesByDate: [Date: PeriodEntry] {
        Dictionary(allEntries.map { ($0.date.startOfDay, $0) }, uniquingKeysWith: { first, _ in first })
    }

    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        return range.compactMap { day in
            calendar.date(from: DateComponents(year: components.year, month: components.month, day: day))
        }
    }

    private var firstWeekday: Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let firstOfMonth = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstOfMonth) - 1
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Button { displayedMonth = displayedMonth.adding(months: -1) } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(displayedMonth.monthYearString)
                        .font(CycleTheme.headerFont)
                    Spacer()
                    Button { displayedMonth = displayedMonth.adding(months: 1) } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .foregroundStyle(CycleTheme.textColor)
                .padding(.horizontal)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(CycleTheme.captionFont)
                            .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(0..<firstWeekday, id: \.self) { _ in
                        Color.clear.frame(height: 44)
                    }

                    ForEach(daysInMonth, id: \.self) { date in
                        let entry = entriesByDate[date.startOfDay]
                        DayCellView(date: date, entry: entry, isToday: date.isToday)
                            .onTapGesture {
                                selectedDate = date
                                showingDayDetail = true
                            }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .background(CycleTheme.backgroundColor)
            .navigationTitle("Calendar")
            .sheet(isPresented: $showingDayDetail) {
                if let date = selectedDate {
                    DayDetailSheet(date: date, existingEntry: entriesByDate[date.startOfDay])
                }
            }
        }
    }
}

private struct DayCellView: View {
    let date: Date
    let entry: PeriodEntry?
    let isToday: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(date.dayOfMonth)")
                .font(.system(size: 16, weight: isToday ? .bold : .regular, design: .rounded))
                .foregroundStyle(isToday ? CycleTheme.primaryColor : CycleTheme.textColor)

            if let entry, entry.flowLevel.isFlow {
                Circle()
                    .fill(CycleTheme.flowColor(for: entry.flowLevel))
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(isToday ? CycleTheme.primaryColor.opacity(0.08) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
