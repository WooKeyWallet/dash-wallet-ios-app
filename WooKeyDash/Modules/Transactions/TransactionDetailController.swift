//
//  TransactionDetailViewController.swift


import UIKit

class TransactionDetailController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let transaction: Transaction
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var detailView: TransactionDetailView = {
        return TransactionDetailView()
    }()
    
    private lazy var toSafraiBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(LocalizedString(key: "transaction.block.url", comment: ""), for: .normal)
        btn.setTitleColor(AppTheme.Color.main_green, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.titleLabel?.numberOfLines = 0
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    
    // MARK: - Life Cycles
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = transaction.token + " " + LocalizedString(key: "transaction.detail.title", comment: "")
        }
        
        do /// Subviews
        {
            scrollView.backgroundColor = AppTheme.Color.tableView_bg
            view.addSubview(scrollView)
            
            scrollView.contentView.addSubViews([detailView, toSafraiBtn])
            
            detailView.snp.makeConstraints { (make) in
                make.left.equalTo(23)
                make.right.equalTo(-23)
                make.top.equalTo(16)
            }
            
            toSafraiBtn.snp.makeConstraints { (make) in
                make.top.equalTo(detailView.snp.bottom).offset(10)
                make.left.right.lessThanOrEqualTo(detailView)
                make.centerX.equalTo(detailView)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        detailView.configure(model: transaction)
        scrollView.resizeContentLayout()
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.transIdlongPressAction))
        detailView.blockInfoView.transactionIdLabel.addGestureRecognizer(longPress)
        toSafraiBtn.addTarget(self, action: #selector(toBlockBrowser), for: .touchUpInside)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func transIdlongPressAction() {
        UIPasteboard.general.string = transaction.hash
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    @objc private func toBlockBrowser() {
        let urls = [
            "https://explorer.dash.org/tx/",
            "http://insight.dash.org/insight/tx/",
        ]
        let hash = transaction.hash
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: LocalizedString(key: "cancel", comment: ""), style: .cancel, handler: nil))
        urls.forEach({ url in
            actionSheet.addAction(UIAlertAction(title: url, style: .default, handler: { (_) in
                AppManager.default.openSafariViewController(with: url+hash)
            }))
        })
        navigationController?.present(actionSheet, animated: true, completion: nil)
    }
}
