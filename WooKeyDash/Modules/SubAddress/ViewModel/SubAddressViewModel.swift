//
//  SubAddressViewModel.swift
//  Wookey
//
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewModel: NSObject {
    
    // MARK: - Properties
    
    private var wallet: WalletProtocol
    
    public lazy var dataSourceState = { Postable<[TableViewSection]>() }()
    
    public lazy var modalState = { Postable<UIViewController>() }()
    
    // MARK: - Life Cycles
    
    required init(wallet: WalletProtocol) {
        self.wallet = wallet
        super.init()
    }
    
    func configureData() {
        DispatchQueue.global().async {
            let addrList = self.wallet.receiveAddresses()
            let usedAddress = self.wallet.receiveAddress
            var i = 0
            let rowList: [TableViewRow] = addrList.map({
                var row = TableViewRow(SubAddressFrame(model: $0, usedAddress: usedAddress), cellType: SubAddressViewCell.self, rowHeight: 83)
                let rowIndex = i
                row.actionHandler = {
                [unowned self] _ in
                    self.toEdit(row: rowIndex)
                }
                i += 1
                return row
            })
            DispatchQueue.main.async {
                self.dataSourceState.newState([TableViewSection(rowList)])
            }
        }
    }
    
    func toAdd() {
        let vc = AddSubAddressController(viewModel: self)
        vc.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.modalState.newState(vc)
        }
    }
    
    func toEdit(row: Int) {
        let vc = AddSubAddressController(viewModel: self)
        vc.modalPresentationStyle = .overCurrentContext
        vc.editIndex = row
        DispatchQueue.main.async {
            self.modalState.newState(vc)
        }
    }
    
    func addSubAddress(label: String) {
        if self.wallet.insertAddress(label: label) {
            configureData()
        } else {
            HUD.showError(LocalizedString(key: "add_fail", comment: ""))
        }
    }
    
    func editSubAddress(label: String, row: Int) {
        let walletID = wallet.getTokenWallet().id
        var labels = WKDefaults.shared.receiveAddressLabels(walletID)
        labels[row] = label
        WKDefaults.shared.setReceiveAddressLabels(walletID, value: labels)
        configureData()
    }
    
    func didSelected(indexPath: IndexPath) {
        guard indexPath.row != wallet.receiveAddressIndex else { return }
        wallet.receiveAddressIndex = indexPath.row
        configureData()
    }
    
    
}
