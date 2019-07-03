//
//  ImportWalletViewModel.swift


import UIKit


class ImportWalletViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    lazy var creationDateState = { Postable<String>() }()
    
    lazy var nextState = { Observable<Bool>(false) }()
    
    // MARK: - Properties (Private)
    
    private let walletName: String
    
    private var seedString: String = "" {
        didSet {
            nextState.value = seedString.count > 0
        }
    }
    
    private var creationDate = Date(timeIntervalSince1970: 0) {
        didSet {
            self.creationDateState.newState(creationDate.toString())
        }
    }
    
    // MARK: - Life Cycles
    
    required init(walletName: String) {
        self.walletName = walletName
        super.init()
    }
    
    // MARK: - Methods (Public)
    
    public func seedInput(text: String) {
        self.seedString = text
    }
    
    public func showDatePicker() -> ZZDatePicker {
        var dateMode = ZZDatePicker.Mode()
        dateMode.minimumDate = Date.init(timeIntervalSince1970: 1390103681)
        let picker = ZZDatePicker.init(mode: dateMode)
        picker.pickDone = { [unowned self] date in
            self.creationDate = date
        }
        return picker
    }
    
    public func confirm() {
        guard let seed = WalletService.shared.seedVerified(seedString) else {
            HUD.showError(LocalizedString(key: "incorrectSeed", comment: ""))
            return
        }
        guard WalletService.shared.hasWallet else {
            self.recoveryWallet(seed)
            return
        }
        AppManager.default.rootViewController?.showAlert("",
                                                         message: LocalizedString(key: "recovery.rescan.tips", comment: ""),
                                                         cancelTitle: LocalizedString(key: "cancel", comment: ""),
                                                         doneTitle: LocalizedString(key: "confirm", comment: ""),
                                                         doneClousre:
        { [unowned self] in
            self.recoveryWallet(seed)
        })
    }
    
    
    // MARK: - Methods (Private)
    
    
    private func recoveryWallet(_ seed: String) {
        HUD.showHUD()
        safeTask {
            do {
                let hasWallet = WalletService.shared.hasWallet
                let dsWallet = try WalletService.shared.generateWallet(seed, date: self.creationDate)
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
                    
                    if hasWallet {
                        WalletService.shared.rescanSync()
                    } else {
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
