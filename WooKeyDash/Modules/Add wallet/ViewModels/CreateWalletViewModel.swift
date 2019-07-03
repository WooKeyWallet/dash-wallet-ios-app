//
//  CreateWalletViewModel.swift


import UIKit

class CreateWalletViewModel: NSObject {

    // MARK: - Properties (Public)
    
    lazy var langState = { Observable<DSBIP39Language>(.english) }()
    
    lazy var agreementState = { Observable<Bool>(false) }()
    
    lazy var nextState = { Observable<Bool>(false) }()
    
    lazy var nameTextState = { Observable<String>("") }()
    
    lazy var nameErrorState = { Observable<String?>(nil) }()
    
    lazy var pushState = { Postable<UIViewController>() }()
    
    
    
    // MARK: - Properties (Private)
    
    let style: WalletCreateStyle
    
    private var name: String = ""
    
    private var isNameVaild: Bool {
        get {
            if name.count == 0 {
                return false
            }
            if WKDefaults.shared.walletId2Names.values.contains(name) {
                return false
            }
            return true
        }
    }
    
    
    // MARK: - Life Cycles
    
    required init(style: WalletCreateStyle) {
        self.style = style
        super.init()
    }
    
    
    // MARK: - Methods (Public)
    
    func navigationTitle() -> String {
        switch style {
        case .new:
            return LocalizedString(key: "wallet.add.create", comment: "")
        case .recovery:
            return LocalizedString(key: "wallet.add.import", comment: "")
        }
    }
    
    func nameFieldInput(_ text: String) {
        var charCount = 0
        let nsStr = NSString.init(string: text)
        for i in 0..<text.count {
            if nsStr.character(at: i) >= 0x40EE {
                charCount += 2
            } else {
                charCount += 1
            }
        }
        let vaild = charCount <= 20
        if vaild {
            self.name = text
        } else {
            self.nameTextState.value = self.name
        }
        self.nameErrorState.value = nil
        self.nextState.value = isVaildNext()
    }
    
    func mnemonicSelectAction() {
        let vc = MnemonicLangSelectViewController(lang: langState.value) {
        [unowned self] (lang) in
            self.langState.value = lang
        }
        pushState.newState(vc)
    }
    
    func agreementClick() {
        agreementState.value = !agreementState.value
        self.nextState.value = isVaildNext()
    }
    
    func toServiceBook() -> UIViewController {
        let web = WebViewController.init(WooKeyURL.serviceBook.url)
        return web
    }
    
    func nextClick() {
        // 钱包名称
        guard isNameVaild else {
            nameErrorState.value = LocalizedString(key: "wallet_invalid", comment: "")
            return
        }
        
        switch style {
        case .new:
            HUD.showHUD()
            safeTask {
                let seed = WalletService.shared.generateRandomSeed(self.langState.value)
                mainTask({
                    HUD.hideHUD()
                    let viewModel = NewWalletViewModel(walletName: self.name, seedString: seed)
                    let vc = SeedViewController(viewModel: viewModel)
                    self.pushState.newState(vc)
                })
            }
        case .recovery:
            DSBIP39Mnemonic.sharedInstance()?.defaultLanguage = self.langState.value
            let viewModel = ImportWalletViewModel(walletName: name)
            let vc = ImportFromWordsController(viewModel: viewModel)
            pushState.newState(vc)
        }
    }
    
    
    
    // MARK: - Methods (Private)
    
    private func isVaildNext() -> Bool {
        return agreementState.value && name.count > 0
    }
    
}
