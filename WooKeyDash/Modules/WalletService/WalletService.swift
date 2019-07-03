//   
//   WalletService.swift
//   WooKeyDash
//   
//  Created by WooKey Team on 2019/5/21
//   Copyright © 2019 WooKey. All rights reserved.
//   
	

import UIKit
import Schedule

enum WalletCreateError: Error {
    case exist
    case failure
}

class WalletService: NSObject {

    static let shared = { WalletService() }()
    
    // MARK: - Properties (Public)
    
    var hasWallet: Bool {
        return chain.hasAWallet
    }
    
    var lastBlockHeight: UInt32 {
        return chain.lastBlockHeight
    }
    
    
    /**
     *  Observables and Postables
     *  Dispatch the new state to observers
     **/
    lazy var activeState = {
        Observable<String>("")
    }()
    
    lazy var refreshState = {
        Postable<Int>()
    }()
    
    lazy var connectingState = {
        Observable<Bool>(true)
    }()
    
    lazy var syncingState = {
        Observable<WalletSyncings>(WalletSyncings(chainManager: self.chainManager))
    }()
    
    lazy var syncFailedState = {
        Postable<Int>()
    }()
    
    lazy var syncFinishedState = {
        Postable<Int>()
    }()
    
    lazy var sendableState = {
        Observable<Bool>(false)
    }()
    
    lazy var balanceState = {
        Postable<Int>()
    }()
    
    lazy var transactionState = {
        Postable<Int>()
    }()
    
    
    // MARK: - Properties (Private)
    
    private lazy var chainManager = {
        DSChainsManager.sharedInstance().mainnetManager
    }()
    
    var chain: DSChain {
        return chainManager.chain
    }
    
    private var allWallets: [DSWallet] {
        return chain.wallets
    }
    
    private lazy var priceManager = {
        DSPriceManager.sharedInstance()
    }()
    
    private lazy var syncingTask: Task = {
        let task = Plan.every(1.second).do {
        [unowned self] in
            self.syncing()
        }
        task.suspend()
        return task
    }()
    
    private var peersConnected: Bool? {
        didSet {
            guard let bool = self.peersConnected, self.peersConnected != oldValue else { return }
            self.timerStarted = bool
            if self.connectingState.value != !bool {
                self.connectingState.value = !bool
            }
            self.sendableState.value = bool && self.syncingState.value.finished
        }
    }
    
    private var timerStarted: Bool = false {
        didSet {
            guard oldValue != timerStarted else {
                return
            }
            if timerStarted {
                self.syncingTask.resume()
            } else {
                self.syncingTask.suspend()
            }
        }
    }
    
    //// NotificationCenter observers
    private var syncFinishedObserver: NSObjectProtocol?
    private var syncFailedObserver: NSObjectProtocol?
    private var syncStartedObserver: NSObjectProtocol?
    private var balanceObserver: NSObjectProtocol?
    private var transactionObserver: NSObjectProtocol?
    
    // MARK: - Life Cycles
    
    func setup() {
        
        if !WKDefaults.shared.appLaunched {
            clearAllWallets()
        }
        
        DSReachabilityManager.shared().startMonitoring()
        
        /// Fetch dash coin price
        priceManager.localCurrencyCode = WKDefaults.shared.currencyCode
        priceManager.startExchangeRateFetching()
        
        DSOptionsManager.sharedInstance().syncType = .default
        
        /// DSTransactionManagerSync Notifications >>>>>>>>>>>
        
        syncStartedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.DSPeerManagerConnectedPeersDidChange, object: nil, queue: nil) { (_) in
            self.peersConnected = self.chainManager.peerManager.hasConnectedPeers
        }
        
        syncFinishedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.DSTransactionManagerSyncFinished, object: nil, queue: nil) { (_) in
            self.peersConnected = true
            self.syncFinishedState.newState(1)
        }
        
        syncFailedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.DSTransactionManagerSyncFailed, object: nil, queue: nil) { (_) in
            self.peersConnected = false
//            self.syncFailedState.newState(1)
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.startSync()
            })
        }
        
        balanceObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.DSWalletBalanceDidChange, object: nil, queue: nil, using: { (_) in
            self.balanceState.newState(1)
            self.refreshState.newState(1)
        })
        
        transactionObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.DSTransactionManagerTransactionStatusDidChange, object: nil, queue: nil, using: { (_) in
            self.transactionState.newState(1)
        })
        
        startSync()
    }
    
    func clearAllWallets() {
        guard hasWallet else {
            return
        }
        DashSync.sharedSyncController().stop(for: chain)
        DashSync.sharedSyncController().wipePeerData(for: chain)
        DashSync.sharedSyncController().wipeBlockchainData(for: chain)
        DashSync.sharedSyncController().wipeSporkData(for: chain)
        DashSync.sharedSyncController().wipeMasternodeData(for: chain)
        DashSync.sharedSyncController().wipeGovernanceData(for: chain)
        DashSync.sharedSyncController().wipeWalletData(for: chain, forceReauthentication: false)
        DSAuthenticationManager.sharedInstance().removePin()
    }
    
}


// MARK: - Methods (Public)

extension WalletService {
    
    // MARK:  -> Wallet Create
    
    func generateRandomSeed(_ lang: DSBIP39Language) -> String {
        return DSWallet.generateRandomSeed(for: lang)
    }
    
    func seedVerified(_ text: String) -> String? {
        guard let bip39 = DSBIP39Mnemonic.sharedInstance(),
            let seed = bip39.normalizePhrase(text)
            else {
                return nil
        }
        return bip39.phraseIsValid(seed) ? seed : nil
    }
    
    func generateWallet(_ seed: String, date: Date) throws -> DSWallet {
        guard !allWallets.contains(where: { $0.seedPhraseIfAuthenticated() == seed }) else {
            throw WalletCreateError.exist
        }
        guard
            let wallet = DSWallet.standardWallet(withSeedPhrase: seed, setCreationDate: date.timeIntervalSince1970, for: chain, storeSeedPhrase: true, isTransient: false)
        else {
            throw WalletCreateError.failure
        }
        return wallet
    }
    
    
    // MARK: -> Wallet Datas
    
    func activeDSWallet() -> DSWallet? {
        guard allWallets.count > 0 else {
            return nil
        }
        let activeId = WKDefaults.shared.activeWalletId
        var dsWallet: DSWallet?
        if activeId == "" {
            dsWallet = allWallets.first!
        } else {
            for wallet in allWallets {
                if activeId == wallet.uniqueID {
                    dsWallet = wallet
                    break
                }
            }
        }
        return dsWallet ?? allWallets.first
    }
    
    func getWallets() -> [TokenWallet] {
        return allWallets.map({ $0.getTokenWallet() })
    }
    
    func updateActive(_ walletId: String) {
        WKDefaults.shared.activeWalletId = walletId
        self.activeState.value = walletId
    }
    
    func getActiveWallet() -> TokenWallet? {
        return activeDSWallet()?.getTokenWallet()
    }
    
    func getAssetsList() -> [Assets] {
        guard let tokenWallet = getActiveWallet() else {
            return []
        }
        var list = [Assets]()
        list.append(Assets(balance: tokenWallet.amount, wallet: tokenWallet))
        return list
    }
    
    func getDSWallet(by id: String) -> DSWallet? {
        var dsWallet: DSWallet?
        for dw in allWallets {
            if dw.uniqueID == id {
                dsWallet = dw
                break
            }
        }
        return dsWallet
    }
    
    func deleteWallet(_ wallet: TokenWallet) {
        guard let _dsWallet = getDSWallet(by: wallet.id) else {
            DispatchQueue.main.async {
                self.refreshState.newState(1)
            }
            return
        }
        chain.unregisterWallet(_dsWallet)
        WKDefaults.shared.walletId2Names.removeValue(forKey: wallet.id)
        WKDefaults.shared.needRescanWallets.removeValue(forKey: wallet.id)
        DispatchQueue.main.async {
            self.refreshState.newState(1)
        }
    }
    
    
    // MARK: -> Wallet Sync
    
    func refreshScan() {
        peersConnected = false
        chainManager.peerManager.clearPeers()
        chainManager.peerManager.connect()
    }
    
