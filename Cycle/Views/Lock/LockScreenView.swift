import SwiftUI

struct LockScreenView: View {
    let lockManager: AppLockManager

    var body: some View {
        ZStack {
            CycleTheme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(CycleTheme.primaryColor)

                Text("Cycle is locked")
                    .font(CycleTheme.subheaderFont)
                    .foregroundStyle(CycleTheme.textColor)

                Button("Unlock") {
                    Task { await lockManager.authenticate() }
                }
                .font(CycleTheme.bodyFont.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(CycleTheme.primaryColor)
                .clipShape(Capsule())
            }
        }
        .task {
            _ = await lockManager.authenticate()
        }
    }
}
