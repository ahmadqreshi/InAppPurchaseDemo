
import StoreKit
import Foundation

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    let YEAR_MEMBERSHIP_PRODUCT_ID = "com.learnapp.learnapp.yearlySubscription" // product id set on app store connect
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    fileprivate var pendingFetchProduct: String!
    var fetchAvailableProductsBlock : (([SKProduct]) -> Void)? = nil
    var purchaseStatusBlock: ((IAPManagerAlertType) -> Void)?
    
    func initialize() {
        fetchAvailableProducts()
    }
    
    func fetchAvailableProducts() {
        productsRequest.cancel()
        // Put here your IAP Products ID’s
        let productIdentifiers = NSSet(objects: YEAR_MEMBERSHIP_PRODUCT_ID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseMyProduct(productIdentifier: String) {
        if iapProducts.isEmpty {
            pendingFetchProduct = productIdentifier
            fetchAvailableProducts()
            return
        }
        
        if canMakePurchases() {
            iapProducts.forEach { product in
                if product.productIdentifier == productIdentifier {
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                }
            }
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    //MARK: - Verify Payment on the server
    private func verifyPayment() {
        let request = SKReceiptRefreshRequest()
        request.start()
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            // Receipt file not found
            return
        }
        // Load the receipt data from the file
        guard let receiptData = try? Data(contentsOf: receiptURL) else {
            // Failed to load receipt data
            return
        }
        // Parse the receipt data as JSON
        guard let receiptJSON = try? JSONSerialization.jsonObject(with: receiptData, options: []) as? [String: Any] else {
            // Failed to parse receipt data as JSON
            return
        }

        debugPrint(receiptJSON) // send this data to server for validation
        // if response is success from the server
        purchaseStatusBlock?(.purchased)
    }
    
}

extension IAPManager: SKProductsRequestDelegate {
    // MARK: — REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            fetchAvailableProductsBlock?(response.products)
        }
    }
    func request(_ request: SKRequest, didFailWithError error:
                 Error) {
        debugPrint("Error load products", error)
    }
}


extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        if let lastTransaction = queue.transactions.last {
//            debugPrint(lastTransaction.transactionIdentifier!)
//        }
        purchaseStatusBlock?(.restored)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        purchaseStatusBlock?(.failed)
    }
    
    // MARK: - IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    if let transaction = transaction as? SKPaymentTransaction {
                        verifyPayment()
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.failed)
                case .restored:
                    if let transaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                default: break
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        if canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            return true
        } else {
            return false
        }
    }
}
