//
//  ViewModel.swift
//  IAPDemo
//
//  Created by Ahmad Qureshi on 05/05/23.
//

import StoreKit

class ViewModel: ObservableObject {
    @Published var products: [SKProduct] = []
    @Published var showSuccessAlert: Bool = false
    var alertMessage: String = ""
    private var inAppPurchaseManager = IAPManager.shared.self
    
    
    func fetchProducts() {
        inAppPurchaseManager.initialize()
        inAppPurchaseManager.fetchAvailableProductsBlock = { (productsArray) in
            DispatchQueue.main.async {
                self.products = productsArray
            }
        }
    }
    
    func handleAlerts() {
        inAppPurchaseManager.purchaseStatusBlock = { [weak self] (type) in
            DispatchQueue.main.async {
                self?.showSuccessAlert.toggle()
                self?.alertMessage = type.message()
            }
            
        }
    }
    
    func purchaseProduct() {
        inAppPurchaseManager.purchaseMyProduct(productIdentifier: inAppPurchaseManager.YEAR_MEMBERSHIP_PRODUCT_ID)
    }
    
    func restorePurhcase() {
        inAppPurchaseManager.restorePurchase()
    }
}

