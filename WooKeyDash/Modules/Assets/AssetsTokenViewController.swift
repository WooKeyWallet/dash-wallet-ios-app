//
//  AssetsTokenViewController.swift


import UIKit

class AssetsTokenViewController: BaseViewController {
    
    
    // MARK: - Properties (Pivate)
    
    private let viewModel: AssetsTokenViewModel
    
    
    // MARK: - Properties (Lazy)

    
    private lazy var contentView = {
        AutoLayoutScrollView(frame: view.bounds)
    }()
    
    private lazy var tokenAssetsView = {
        AssetsTokenView()
    }()
    
    private lazy var viewControllers = {
        Array<TransactionsType>([.all, .in, .out]).map({ TransactionListController.init(type: $0) })
    }()
    
    private lazy var tokenTransactionsView: CAPSPageMenu = {
        let _frame = view.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: UIApplication.shared.statusBarFrame.height + 44, right: 0))
        return CAPSPageMenu.init(viewControllers: viewControllers, frame: _frame, pageMenuOptions: CAPSPageMenuOption.itemsScaleToFillOptions())
    }()
    
    //滑动是否进入结束状态
    private lazy var isScrollEND = { return Observable<Bool>(false) }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: AssetsTokenViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = viewModel.title
            view.backgroundColor = AppTheme.Color.tableView_bg
        }
        
        do /// Subviews
        {
            contentView.delegate = self
            view.addSubview(contentView)
            
            contentView.contentView.addSubViews([
                tokenAssetsView,
                tokenTransactionsView.view,
            ])
            
            tokenAssetsView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
            tokenTransactionsView.view.snp.makeConstraints { (make) in
                make.top.equalTo(tokenAssetsView.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.height.equalTo(tokenTransactionsView.view.height)
            }
            
            contentView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Notifications
        {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
        do //// Actions
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigationItem_refresh"), style: .plain, target: self, action: #selector(self.refreshAction))
            tokenAssetsView.sendBtn.addTarget(self, action: #selector(self.sendAction), for: .touchUpInside)
            tokenAssetsView.receiveBtn.addTarget(self, action: #selector(self.receiveAction), for: .touchUpInside)
            tokenAssetsView.copyBtn.addTarget(self, action: #selector(self.copyAction), for: .touchUpInside)
            
            /// 叠加视图滑动联动
            viewControllers.forEach({
                // 子级结束，进入父级
                $0.isScrollEND.observe(self, eventHandler: { (isEnd, strongSelf) in
                    guard isEnd else { return }
                    strongSelf.isScrollEND.value = false
                })
                // 父级结束，进入子级
                self.isScrollEND.observe($0, eventHandler: { (isEnd, strongVC) in
                    guard isEnd else { return }
                    strongVC.isScrollEND.value = false
                })
            })
        }
        
        do //// Wallet Syncing
        {
            viewModel.configure(assetsView: tokenAssetsView)
            
            viewModel.sendState.observe(tokenAssetsView.sendBtn) { (enable, btn) in
                DispatchQueue.main.async {
                    btn.isEnabled = enable
                }
            }
            viewModel.reciveState.observe(tokenAssetsView.receiveBtn) { (enable, btn) in
                DispatchQueue.main.async {
                    btn.isEnabled = enable
                }
            }
            viewModel.conncetingState.observe(tokenAssetsView.progressBar) { (connecting, progressBar) in
                DispatchQueue.main.async {
                    progressBar.animating = connecting
                }
            }
            viewModel.progressState.observe(tokenAssetsView.progressBar) { (progress, progressBar) in
                DispatchQueue.main.async {
                    progressBar.progress = progress
                }
            }
            viewModel.statusTextState.observe(tokenAssetsView.progressLabel) { (text, label) in
                DispatchQueue.main.async {
                    label.text = text
                }
            }
            viewModel.balanceState.observe(tokenAssetsView.balanceLabel) { (text, label) in
                DispatchQueue.main.async {
                    label.text = text
                }
            }
            viewModel.priceState.observe(tokenAssetsView.priceLabel) { (text, label) in
                DispatchQueue.main.async {
                    label.text = text
                }
            }
            viewModel.historyState.observe(self) { (list, strongSelf) in
                let viewControllers = strongSelf.viewControllers
                let currentPageIndex = strongSelf.tokenTransactionsView.currentPageIndex
                let currentViewController = viewControllers[currentPageIndex]
                let needReloadCurrentPage = currentViewController.dataSource.count != list[currentPageIndex].count || currentViewController.dataSource[0].rows.count != list[currentPageIndex][0].rows.count
                stride(from: 0, to: list.count, by: 1).forEach({
                    viewControllers[$0].dataSource = list[$0]
                })
                if needReloadCurrentPage {
                    DispatchQueue.main.async {
                        currentViewController.reloadData()
                    }
                }
            }
            
            viewModel.synchronize()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tokenTransactionsView.controllerArray[tokenTransactionsView.currentPageIndex].viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tokenAssetsView.progressBar.willAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tokenAssetsView.progressBar.willDisappear()
    }
    
    deinit {
        dPrint("\(#function) ================================= \(self.classForCoder)")
    }
    
    
    // MARK: - Methods (Notifications)
    
    @objc private func willResignActiveNotification() {
        tokenAssetsView.progressBar.willDisappear()
    }
    
    @objc private func didBecomeActiveNotification() {
        tokenAssetsView.progressBar.willAppear()
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func refreshAction() {
        viewModel.refresh()
    }
    
    @objc private func sendAction() {
        navigationController?.pushViewController(viewModel.toSend(), animated: true)
    }
    
    @objc private func receiveAction() {
        navigationController?.pushViewController(viewModel.toReceive(), animated: true)
    }
    
    @objc private func copyAction() {
        viewModel.copyAddress()
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }

}

// MARK: - UIScrollViewDelegate

extension AssetsTokenViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var limit_offset = tokenAssetsView.height + 10
        if #available(iOS 11.0, *) {
            limit_offset -= scrollView.adjustedContentInset.top - scrollView.contentInset.top
        } else {
            limit_offset -= scrollView.contentInset.top
        }
        guard !isScrollEND.value else {
            scrollView.contentOffset.y = limit_offset
            return
        }
        if scrollView.contentOffset.y >= limit_offset {
            scrollView.contentOffset.y = limit_offset
            isScrollEND.value = true
        }
    }
}
