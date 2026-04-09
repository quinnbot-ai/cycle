import SwiftUI

struct ProBadge: View {
    var body: some View {
        Label("Pro", systemImage: "lock.fill")
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(CycleTheme.secondaryColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(CycleTheme.secondaryColor.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    ProBadge()
        .padding()
}
