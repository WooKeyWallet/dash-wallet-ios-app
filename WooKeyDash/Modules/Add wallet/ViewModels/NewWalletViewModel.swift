//   
//   NewWalletViewModel.swift
//   WooKeyDash
//   
//  Created by WooKey Team on 2019/5/23
//   Copyright © 2019 WooKey. All rights reserved.
//   
	

import UIKit

class NewWalletViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    lazy var navItemRightEnable = {
        Observable<Bool>(false)
    }()
    
    lazy var pushState = {
        Postable<UIViewController>()
    }()
    
    
    // MARK: - Properties (Private)
    
    private let walletName: String
    
    private var seedString = "" {
        didSet {
            seed = Seed(sentence: seedString)
        }
    }
    
    private var seed: Seed? {
        didSet {
            navItemRightEnable.value = seed != nil
        }
    }
    
    
    // MARK: - Life Cycles
    
    required init(walletName: String, seedString: String) {
        self.walletName = walletName
        super.init()
        self.seedString = seedString
        self.seed = Seed(sentence: seedString)
    }
    
    func configure(wordListView: WordListView) {
        navItemRightEnable.value = seed != nil
        guard let list = seed?.words else { return }
        wordListView.configure(list)
    }
    
    // MARK: - Methods (Public)
    
    func generateSeed() {
        safeTask {
            
        }
    }
    
    func copySeed() {
        UIPasteboard.general.string = seedString
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    func next() {
        guard let _ = seed else { return }
        let vc = SeedVerifyViewController(viewModel: self)
        pushState.newState(vc)
    }
    
    func getWords() -> [String] {
        return seed?.words ?? []
    }
    
    func createWallet() {
        HUD.showHUD()
        safeTask {
            do {
                let hasWallet = WalletService.shared.hasWallet
                let dsWallet = try WalletService.shared.generateWallet(self.seedString, date: Date())
                WKDefaults.shared.walletId2Names[dsWallet.uniqueID] = self.walletName
                WalletService.shared.updateActive(dsWallet.uniqueID)
                
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    if
                        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
                        let _ = navigationController.viewControllers.first as? UITabBarController
                    {
                        guard let managementVC = navigationController.viewControllers[1] as? WalletManagementViewController else { return }
                        managementVC.loadData()
                        navigationController.popToViewController(managementVC, animated: true)
                    } else {
                        AppManager.default.rootIn()
                    }
                    
                    if !hasWallet {
                        WalletService.shared.startSync()
                    }
                }
            } catch {
                let err = error as! WalletCreateError
                switch err {
                case .exist:
                    HUD.showError(LocalizedString(key: "wallet_invalid", comment: ""))
                case .failure:
                    HUD.showError(LocalizedString(key: "walletCreateError", comment: ""))
                }
            }
        }
    }

}
