

import UIKit
import StoreKit

extension SKProduct {
    var localizedCurrencyPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }

    var title: String? {
        switch productIdentifier {
        case IAPManager.shared.YEAR_MEMBERSHIP_PRODUCT_ID:
            return "Yearly"
        default:
            return nil
        }
    }
}
