//
//  CurrencyForDashAmountController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/27.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class CurrencyForDashAmountController: BaseTableViewController {

    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 62 }
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: SettingsViewModel
    
    private let codeList: [String] = [
        "USD",
        "CNY",
        "TWD",
        "HKD",
        "MOP",
        "EUR",
    ]
    
    private lazy var topTipLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal
        label.backgroundColor = UIColor(hex: 0xE7E9EC)
        return label
    }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Views
        {
            navigationItem.title = LocalizedString(key: "currency.exechange.rate", comment: "")
            
            view.addSubview(topTipLabel)
            
            tableView.register(cellType: WKOptionViewCell.self)
            tableView.separatorInset.left = 25
            tableView.backgroundColor = AppTheme.Color.page_common
            
            topTipLabel.snp.makeConstraints { (make) in
                make.top.equalTo(44+UIApplication.shared.statusBarFrame.height)
                make.left.right.equalTo(0)
                make.height.equalTo(44)
            }
            
            tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(topTipLabel.snp.bottom)
                make.left.right.bottom.equalTo(0)
            }
        }
    }
    
    override func configureBinds() {
        
        loadData()
        
        onDidSelectRow { [unowned self] (row, _) in
            guard let index = row.indexPath?.row else { return }
            WKDefaults.shared.currencyCode = self.codeList[index]
            DSPriceManager.sharedInstance().localCurrencyCode = WKDefaults.shared.currencyCode
            self.loadData()
            self.viewModel.reloadData()
            WalletService.shared.refreshState.newState(1)
        }
    }
    
    private func loadData() {
        let currencyCode = WKDefaults.shared.currencyCode
        let amount = UInt64(DSPriceManager.sharedInstance().amount(forDashString: "1"))
        let price = Helper.priceForDash(amount)
        topTipLabel.text = "1 Dash \(price)"
        
        let rowList: [TableViewRow] = codeList.map({
            var model = ($0, false)
            if $0 == currencyCode {
                model.1 = true
            }
            return TableViewRow.init(model, cellType: WKOptionViewCell.self, rowHeight: 62)
        })
        dataSource = [TableViewSection(rowList)]
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11, *) {
            
        } else {
            tableView.contentInset.top = 0
        }
    }

}