    func startSync() {
        guard hasWallet else {
            return
        }
        chain.reloadWallets()
        chainManager.peerManager.connect()
        peersConnected = true
    }
    
    func rescanSync() {
        chainManager.rescan()
    }
    
    func stopSync() {
        timerStarted = false
        chainManager.peerManager.disconnect()
        chainManager.chain.saveBlocks()
    }
    
    func pasueSync() {
        self.peersConnected = false
        self.chainManager.peerManager.disconnect()
    }
    
    // MARK:  -> Wallet Transiactions
    
    func allTransiactions() -> [Transaction] {
        guard let wallet = activeDSWallet(),
            let account = wallet.accounts.first as? DSAccount
        else {
            return []
        }
        var list = account.allTransactions as? [DSTransaction] ?? []
        if list.count == 0 {
            account.loadTransactions()
            list = account.allTransactions as? [DSTransaction] ?? []
        }
        return list.map({ $0.transaction(for: account) })
    }
    
    func createTransaction(request: DSPaymentProtocolRequest, amount: UInt64, account: DSAccount, result:DSTransactionCreationSuccessBlock?) {
        HUD.showHUD()
        chainManager.transactionManager.confirmProtocolRequest(request, forAmount: amount, from: account, transactionCreationCompletion: { (tx, address, amount_, fee) in
            HUD.hideHUD()
            result?(tx, address, amount_, fee)
        }) { (errorTitle, errorMessage, shouldCancel) in
            if let msg = errorMessage {
                HUD.showError(msg)
            }
        }
    }
    
    func publishTransaction(tx: DSTransaction, request: DSPaymentProtocolRequest, amount: UInt64, account: DSAccount, address: String, success: (() -> Void)?) {
        HUD.showHUD()
        DispatchQueue.global().async {
            CFRunLoopPerformBlock(RunLoop.current.getCFRunLoop(), CFRunLoopMode.commonModes.rawValue) {
                var displayedSuccess = false
                self.chainManager.transactionManager.signAndPublishTransaction(tx, createdFrom: request, from: account, toAddress: address, withPrompt: ".", forAmount: amount, requestingAdditionalInfo: { (info) in
                    
                }, presentChallenge: { (_, _, _, _, _) in
                    
                }, transactionCreationCompletion: { (_, _, _) -> Bool in
                    return true
                }, signedCompletion: { (tx, error, cancelled) -> Bool in
                    DispatchQueue.main.async {
                        if let err = error as NSError? {
                            HUD.hideHUD()
                            HUD.showError(err.localizedDescription)
                        }
                    }
                    return true
                }, publishedCompletion: { (tx, error, sent) in
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        if let err = error as NSError? {
                            HUD.showError(err.localizedDescription)
                        } else if sent {
                            displayedSuccess = true
                            success?()
                        }
                    }
                }, requestRelayCompletion: { (tx, ack, relayedToServer) in
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        if relayedToServer && !displayedSuccess {
                            success?()
                        }
                    }
                }) { (errorTitle, errorMessage, shouldCancel) in
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        if let msg = errorMessage {
                            HUD.showError(msg)
                        }
                    }
                }
            }
            RunLoop.current.run()
            // Wake Up to excute block
            CFRunLoopWakeUp(RunLoop.current.getCFRunLoop())
        }
    }
    
    
    // MARK:  -> Wallet Address
    
    func validAddress(string: String) -> String? {
        let req = DSPaymentRequest.init(string: string, on: chain)!
        guard req.isValid else { return nil }
        return req.paymentAddress
    }
    
    func paymentRequest(_ address: String) -> DSPaymentRequest {
        return DSPaymentRequest(string: address, on: chain)
    }
    
}


// MARK: - Methods (Private)

extension WalletService {
    
    private func syncing() {
        guard peersConnected == true else {
            return
        }
        let syncings = WalletSyncings(chainManager: chainManager)
        if self.syncingState.value != syncings {
            self.syncingState.value = syncings
        }
        if syncings.finished && peersConnected ?? false {
            sendableState.value = true
        }
    }
}
