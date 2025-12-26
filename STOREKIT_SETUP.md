# StoreKit Purchase Setup Guide

This guide explains how to set up in-app purchases for AUTOPODCUT using native macOS StoreKit.

## Why StoreKit Instead of Superwall?

Superwall SDK is designed for iOS and requires UIKit, which is not available on macOS. This app uses native StoreKit 2, which works perfectly on macOS and provides full control over the purchase experience.

## Step 1: Set Up Lifetime Product in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app (or create it if needed)
3. Navigate to **Features** → **In-App Purchases**
4. Click the **+** button to create a new in-app purchase
5. Choose **Non-Consumable** (for lifetime purchase)
6. Fill in the product details:
   - **Reference Name**: Lifetime Access
   - **Product ID**: `com.pallagi.autopodcut.lifetime` (must match exactly)
   - **Price**: Set to $21.99 USD
   - **Display Name**: Lifetime Access
   - **Description**: Unlock all premium features with lifetime access

## Step 2: Product ID Configuration

The product ID is already configured in `StoreManager.swift`:

```swift
let lifetimeProductID = "com.pallagi.autopodcut.lifetime"
```

Make sure this matches exactly with the Product ID in App Store Connect.

## Step 3: Enable Capabilities

1. In Xcode, select your project
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **In-App Purchase** capability

## Step 4: Test the Purchase Flow

1. Build and run your app
2. You'll see the purchase screen automatically after answering the two questions
3. The purchase screen shows "Unlock for a Lifetime for $21.99 USD" with Apple Pay button
4. In sandbox testing, use a test user account from App Store Connect
5. Once purchased, the purchase screen will be skipped on future launches

## How It Works

**Navigation Flow:**
1. **Screen 1**: Audio question (always shown)
2. **Screen 2**: Video question (always shown)
3. **Screen 3**: Lifetime purchase screen (only shown if NOT purchased)
4. **Screen 4**: Auto Cut functionality screen

**Purchase System:**
- **StoreManager**: Manages product loading, purchases, and purchase status
- **LifetimePurchaseView**: Displays the lifetime purchase option with Apple Pay integration
- **Purchase Status**: Automatically checks `storeManager.isPremiumUnlocked` to skip purchase screen if already purchased

**Apple Pay Integration:**
- StoreKit 2 automatically handles Apple Pay on macOS
- The purchase button is styled to match Apple Pay appearance
- Transactions are processed securely through Apple's payment system

## Features Included

✅ Native macOS StoreKit 2 implementation
✅ Product loading and display
✅ Purchase handling
✅ Restore purchases functionality
✅ Transaction verification
✅ Purchase status tracking

## Customizing the Purchase View

Edit `PurchaseView.swift` to customize:
- Layout and styling
- Product descriptions
- Button appearance
- Error handling

## Testing

1. Use sandbox test accounts from App Store Connect
2. Test both purchase and restore flows
3. Verify transaction handling works correctly

For more information, see [Apple's StoreKit documentation](https://developer.apple.com/documentation/storekit).

