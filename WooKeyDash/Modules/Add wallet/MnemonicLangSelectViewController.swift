//
//  MnemonicLangSelectViewController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/27.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class MnemonicLangSelectViewController: BaseTableViewController {

    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 62 }
    
    
    // MARK: - Properties (Private)
    
    private let lang: DSBIP39Language
    
    private let selectedHandler: ((DSBIP39Language) -> Void)?
    
    private lazy var topMessageBG: TopMessageBanner = {
        return TopMessageBanner.init(messages: [
            LocalizedString(key: "wallet.create.words.lang.tip", comment: ""),
        ])
    }()
    
    
    // MARK: - Life Cycle
    
    required init(lang: DSBIP39Language, selectedHandler: ((DSBIP39Language) -> Void)?) {
        self.selectedHandler = selectedHandler
        self.lang = lang
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Views
        {
            navigationItem.title = LocalizedString(key: "language_select", comment: "")
            
            view.addSubview(topMessageBG)
            
            tableView.register(cellType: LanguageViewCell.self)
            tableView.separatorInset.left = 25
            tableView.backgroundColor = AppTheme.Color.page_common
            
            topMessageBG.snp.makeConstraints { (make) in
                make.top.equalTo(44+UIApplication.shared.statusBarFrame.height)
                make.left.right.equalTo(0)
            }
            
            tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(topMessageBG.snp.bottom)
                make.left.right.bottom.equalTo(0)
            }
        }
    }
    
    override func configureBinds() {
        typealias Model = (lang: DSBIP39Language, selected: Bool)
        let list: [Model] = [
            (DSBIP39Language.english, false),
            (DSBIP39Language.chineseSimplified, false),
            (DSBIP39Language.japanese, false),
            (DSBIP39Language.spanish, false),
            (DSBIP39Language.french, false),
            (DSBIP39Language.italian, false),
            (DSBIP39Language.korean, false),
        ]
        let rowList: [TableViewRow] = list.map({
            var model = ($0.lang.localizedString, $0.selected)
            if $0.lang == lang {
                model.1 = true
            }
            return TableViewRow.init(model, cellType: LanguageViewCell.self, rowHeight: 62)
        })
        dataSource = [TableViewSection(rowList)]
        
        onDidSelectRow { [unowned self] (row, _) in
            guard let index = row.indexPath?.row else { return }
            self.selectedHandler?(list[index].lang)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11, *) {
            
        } else {
            tableView.contentInset.top = 0
        }
    }

}
