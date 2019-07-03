//
//  SeedViewController.swift


import UIKit

class SeedViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: NewWalletViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var topMessageBG: TopMessageBanner = {
        return TopMessageBanner.init(messages: [
            LocalizedString(key: "words.create.tip1", comment: ""),
            LocalizedString(key: "words.create.tip2", comment: "")
        ])
    }()
    
    private lazy var wordListView: WordListView = {
        let v = WordListView.init()
        v.title = LocalizedString(key: "words.list.title", comment: "")
        return v
    }()
    
    private lazy var confirmBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "words.list.confirm", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
            ], backgroundColor: AppTheme.Color.main_blue)
        return btn
    }()
    
    // MARK: - Life Cycles
    
    required init(viewModel: NewWalletViewModel) {
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
            navigationItem.title = LocalizedString(key: "wallet.add.create", comment: "")
            
            scrollView.frame = view.bounds
            view.addSubview(scrollView)
        }
        
        do /// Subviews
        {
            scrollView.contentView.addSubViews([
            topMessageBG,
            wordListView,
            confirmBtn,
            ])
            
            do // auto layout
            {
                topMessageBG.snp.makeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                }
                wordListView.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(25)
                    make.right.equalToSuperview().offset(-25)
                    make.top.equalTo(topMessageBG.snp.bottom).offset(25)
                }
                confirmBtn.snp.makeConstraints { (make) in
                    make.left.right.equalTo(wordListView)
                    make.top.equalTo(wordListView.snp.bottom).offset(37)
                    make.height.equalTo(50)
                }
                scrollView.resizeContentLayout()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_copy"), style: .plain, target: self, action: #selector(self.copyAction))
        }
        
        do /// Models ->
        {
            viewModel.navItemRightEnable.observe(self) { (enable, _Self) in
                _Self.navigationItem.rightBarButtonItem?.isEnabled = enable
            }
            
            viewModel.pushState.observe(self) { (vc, _Self) in
                _Self.navigationController?.pushViewController(vc, animated: true)
            }
            
            viewModel.configure(wordListView: wordListView)
            scrollView.resizeContentLayout()            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = SeedAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
    
    // MARK: - Methods (Action)
    
    @objc private func copyAction() {
        viewModel.copySeed()
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    @objc private func confirmAction() {
        viewModel.next()
    }

}
