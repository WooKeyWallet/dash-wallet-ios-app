//
//  AssetsTokenViewModel.swift


import UIKit

class AssetsTokenViewModel: NSObject {
    
    public var title: String {
        return asset.token
    }

    // MARK: - Properties (Lazy)
    
    lazy var conncetingState = { return Postable<Bool>() }()
    
    lazy var progressState = { return Postable<CGFloat>() }()
    
    lazy var statusTextState = { return Postable<String>() }()
    
    lazy var balanceState = { return Postable<String>() }()
    
    lazy var priceState = { return Postable<String>() }()
    
    lazy var historyState = { return Postable<[[TableViewSection]]>() }()
    
    
    lazy var sendState = { return Observable<Bool>(false) }()
    lazy var reciveState = { return Observable<Bool>(true) }()
    lazy var refreshState = { return Observable<Bool>(false) }()
    
    
    // MARK: - Properties (Private)
    
    private let asset: Assets
    private let _wallet: TokenWallet
    
    
    // MARK: - Life Cycle
    
    init(asset: Assets) {
        self.asset = asset
        self._wallet = asset.wallet ?? TokenWallet()
        super.init()
    }
    
    func configure(assetsView: AssetsTokenView) {
        assetsView.tokenIconView.image = asset.icon
        assetsView.balanceLabel.text = asset.balance
        assetsView.priceLabel.text = _wallet.price
        assetsView.progressBar.progress = 0
        assetsView.tokenAddress.text = _wallet.address
        let blockWallet = self._wallet
        WKDefaults.shared.receiveAddressIndexState.observe(assetsView.tokenAddress) { (walletId, label) in
            guard walletId == blockWallet.id, let address = blockWallet.onWallet?.receiveAddress else { return }
            label.text = address
        }
    }
    
    func synchronize() {
        
        let syncingPreffix = LocalizedString(key: "assets.sync.progress.preffix", comment: "")
        let syncFinishText = LocalizedString(key: "assets.sync.success", comment: "")
        
        let service = WalletService.shared
        
        service.connectingState.observe(self) { (value, _Self) in
            _Self.conncetingState.newState(value)
            if value {
                _Self.statusTextState.newState(LocalizedString(key: "assets.connect.ing", comment: ""))
            } else {
                let syncings = service.syncingState.value
                let text = syncings.finished ? syncFinishText : syncingPreffix + syncings.leftBlocksString
                _Self.statusTextState.newState(text)
            }
        }
        
        service.syncingState.observe(self) { (syncings, _Self) in
            guard !service.connectingState.value else { return }
            _Self.progressState.newState(syncings.progress)
            if syncings.finished {
                _Self.statusTextState.newState(syncFinishText)
            } else {
                _Self.statusTextState.newState(syncingPreffix + syncings.leftBlocksString)
            }
        }
        
        service.syncFailedState.observe(self) { (_, _Self) in
            _Self.conncetingState.newState(false)
            _Self.statusTextState.newState(LocalizedString(key: "assets.connect.failure", comment: ""))
        }
        
        service.syncFinishedState.observe(self) { (_, _Self) in
            _Self.conncetingState.newState(false)
            _Self.progressState.newState(1)
            _Self.statusTextState.newState(syncFinishText)
            _Self.sendState.value = true
        }
        
        service.balanceState.observe(self) { (_, _Self) in
            guard let wallet = service.activeDSWallet()?.getTokenWallet() else { return }
            _Self.balanceState.newState(wallet.amount)
            _Self.priceState.newState(wallet.price)
            _Self.fetchData()
        }
        
        service.transactionState.observe(self) { (_, _Self) in
            _Self.fetchData()
        }
        
        service.sendableState.observe(self) { (newValue, _Self) in
            guard _Self.sendState.value != newValue else { return }
            _Self.sendState.value = newValue
        }
        
        fetchData()
    }
    
    private func fetchData() {
        DispatchQueue.global().async {
            let allList = WalletService.shared.allTransiactions()
            let mapToRowList = {
                (list: [Transaction]) -> [TableViewRow] in
                return list.map({
                    let model = $0
                    var row = TableViewRow(TransactionListCellFrame(model: model), cellType: TransactionListCell.self, rowHeight: 0)
                    row.actionHandler = {
                    [unowned self] _ in
                        mainTask({
                            self.toTransaction(model)
                        })
                    }
                    return row
                })
            }
            let allRows = mapToRowList(allList)
            let receiveRows = mapToRowList(allList.filter({ $0.type == .in }))
            let sendRows = mapToRowList(allList.filter({ $0.type == .out }))
            let data = [
                [TableViewSection(allRows),],
                [TableViewSection(receiveRows),],
                [TableViewSection(sendRows),],
            ]
            self.historyState.newState(data)
        }
    }
    
    deinit {
        dPrint("\(#function) ================================= \(self.classForCoder)")
    }
    
    
    // MARk: - Methods (Public)
    
    func refresh() {
        WalletService.shared.refreshScan()
    }
    
    func toTransaction(_ model: Transaction) {
        let vc = TransactionDetailController(transaction: model)
        AppManager.default.rootViewController?.pushViewController(vc, animated: true)
    }
    
    func toSend() -> UIViewController {
        let viewModel = SendViewModel(wallet: _wallet)
        let vc = SendViewController(viewModel: viewModel)
        return vc
    }
    
    func toReceive() -> UIViewController {
        let viewModel = ReceiveViewModel(wallet: _wallet)
        let vc = ReceiveViewController(viewModel: viewModel)
        return vc
    }
    
    func copyAddress() {
        UIPasteboard.general.string = _wallet.onWallet?.receiveAddress
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
}
