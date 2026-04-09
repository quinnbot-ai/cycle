import Foundation
import SwiftData

@Model
final class CustomSymptom {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date

    init(name: String, icon: String = "star.fill") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
    }
}
