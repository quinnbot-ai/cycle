import Foundation
import StoreKit
import Observation

@MainActor @Observable
final class StoreManager {
    static let proProductID = "com.cycleapp.pro"

    private(set) var proProduct: Product?
    private(set) var isPro = false
    private nonisolated(unsafe) var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task { await listenForTransactions() }
        Task { await loadProducts() }
        Task { await checkEntitlement() }
    }

    deinit {
        updateTask?.cancel()
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.proProductID])
            proProduct = products.first
        } catch {
            // Product loading failed
        }
    }

    func purchase() async throws -> Bool {
        guard let product = proProduct else { return false }
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            isPro = true
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.proProductID {
                isPro = true
                return
            }
        }
        isPro = false
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await checkEntitlement()
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                isPro = transaction.productID == Self.proProductID
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
