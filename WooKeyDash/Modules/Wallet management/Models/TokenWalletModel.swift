//
//  TokenWalletModel.swift


import UIKit

struct TokenWallet {
    var id: String = ""
    var label: String = ""
    var token: String = ""
    var amount: String = ""
    var price: String = ""
    let icon: UIImage? = UIImage(named: "token_icon_Dash")
    var address: String = ""
    var in_use: Bool = false
    
    var onWallet: WalletProtocol?
    
    init() {
        
    }
    
    func getToken() -> Token {
        return Token(rawValue: token) ?? .dash
    }
}
