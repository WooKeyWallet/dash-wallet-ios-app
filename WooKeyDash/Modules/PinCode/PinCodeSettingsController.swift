//
//  PinCodeSettingsController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/29.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class PinCodeSettingsController: BaseTableViewController {
    
    override var rowHeight: CGFloat { return 57 }
    override var style: UITableView.Style { return .grouped }
    
    // MARK: - Properties (Private)
    
    
    
    // MARK: - Life Cycles

    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "settings.pin", comment: "")
        }
        
        do /// Views
        {
            tableView.register(cellType: WKSwitchViewCell.self)
            tableView.register(cellType: WKTableViewCell.self)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        loadData()
    }
    
    private func loadData() {
        DispatchQueue.global().async {
            let model1 = WKTableViewCell.Model(title: LocalizedString(key: "pin.change.title", comment: ""), detail: "", showArrow: true)
            var modelList: [(Any, BaseTableViewCell.Type)] = [(model1, WKTableViewCell.self),]
            if WKAuthenticator.shared.faceIDAvailable() {
                let model2 = WKSwitchViewCell.Model(isOn: WKAuthenticator.shared.hasTouchOrFaceId, title: LocalizedString(key: "faceId", comment: ""))
                modelList.append((model2, WKSwitchViewCell.self))
            } else if WKAuthenticator.shared.touchIDAvailable() {
                let model2 = WKSwitchViewCell.Model(isOn: WKAuthenticator.shared.hasTouchOrFaceId, title: LocalizedString(key: "touchId", comment: ""))
                modelList.append((model2, WKSwitchViewCell.self))
            }
            var rowList = modelList.map({ TableViewRow($0.0, cellType: $0.1, rowHeight: 0) })
            rowList[0].didSelectedAction = {
            [unowned self] _ in
                self.toChangePinCode()
            }
            if rowList.count == 2 {
                rowList[1].actionHandler = {
                    [unowned self] btn in
                    guard let btn = btn as? UISwitch else { return }
                    self.switchTouchOrFaceId(btn)
                }
            }
            var sec = TableViewSection(rowList)
            sec.footerHeight = 20
            sec.headerHeight = 0.1
            self.dataSource = [sec]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Methods (Action)
    
    private func toChangePinCode() {
        DispatchQueue.main.async {
            PINAlertController.show(loginResult: { [unowned self] (success) in
                guard success else { return }
                let vc = PinCodeSetViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    private func switchTouchOrFaceId(_ btn: UISwitch) {
        DispatchQueue.main.async {
            btn.setOn(WKAuthenticator.shared.hasTouchOrFaceId, animated: true)
            PINAlertController.show(loginResult: { (success) in
                guard success else {
                    return
                }
                guard WKAuthenticator.shared.firstSetFaceID else {
                    let bool = WKAuthenticator.shared.hasTouchOrFaceId
                    WKAuthenticator.shared.hasTouchOrFaceId = !bool
                    btn.setOn(!bool, animated: true)
                    return
                }
                WKAuthenticator.shared.hasTouchOrFaceId = true
                WKAuthenticator.shared.request({ (ok) in
                    WKAuthenticator.shared.hasTouchOrFaceId = ok
                    btn.setOn(ok, animated: true)
                })
            })
        }
    }

}
