//
//  AssetsViewController.swift


import UIKit

class AssetsViewController: BaseTableViewController {
    
    // MARK: - Properties (Private)
    
    private var wallet: TokenWallet? {
        didSet {
            titleLabel.text = wallet?.token
            titleLabel.sizeToFit()
            header.configure(wallet)
        }
    }
    
    private var assetsList = [Assets]() {
        didSet {
            footer.configure(assetsList)
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var titleLabel = {
        return UILabel()
    }()
    
    private lazy var header = {
        AssetsViewHeader()
    }()
    
    private lazy var footer = {
        AssetsListView(width: view.width)
    }()
    
    
    // MARK: - Life Cycles
    
    override func configureUI() {
        super.configureUI()
        
        do /// Subviews
        {
            navigationItem.titleView = {
                (lab: UILabel) -> UILabel in
                lab.textColor = AppTheme.Color.navigationTitle
                lab.textAlignment = .center
                lab.font = AppTheme.Font.navigationTitle
                return lab
            }(titleLabel)
            tableView.tableHeaderView = header
            tableView.tableFooterView = footer
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "assets_token_manage"), style: .plain, target: self, action: #selector(self.leftBarButtonAction))
            navigationItem.rightBarButtonItem = {
                () -> UIBarButtonItem in
                let btn = UIButton(frame: .zero)
                btn.setImage(UIImage(named: "assets_eye_show"), for: .normal)
                btn.setImage(UIImage(named: "assets_eye_hidden"), for: .selected)
                btn.isSelected = WKDefaults.shared.hiddenAsset
                btn.sizeToFit()
                btn.addTarget(self, action: #selector(self.rightBarButtonAction(_:)), for: .touchUpInside)
                return UIBarButtonItem.init(customView: btn)
            }()
            
            header.copyBtn.addTarget(self, action: #selector(self.copyAction), for: .touchUpInside)
            
            footer.configureHandlers { [unowned self] (index) in
                let viewModel = AssetsTokenViewModel(asset: self.assetsList[index])
                let vc = AssetsTokenViewController(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        do /// Reload datas
        {
            WalletService.shared.activeState.observe(self) { (walletId, strongSelf) in
                let wallet = WalletService.shared.getActiveWallet()
                let assetsList = WalletService.shared.getAssetsList()
                DispatchQueue.main.async {
                    strongSelf.wallet = wallet
                    strongSelf.assetsList = assetsList
                }
            }
            
            WalletService.shared.refreshState.observe(self) { (signal, strongSelf) in
                let wallet = WalletService.shared.getActiveWallet()
                let assetsList = WalletService.shared.getAssetsList()
                DispatchQueue.main.async {
                    strongSelf.wallet = wallet
                    strongSelf.assetsList = assetsList
                }
            }
            
            WKDefaults.shared.receiveAddressIndexState.observe(self) { (walletId, _Self) in
                guard let wallet = WalletService.shared.getActiveWallet(),
                    wallet.id == walletId
                else {
                    return
                }
                let assetsList = WalletService.shared.getAssetsList()
                DispatchQueue.main.async {
                    _Self.wallet = wallet
                    _Self.assetsList = assetsList
                }
            }
        }
    }
    
    
    
    // MARK: - Methods (Action)
    
    @objc private func leftBarButtonAction() {
        let vc = WalletManagementViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func rightBarButtonAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        footer.balanceSecureTextEntryState = btn.isSelected
        WKDefaults.shared.hiddenAsset = btn.isSelected
    }
    
    @objc private func copyAction() {
        guard let address = wallet?.address else { return }
        UIPasteboard.general.string = address
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
}
