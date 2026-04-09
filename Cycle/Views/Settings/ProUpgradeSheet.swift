import SwiftUI

struct ProUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let storeManager: StoreManager

    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(CycleTheme.primaryColor)

                    Text("Cycle Pro")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(CycleTheme.textColor)

                    Text("One-time purchase. No subscription.")
                        .font(CycleTheme.bodyFont)
                        .foregroundStyle(CycleTheme.textColor.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Cycle length trends & analytics")
                    FeatureRow(icon: "calendar.badge.clock", text: "Luteal & follicular phase estimates")
                    FeatureRow(icon: "plus.circle", text: "Custom symptoms")
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        isPurchasing = true
                        Task {
                            _ = try? await storeManager.purchase()
                            isPurchasing = false
                            if storeManager.isPro { dismiss() }
                        }
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        } else {
                            Text("Unlock Pro — \(storeManager.proProduct?.displayPrice ?? "$4.99")")
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .foregroundStyle(.white)
                    .background(CycleTheme.primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
                    .disabled(isPurchasing)

                    Button("Restore Purchase") {
                        Task { await storeManager.restorePurchases() }
                    }
                    .font(CycleTheme.captionFont)
                    .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(CycleTheme.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(CycleTheme.primaryColor)
                .frame(width: 28)
            Text(text)
                .font(CycleTheme.bodyFont)
                .foregroundStyle(CycleTheme.textColor)
        }
    }
}
