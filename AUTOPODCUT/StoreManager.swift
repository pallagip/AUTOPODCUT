//
//  StoreManager.swift
//  AUTOPODCUT
//
//  StoreKit-based purchase manager for macOS
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Lifetime purchase product ID
    let lifetimeProductID = "com.pallagi.autopodcut.lifetime"
    
    // Product IDs array for loading
    var productIDs: [String] {
        [lifetimeProductID]
    }
    
    init() {
        // Listen for transaction updates
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await transaction.finish()
                    await updatePurchasedProducts()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted { $0.price < $1.price }
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return transaction
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("Error restoring purchases: \(error)")
        }
        
        isLoading = false
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // Check if it's our lifetime product or any product we recognize
                if transaction.productID == lifetimeProductID || productIDs.contains(transaction.productID) {
                    purchasedIDs.insert(transaction.productID)
                }
                // Also check all products for compatibility
                if let product = products.first(where: { $0.id == transaction.productID }) {
                    purchasedIDs.insert(product.id)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    var isPremiumUnlocked: Bool {
        purchasedProductIDs.contains(lifetimeProductID) || !purchasedProductIDs.isEmpty
    }
    
    var lifetimeProduct: Product? {
        products.first(where: { $0.id == lifetimeProductID })
    }
}

enum StoreError: Error {
    case failedVerification
    case userCancelled
    case pending
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

