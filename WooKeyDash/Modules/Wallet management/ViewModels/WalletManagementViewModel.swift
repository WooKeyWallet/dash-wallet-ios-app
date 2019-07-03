//
//  WalletManagementViewModel.swift


import UIKit

class WalletManagementViewModel: NSObject {
    
    // MARK: - Properties (Lazy)
    

    // MARK: - Life Cycles
    
    override init() {
        super.init()
        
    }
    
    // MARK: - Methods (Public)
    
    public func updateActive(_ walletId: String) {
        WalletService.shared.updateActive(walletId)
        guard
            let rootViewController = AppManager.default.rootViewController,
            let tabBarController = rootViewController.rootViewController as? TabBarController
        else {
            return
        }
        tabBarController.tab = .assets
        rootViewController.popViewController(animated: true)
    }
}
