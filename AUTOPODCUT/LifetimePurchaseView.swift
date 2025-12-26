//
//  LifetimePurchaseView.swift
//  AUTOPODCUT
//
//  Lifetime purchase screen with Apple Pay integration
//

import SwiftUI
import StoreKit

struct LifetimePurchaseView: View {
    @ObservedObject var storeManager: StoreManager
    let onPurchaseSuccess: () -> Void
    let onSkip: () -> Void
    
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 12) {
                Text("Unlock for a Lifetime")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                if let product = storeManager.lifetimeProduct {
                    Text(product.displayPrice)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.cyan)
                } else {
                    Text("$21.99 USD")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.cyan)
                }
            }
            .padding(.bottom, 20)
            
            // Price info (shown in header, so this section can be smaller)
            if storeManager.isLoading && storeManager.lifetimeProduct == nil {
                ProgressView("Loading...")
                    .padding(.bottom, 20)
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited video processing")
                FeatureRow(icon: "checkmark.circle.fill", text: "All premium features")
                FeatureRow(icon: "checkmark.circle.fill", text: "Lifetime updates")
                FeatureRow(icon: "checkmark.circle.fill", text: "Priority support")
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            
            // Purchase Button with Apple Pay styling
            if let product = storeManager.lifetimeProduct {
                Button(action: {
                    Task {
                        await purchaseProduct(product)
                    }
                }) {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 18))
                        }
                        
                        Text(isPurchasing ? "Processing..." : "Purchase with Apple Pay")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.6, blue: 1.0),
                                Color(red: 0.0, green: 0.5, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(isPurchasing)
                .padding(.horizontal, 40)
            } else if storeManager.isLoading {
                FuturisticButton(
                    title: "Loading...",
                    isSelected: false,
                    isEnabled: false,
                    action: {}
                )
                .padding(.horizontal, 40)
            } else {
                // Fallback if product not loaded
                Button(action: {
                    Task {
                        await storeManager.loadProducts()
                    }
                }) {
                    Text("Retry Loading")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)
            }
            
            // Error message
            if let error = purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }
            
            // Skip button (optional - remove if you don't want users to skip)
            Button("Continue without purchasing") {
                onSkip()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
    
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil
        
        do {
            let transaction = try await storeManager.purchase(product)
            if transaction != nil {
                // Purchase successful
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onPurchaseSuccess()
                }
            }
        } catch {
            if case StoreError.userCancelled = error {
                // User cancelled - don't show error
                purchaseError = nil
            } else {
                purchaseError = error.localizedDescription
            }
            isPurchasing = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.system(size: 20))
            Text(text)
                .font(.system(size: 16, design: .rounded))
            Spacer()
        }
    }
}

