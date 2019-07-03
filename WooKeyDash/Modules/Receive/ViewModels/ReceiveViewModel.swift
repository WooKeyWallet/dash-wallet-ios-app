//
//  ReceiveViewModel.swift


import UIKit

class ReceiveViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    public var navigationTitle: String {
        return wallet.token + LocalizedString(key: "receive.title.suffix", comment: "")
    }
    
    public var receiveTips: String {
        return LocalizedString(key: "receive.address.tips", comment: "").replacingOccurrences(of: "$0", with: wallet.token)
    }
    
    
    // MARK: - Properties (Private)
    
    private let wallet: TokenWallet
    
    private var amount: Int64? {
        didSet {
            if let a = amount, let aStr = DSPriceManager.sharedInstance().attributedString(forDashAmount: a)?.string {
                amountState.value = "\(aStr) \(wallet.token)"
                priceState.value = Helper.priceForDash(UInt64(a))
            } else {
                amountState.value = ""
                priceState.value = ""
            }
            generateQRCode(wallet.onWallet?.receiveAddress ?? "")
        }
    }
    
    // MARK: - Properties (Lazy)
    
    lazy var qrcodeState = { Observable<UIImage?>(nil) }()
    lazy var addressState = { Observable<String>("") }()
    lazy var amountState = { Observable<String>("") }()
    lazy var priceState = { Observable<String>("") }()
    
    
    // MARK: - Life Cycle
    
    init(wallet: TokenWallet) {
        self.wallet = wallet
        super.init()
        self.addressState.value = wallet.address
        self.generateQRCode(wallet.address)
    }
    
    func configure(receiveView: ReceiveView) {
        receiveView.addressTipLabel.text = receiveTips
        WKDefaults.shared.receiveAddressIndexState.observe(self) { (walletId, _Self) in
            guard walletId == _Self.wallet.id, let address = _Self.wallet.onWallet?.receiveAddress else { return }
            _Self.addressState.value = address
            _Self.generateQRCode(address)
        }
    }
    
    
    // MARK: - Methods (Prviate)
    
    private func generateQRCode(_ address: String) {
        let request = WalletService.shared.paymentRequest(address)
        if let amount = amount {
            request.amount = UInt64(amount)
        }
//        let icon = UIImage(named: "dash_qrcode_icon")
        Helper.generateQRCode(content: request.string, icon: nil) { (qrcode) in
            self.qrcodeState.value = qrcode
        }
    }
    

    // MARK: - Methods (Public)
    
    public func add(amount: Int64) {
        self.amount = amount
    }
    
    public func removeAmount() {
        self.amount = nil
    }
    
    public func showHideAddress(_ isHidden: Bool) {
        let address = wallet.onWallet?.receiveAddress ?? ""
        addressState.value = isHidden ? String(address.map({ _ in return "*" })) : address
    }
    
    public func copyAddress() {
        UIPasteboard.general.string = wallet.onWallet?.receiveAddress
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    public func toSubAddress() -> UIViewController? {
        guard let onWallet = wallet.onWallet else { return nil }
        let viewModel = SubAddressViewModel(wallet: onWallet)
        return SubAddressViewController(viewModel: viewModel)
    }
    
}
