//
//  Common.swift


import Foundation

// MARK: -

public enum WalletCreateStyle: Int {
    case new
    case recovery
}

public enum Token: String {
    case dash = "Dash"
}

public enum WooKeyURL: String {
    
    case serviceBook = "https://wallet.wookey.io/service-docs/app.html"
    case moreNodes = "https://wallet.wookey.io/monero-nodes/app.html"
    
    var url: URL {
        return URL(string: rawValue)!
    }
}
