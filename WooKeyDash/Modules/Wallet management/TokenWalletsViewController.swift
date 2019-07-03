//
//  TokenWalletViewController.swift


import UIKit

class TokenWalletsViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 144 }
    
    
    // MARK: - Properties (Private)
        
    private let viewModel: WalletManagementViewModel
    

    // MARK: - Life Cycles
    
    init(viewModel: WalletManagementViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
        }
        
        do /// Subviews
        {
            tableView.separatorStyle = .none
            tableView.register(cellType: TokenWalletViewCell.self)
            tableView.tableHeaderView = {
                () -> UIView in
                let header = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 5))
                header.backgroundColor = UIColor.clear
                return header
            }()
            tableView.snp.remakeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11, *) {
            let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
            tableView.contentInset.bottom = 58 + safeAreaInsets.bottom + 15
        } else {
            tableView.contentInset.bottom = 58 + 15
        }
    }
    
    func loadData() {
        DispatchQueue.global().async {
            let wallets: [TokenWallet] = WalletService.shared.getWallets()
            self.dataSource = [
                TableViewSection.init(wallets.map({
                    var row = TableViewRow.init($0, cellType: TokenWalletViewCell.self, rowHeight: 0)
                    let __model = $0
                    let walletId = $0.id
                    row.actionHandler = {
                        [unowned self] action in
                        guard let action = action as? TokenWalletViewCell.Action else { return }
                        switch action {
                        case .active:
                            if !__model.in_use {
                                self.updateActive(walletId: walletId)
                            }
                        case .detail:
                            let viewModel = TokenWalletDetailViewModel.init(tokenWallet: __model)
                            let vc = TokenWalletDetailViewController.init(viewModel: viewModel)
                            AppManager.default.rootViewController?.pushViewController(vc, animated: true)
                        }
                        
                    }
                    return row
                }))
            ]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Methods (Private)
    
    private func updateActive(walletId: String) {
        viewModel.updateActive(walletId)
    }

}
