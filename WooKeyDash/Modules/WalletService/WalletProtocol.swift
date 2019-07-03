//   
//   WalletProtocol.swift
//   WooKeyDash
//   
//  Created by WooKey Team on 2019/5/22
//   Copyright © 2019 WooKey. All rights reserved.
//   
	

import Foundation

protocol WalletProtocol {
    var balance: UInt64 { get }
    var receiveAddressIndex: Int { get set }
    var receiveAddress: String { get }
    func getTokenWallet() -> TokenWallet
    func insertAddress(label: String) -> Bool
    func receiveAddresses() -> [SubAddress]
}

protocol TransactionProtocol {
    func transaction(for account: DSAccount) -> Transaction
}

extension DSWallet: WalletProtocol {
    
    var receiveAddressIndex: Int {
        get { return WKDefaults.shared.receiveAddressIndex(uniqueID) }
        set {
            WKDefaults.shared.setReceiveAddressIndex(uniqueID, value: newValue)
        }
    }
    
    var receiveAddress: String {
        let index = receiveAddressIndex
        let list = receiveAddresses()
        guard index < list.count else {
            let account = self.accounts.first as? DSAccount
            return account?.receiveAddress ?? ""
        }
        return list[index].address
    }
    
    func getTokenWallet() -> TokenWallet {
        var model = TokenWallet()
        model.id = uniqueID
        model.label = WKDefaults.shared.walletId2Names[model.id] ?? ""
        model.token = Token.dash.rawValue
        let str = Helper.amountForDash(Int64(balance))
        model.amount = Helper.displayDigitsAmount(str)
        model.address = receiveAddress
        model.price = Helper.priceForDash(balance)
        model.in_use = model.id == WKDefaults.shared.activeWalletId
        
        model.onWallet = self
        return model
    }
    
    func insertAddress(label: String) -> Bool {
        guard let account = self.accounts.first as? DSAccount,
            let fundPath = account.defaultDerivationPath
        else {
            return false
        }
        let limit = WKDefaults.shared.receiveAddressCount(uniqueID) + 1
        var labels = WKDefaults.shared.receiveAddressLabels(uniqueID)
        let addressList = (0..<limit).map({ fundPath.address(at: UInt32($0), internal: false) })
        let success = addressList.count == limit
        if success {
            labels.append(label)
            WKDefaults.shared.setReceiveAddressCount(uniqueID, value: limit)
            WKDefaults.shared.setReceiveAddressLabels(uniqueID, value: labels)
        }
        return success
    }
    
    func receiveAddresses() -> [SubAddress] {
        guard let account = self.accounts.first as? DSAccount,
            let fundPath = account.defaultDerivationPath
        else {
                return []
        }
        let limit = WKDefaults.shared.receiveAddressCount(uniqueID)
        let labels = WKDefaults.shared.receiveAddressLabels(uniqueID)
        let listCount = min(limit, labels.count)
        let addressList = (0..<listCount).map({ fundPath.address(at: UInt32($0), internal: false) })
        var i = 0
        return addressList.map({
            let model = SubAddress(address: $0, label: labels[i], index: i)
            i += 1
            return model
        })
    }
    
}

extension DSTransaction: TransactionProtocol {
    
    func transaction(for account: DSAccount) -> Transaction {
        
        let priceManager = DSPriceManager.sharedInstance()
        
        let fee: UInt64
        if feeUsed == UInt64.max {
            fee = standardFee
        } else {
            fee = feeUsed
        }
        let feeStr = priceManager.attributedString(forDashAmount: Int64(fee))?.string ?? "--"
        
        let send = account.amountSent(by: self)
        let received = account.amountReceived(from: self)
        let isSend = send > 0
        let amount: Int64
        if isSend {
            if send == received {
                amount = Int64(send)
            } else {
                let sentInfo = send.subtractingReportingOverflow(received)
                if sentInfo.overflow {
                    amount = 0
                } else {
                    amount = Int64(sentInfo.partialValue)
                }
            }
        } else {
            amount = Int64(received)
        }
        let amountStr = priceManager.attributedString(forDashAmount: amount)?.string ?? ""
        
        let time = timestamp > 1 ? timestamp : WalletService.shared.chain.timestamp(forBlockHeight: UInt32(TX_UNCONFIRMED))
        let date = Date(timeIntervalSince1970: time).toString("yyyy-MM-dd HH:mm:ss")
        
        let lastBlockHeight = WalletService.shared.lastBlockHeight
        let confirms = blockHeight > lastBlockHeight ? 0 : (lastBlockHeight - blockHeight) + 1
        
        var status = Transaction.Status.failure
        if confirms == 0 && !account.transactionIsValid(self) { // invalid
            status = .failure
        } else if !instantSendReceived && confirms == 0 && account.transactionIsPending(self) { // pending
            status = .proccessing
        } else if !instantSendReceived && confirms == 0 && !account.transactionIsVerified(self) { // unverified
            status = .proccessing
        } else if account.transactionOutputsAreLocked(self) { // locked
            status = .proccessing
        } else if !instantSendReceived && confirms < 6 { // confirms
            status = .proccessing
        } else { // success
            status = .success
        }
        
        var (inputAddresses, outputAddresses) = ([String](), [String]())
        self.inputAddresses?.forEach({
            if let addr = $0 as? String, !inputAddresses.contains(addr) {
                inputAddresses.append(addr)
            }
        })
        self.outputAddresses?.forEach({
            if let addr = $0 as? String, !outputAddresses.contains(addr) {
                if let tx = self as? DSProviderRegistrationTransaction,
                    tx.masternodeHoldingWallet?.containsHoldingAddress(addr) ?? false {
                    if send == 0 || send == received + UInt64(MASTERNODE_COST) + fee {
                        outputAddresses.append(addr)
                    }
                } else if account.containsAddress(addr) {
                    if send == 0 || send == received {
                        outputAddresses.append(addr)
                    }
                } else if isSend {
                    outputAddresses.append(addr)
                }
            }
        })
        let sendAddress = inputAddresses.joined(separator: "、")
        let receiveAddress = outputAddresses.joined(separator: "、")
        
        var model = Transaction(type: isSend ? .out : .in,
                           amount: amountStr,
                           status: status,
                           token: Token.dash.rawValue,
                           date: date,
                           fee: feeStr,
                           receiveAddress: receiveAddress,
                           sendAddress: sendAddress,
                           hash: txHashText(),
                           block: String(blockHeight))
        model.amountPrice = Helper.priceForDash(UInt64(amount))
        model.feePrice = Helper.priceForDash(fee)
        if isSend {
            model.receiveAmount = priceManager.attributedString(forDashAmount: amount - Int64(fee))?.string ?? ""
            model.receiveAmountPrice = Helper.priceForDash(UInt64(amount) - fee)
        }
        return model
    }
}

extension DSBIP39Language {
    
    var localizedString: String {
        switch self {
        case .chineseSimplified:
            return "中文（简体）"
        case .english:
            return "English"
        case .french:
            return "Français"
        case .italian:
            return "Italiano"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .spanish:
            return "Español"
        default:
            return ""
        }
    }
}


