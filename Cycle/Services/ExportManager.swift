import Foundation

enum ExportManager {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func generateCSV(from entries: [PeriodEntry]) -> String {
        var lines: [String] = []
        lines.append("Date,Flow,Mood,Symptoms,Notes")

        let sorted = entries.sorted { $0.date < $1.date }
        for entry in sorted {
            let date = dateFormatter.string(from: entry.date)
            let flow = entry.flowLevel.label
            let mood = entry.mood.label
            let symptoms = entry.symptoms.map(\.label).sorted().joined(separator: "; ")
            let notes = csvEscape(entry.notes ?? "")
            lines.append("\(date),\(flow),\(mood),\(csvEscape(symptoms)),\(notes)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    static func exportURL(from entries: [PeriodEntry]) -> URL? {
        let csv = generateCSV(from: entries)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("Cycle-Export-\(dateFormatter.string(from: Date())).csv")
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
