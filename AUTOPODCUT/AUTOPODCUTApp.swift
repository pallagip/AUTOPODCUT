//
//  AUTOPODCUTApp.swift
//  AUTOPODCUT
//
//  Created by Patrik Pallagi on 2025. 12. 24..
//

import SwiftUI
import StoreKit

@main
struct AUTOPODCUTApp: App {
    @StateObject private var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
                .task {
                    // Load products on app launch
                    await storeManager.loadProducts()
                }
        }
    }
}
