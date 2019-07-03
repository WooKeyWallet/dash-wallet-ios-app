//
//  SendViewModel.swift


import UIKit

class SendViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    public var navigationTitle: String {
        return wallet.token + " " + LocalizedString(key: "send.title.suffix", comment: "")
    }
    
    public var walletName: String {
        return wallet.label
    }
    

    // MARK: - Properties (Private)
    
    private let wallet: TokenWallet
    private let dsWallet: DSWallet
    private let account: DSAccount
    
    private var sendValid: Bool {
        guard let amt = amount else { return false }
        return addressState.value.count > 0 && amt > 0
    }
    
    private var isAllin: Bool = false
    
    private var payment: DSPaymentRequest?
    
    private var amount: UInt64? {
        didSet {
            guard let amount = amount else { return }
            payment?.amount = amount
            priceState.value = Helper.priceForDash(amount)
        }
    }
    
    // MARK: - Properties (Lazy)
    
    lazy var pushState = { Postable<UIViewController>() }()
    lazy var popState = { Postable<Int>() }()
    
    lazy var sendState = { return Observable<Bool>(false) }()
    
    lazy var addressState = { return Observable<String>("") }()
    lazy var amountState = { return Observable<String>("") }()
    lazy var priceState = { return Observable<String>("") }()
    lazy var feeState = { return Observable<String>("") }()
    
    
    // MARK: - Life Cycle
    
    init(wallet: TokenWallet) {
        self.wallet = wallet
        self.dsWallet = wallet.onWallet as! DSWallet
        self.account = dsWallet.accounts.first as! DSAccount
        super.init()
    }
    
    func configureHeader(_ header: SendViewHeader) {
        header.configureModels(model: (wallet.icon, walletName, "\(wallet.amount) \(wallet.token)", wallet.price))
        WalletService.shared.refreshState.observe(header) { (_, header) in
            guard let wallet = WalletService.shared.activeDSWallet()?.getTokenWallet() else { return }
            DispatchQueue.main.async {
                header.configureModels(model: (wallet.icon, wallet.label, "\(wallet.amount) \(wallet.token)", wallet.price))
            }
        }
    }
    
    func configureConfirm(_ view: SendConfirmView, sendModel: SendModel) {
        let feeStr = Helper.amountForDash(Int64(sendModel.fee))
        let model = SendDetail.init(tokenIcon: wallet.icon,
                                    amount: amountState.value,
                                    fee: feeStr,
                                    price: priceState.value,
                                    token: wallet.token,
                                    address: addressState.value)
        view.configureModel(model: model)
    }
    
    deinit {
    }
    
    
    /// Actions
    
    func allin() {
        self.amount = account.maxOutputAmount(usingInstantSend: payment?.requestsInstantSend ?? false)
        self.amountState.value = Helper.amountForDash(Int64(amount ?? 0))
        sendState.value = sendValid
    }
    
    func toSelectAddress() -> UIViewController {
        let vc = AddressBooksController.init()
        vc.didSelected = {
            [unowned self] address in
            self.inputAddress(address)
            self.addressState.value = address
            self.sendState.value = self.sendValid
            if WalletService.shared.validAddress(string: address) != nil {
                self.payment = WalletService.shared.paymentRequest(address)
                if let amount = self.amount {
                    self.payment?.amount = amount
                }
            }
        }
        return vc
    }
    
    
    /// Inputs
    
    func inputAddress(_ text: String) {
        self.addressState.value = text
        self.sendState.value = sendValid
        if WalletService.shared.validAddress(string: text) != nil {
            payment = WalletService.shared.paymentRequest(text)
        }
    }
    
    func inputAmount(_ text: String) {
        guard text.count > 0 else {
            amount = nil
            amountState.value = ""
            self.sendState.value = false
            return
        }
        let inputAmount = DSPriceManager.sharedInstance().amount(forDashString: text)
        amount = UInt64(inputAmount)
        amountState.value = text
        self.sendState.value = sendValid
    }
    
    
    func toScan() -> UIViewController {
        let vc = QRCodeScanViewController()
        vc.resultHandler = {
            [unowned self] (results, scanViewController) in
            if results.count > 0 {
                let payReq = WalletService.shared.paymentRequest(results.first?.strScanned ?? "")
                self.addressState.value = payReq.paymentAddress
                self.payment = payReq
                if payReq.amount != 0 {
                    self.amount = payReq.amount
                    self.amountState.value = Helper.amountForDash(Int64(payReq.amount))
                } else if let amount = self.amount {
                    self.payment?.amount = amount
                }
                self.sendState.value = self.sendValid
            } else {
                HUD.showError(LocalizedString(key: "not_recognized", comment: ""))
            }
            scanViewController.navigationController?.popViewController(animated: true)
        }
        return vc
    }
    
    
    func toConfirm(sendModel: SendModel) -> UIViewController {
        return SendConfirmViewController(viewModel: self, model: sendModel)
    }
    
    func send() {
        guard let req = self.payment, req.isValid else {
            HUD.showError(LocalizedString(key: "send.create.failure", comment: ""))
            return
        }
        guard amount! <= account.maxOutputAmount(usingInstantSend: req.requestsInstantSend) else {
            HUD.showError(LocalizedString(key: "send.limit.max", comment: ""))
            return
        }
        if req.r != nil && req.r.count > 0 {
            HUD.showHUD()
            DSPaymentRequest.fetch(req.r, scheme: req.scheme, on: WalletService.shared.chain, timeout: 20) { (request, error) in
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    if let err = error as NSError? {
                        HUD.showError(err.localizedDescription)
                    } else {
                        self.createTx(request: request!)
                    }
                }
            }
        } else {
            self.createTx(request: req.protocolRequest)
        }
    }
    
    private func createTx(request: DSPaymentProtocolRequest) {
        guard let amount = amount else { return }
        WalletService.shared.createTransaction(request: request, amount: amount, account: account) {
        [weak self] (tx, address, amount, fee) in
            guard let strongSelf = self else { return }
            let model = SendModel(tx: tx, address: address, amount: amount, fee: fee, request: request)
            DispatchQueue.main.async {
                strongSelf.pushState.newState(strongSelf.toConfirm(sendModel: model))
            }
        }
    }
    
    func commitTx(send: SendModel) {
        WalletService.shared.publishTransaction(tx: send.tx, request: send.request, amount: send.amount, account: account, address: send.address) { [weak self] in
            HUD.showSuccess(LocalizedString(key: "send.success", comment: ""))
            self?.popState.newState(2)
        }
    }
}
