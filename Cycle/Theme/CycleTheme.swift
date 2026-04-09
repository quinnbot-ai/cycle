import SwiftUI

enum CycleTheme {
    // MARK: - Colors
    static let primaryColor = Color(light: .init(hex: 0xD4A0A0), dark: .init(hex: 0xDEB0B0))
    static let backgroundColor = Color(light: .init(hex: 0xFAF7F5), dark: .init(hex: 0x1C1618))
    static let textColor = Color(light: .init(hex: 0x3D3338), dark: .init(hex: 0xF0EBE8))
    static let secondaryColor = Color(light: .init(hex: 0xB8A9C9), dark: .init(hex: 0xC4B5D5))
    static let fertileColor = Color(light: .init(hex: 0xA8BFA0), dark: .init(hex: 0xB4CBB0))

    // MARK: - Flow Gradient
    static func flowColor(for level: FlowLevel) -> Color {
        switch level {
        case .none: .clear
        case .spotting: Color(hex: 0xE8C4C4)
        case .light: Color(hex: 0xD4A0A0)
        case .medium: Color(hex: 0xC07878)
        case .heavy: Color(hex: 0xA05050)
        }
    }

    // MARK: - Typography
    static let headerFont: Font = .system(.title2, design: .rounded, weight: .semibold)
    static let subheaderFont: Font = .system(.headline, design: .rounded, weight: .medium)
    static let bodyFont: Font = .system(.body, design: .default)
    static let captionFont: Font = .system(.caption, design: .default)

    // MARK: - Layout
    static let cornerRadius: CGFloat = 16
    static let pillCornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let gridSpacing: CGFloat = 10
}

// MARK: - Color Hex Init
extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
