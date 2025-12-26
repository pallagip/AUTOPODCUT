//
//  PurchaseView.swift
//  AUTOPODCUT
//
//  Native macOS purchase screen using StoreKit
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Unlock Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Get access to all premium features")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Products List
            if storeManager.isLoading {
                ProgressView("Loading products...")
                    .padding()
            } else if storeManager.products.isEmpty {
                Text("No products available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(storeManager.products, id: \.id) { product in
                            ProductRow(product: product, storeManager: storeManager) {
                                isPurchasing = true
                                purchaseError = nil
                            } onError: { error in
                                purchaseError = error
                                isPurchasing = false
                            } onSuccess: {
                                isPurchasing = false
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Error message
            if let error = purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Restore button
            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .buttonStyle(.borderless)
            .foregroundColor(.blue)
            .padding(.bottom, 8)
            
            Spacer()
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ProductRow: View {
    let product: Product
    let storeManager: StoreManager
    let onPurchaseStart: () -> Void
    let onError: (String) -> Void
    let onSuccess: () -> Void
    
    @State private var isPurchasing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Button(action: {
                Task {
                    await purchaseProduct()
                }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isPurchasing ? "Processing..." : "Subscribe")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isPurchasing || storeManager.isPremiumUnlocked)
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func purchaseProduct() async {
        isPurchasing = true
        onPurchaseStart()
        
        do {
            _ = try await storeManager.purchase(product)
            onSuccess()
        } catch {
            if case StoreError.userCancelled = error {
                // User cancelled, don't show error
            } else {
                onError(error.localizedDescription)
            }
            isPurchasing = false
        }
    }
}

