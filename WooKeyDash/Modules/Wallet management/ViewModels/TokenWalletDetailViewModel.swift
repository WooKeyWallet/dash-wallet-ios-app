//
//  TokenWalletDetailViewModel.swift


import UIKit

class TokenWalletDetailViewModel: NSObject {
    
    // MARK: - Properties (Private)
    
    private let tokenWallet: TokenWallet
    
    
    // MARK: - Properties (Lazy)
    
    lazy var reloadDataState = { Postable<[TableViewSection]>() }()
    
    
    // MARK: - Life Cycle

    required init(tokenWallet: TokenWallet) {
        self.tokenWallet = tokenWallet
        super.init()
    }
    
    func configure() {
        postData()
        WKDefaults.shared.receiveAddressIndexState.observe(self) { (walletId, _Self) in
            guard walletId == _Self.tokenWallet.id else { return }
            _Self.postData()
        }
    }
    
    private func postData() {
        DispatchQueue.global().async {
            let address = self.tokenWallet.onWallet?.receiveAddress ?? self.tokenWallet.address
            /// header
            let headerData = TokenWalletDetail(token: self.tokenWallet.token, assets: self.tokenWallet.amount, address: address, price: self.tokenWallet.price)
            let row_0_0 = TableViewRow.init(headerData, cellType: TokenWalletDeailHeaderCell.self, rowHeight: /*146*/127)
            var section0 = TableViewSection.init([row_0_0])
            section0.headerHeight = 0.01
            section0.footerHeight = 10
            
            /// dataSource
            let modelList: [[TokenWalletDetaillViewCellModel]] = [
                [],
                [
                    (title: LocalizedString(key: "wallet.detail.name", comment: ""), detail: self.tokenWallet.label, showArrow: false),
                    (title: LocalizedString(key: "wallet.subAddress.title", comment: ""), detail: address, showArrow: true),
                    (title: LocalizedString(key: "wallet.detail.import.seed", comment: ""), detail: "", showArrow: true),
                ],
            ]
            let row_1_0 = TableViewRow.init(modelList[1][0], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            var row_1_1 = TableViewRow.init(modelList[1][1], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            row_1_1.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toSubAddress()
                }
            }
            var row_1_2 = TableViewRow.init(modelList[1][2], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            row_1_2.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toExportSeed()
                }
            }
            var section1 = TableViewSection.init([row_1_0, row_1_1, row_1_2])
            section1.headerHeight = 0.01
            section1.footerHeight = 10
            
            var row_2_0 = TableViewRow.init(nil, cellType: TokenWalletDeleteCell.self, rowHeight: 52)
            row_2_0.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toDeleteWallet()
                }
            }
            var section2 = TableViewSection.init([row_2_0])
            section2.headerHeight = 0.01
            section2.footerHeight = 10
            DispatchQueue.main.async {
                self.reloadDataState.newState([section0, section1, section2])
            }
        }
    }
    
    
    // MARK: - Methods (Public)
    
    public func getNavigationTitle() -> String {
        return tokenWallet.label
    }
    
    
    // MARK: - Methods (Private)
    
    private func toSubAddress() {
        guard let onWallet = tokenWallet.onWallet else { return }
        let viewModel = SubAddressViewModel(wallet: onWallet)
        let vc = SubAddressViewController(viewModel: viewModel)
        AppManager.default.rootViewController?.pushViewController(vc, animated: true)
    }
    
    private func showPasswordTips() {
        let alert = WKAlertController.init()
        alert.alertTitle = LocalizedString(key: "pwdTips", comment: "")
        alert.msgAlignment = .center
        AppManager.default.rootViewController?.definesPresentationContext = true
        AppManager.default.rootViewController?.present(alert, animated: false, completion: nil)
    }
    
    private func toExportSeed() {
        WKAuthenticator.shared.request { [unowned self] (success) in
            guard success else { return }
            let dsWallet = WalletService.shared.getDSWallet(by: self.tokenWallet.id)
            let vc = ExportWalletSeedViewController()
            let seed = dsWallet?.seedPhraseIfAuthenticated()
            vc.seedString = seed
            AppManager.default.rootViewController?.pushViewController(vc, animated: true)
        }
    }
    
    private func toDeleteWallet() {
        guard !tokenWallet.in_use else {
            HUD.showError(LocalizedString(key: "delete.wallet.onlineError", comment: ""))
            return
        }
        WKAuthenticator.shared.request { [unowned self] (success) in
            guard success else { return }
            HUD.showHUD()
            safeTask({
                WalletService.shared.deleteWallet(self.tokenWallet)
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    AppManager.default.rootViewController?.popViewController(animated: true)
                }
            })
        }
    }
}
