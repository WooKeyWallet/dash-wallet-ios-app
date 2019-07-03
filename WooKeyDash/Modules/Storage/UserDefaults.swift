//
//  WalletUserDefaults.swift


import UIKit

private struct KeyPath {
    static let appLaunched = "appLaunchedKey"
    static let wallet_id_to_names = "walletIdToNamesKey"
    static let wallet_subAddress_index = "walletIndexSubAddressKey"
    static let activeWalletId = "activeWalletIdKey"
    static let currencyCode = "currencyCodeKey"
    static let needRescan = "needRescanKey"
    static let earliestWalletCreationTime = "earliestWalletCreationTimeKey"
    static let receiveAddressIndex = "receiveAddressIndexKey"
    static let receiveAddressCount = "receiveAddressCountKey"
    static let receiveAddressLabels = "receiveAddressLabelsKey"
    static let hiddenAsset = "hiddenAssetKey"
}

public class WKDefaults: UserDefaults {
    
    // MARK: - Properties
    
    public static let shared = { return WKDefaults(suiteName: AppInfo.bundleIdentifier + "-defaults")! }()
    
    public var appLaunched: Bool {
        get {
            let value = bool(forKey: KeyPath.appLaunched)
            if !value {
                setValue(true, forKey: KeyPath.appLaunched)
            }
            return value
        }
    }
    
    public var walletId2Names: [String: String] {
        get { return value(forKey: KeyPath.wallet_id_to_names) as? [String: String] ?? [:] }
        set {
            setValue(newValue, forKey: KeyPath.wallet_id_to_names)
        }
    }
    
    public var activeWalletId: String {
        get { return string(forKey: KeyPath.activeWalletId) ?? "" }
        set {
            setValue(newValue, forKey: KeyPath.activeWalletId)
        }
    }
    
    public var currencyCode: String {
        get { return string(forKey: KeyPath.currencyCode) ?? "USD" }
        set {
            setValue(newValue, forKey: KeyPath.currencyCode)
        }
    }
    
    public var earliestWalletCreationTime: TimeInterval? {
        get { return value(forKey: KeyPath.earliestWalletCreationTime) as? TimeInterval }
        set {
            setValue(newValue, forKey: KeyPath.earliestWalletCreationTime)
        }
    }
    
    public var needRescanWallets: [String: Bool] {
        get { return value(forKey: KeyPath.needRescan) as? [String: Bool] ?? [:] }
        set {
            setValue(newValue, forKey: KeyPath.needRescan)
        }
    }
    
    public var receiveAddressLabels: [String] {
        get { return value(forKey: KeyPath.receiveAddressLabels) as? [String] ?? [LocalizedString(key: "primaryAddress", comment: "")] }
        set {
            let value = newValue.count > 1 ? newValue : [LocalizedString(key: "primaryAddress", comment: "")]
            setValue(value, forKey: KeyPath.receiveAddressLabels)
        }
    }
    
    public var hiddenAsset: Bool {
        get { return bool(forKey: KeyPath.hiddenAsset) }
        set {
            setValue(newValue, forKey: KeyPath.hiddenAsset)
        }
    }
    
    lazy var receiveAddressIndexState = { Postable<String>() }()
    
    
    // MARK: - Methods
    
    func receiveAddressIndex(_ walletId: String) -> Int {
        let key = KeyPath.receiveAddressIndex + "-" + walletId
        return integer(forKey: key)
    }
    
    func setReceiveAddressIndex(_ walletId: String, value: Int) {
        let key = KeyPath.receiveAddressIndex + "-" + walletId
        setValue(value, forKey: key)
        receiveAddressIndexState.newState(walletId)
    }
    
    func receiveAddressCount(_ walletId: String) -> Int {
        let key = KeyPath.receiveAddressCount + "-" + walletId
        return value(forKey: key) as? Int ?? 1
    }
    
    func setReceiveAddressCount(_ walletId: String, value: Int) {
        let key = KeyPath.receiveAddressCount + "-" + walletId
        let _value = value > 1 ? value : 1
        setValue(_value, forKey: key)
    }
    
    func receiveAddressLabels(_ walletId: String) -> [String] {
        let defaultList = [LocalizedString(key: "primaryAddress", comment: "")]
        let key = KeyPath.receiveAddressLabels + "-" + walletId
        return value(forKey: key) as? [String] ?? defaultList
    }
    
    func setReceiveAddressLabels(_ walletId: String, value: [String]) {
        let defaultList = [LocalizedString(key: "primaryAddress", comment: "")]
        let key = KeyPath.receiveAddressLabels + "-" + walletId
        let _value = value.count > 1 ? value : defaultList
        setValue(_value, forKey: key)
    }
    
}
