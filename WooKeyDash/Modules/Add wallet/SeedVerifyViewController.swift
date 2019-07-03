//
//  SeedVerifyViewController.swift


import UIKit

class SeedVerifyViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let viewModel: NewWalletViewModel
    
    private var verifyWords = ["", "", ""]
    

    // MARK: - Properties (Lazy)
    
    private lazy var randomIndexs: [Int] = {
        return [
            Int(arc4random_uniform(10000) % 3 + 1),
            Int(arc4random_uniform(10000) % 3 + 5),
            Int(arc4random_uniform(10000) % 3 + 9),
        ]
    }()
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var topMessageBG: TopMessageBanner = {
        return TopMessageBanner.init(messages: [
            LocalizedString(key: "words.verify.tip", comment: ""),
        ])
    }()
    
    private lazy var verifyWordView: VerifyWordsView = {
        let v = VerifyWordsView.init()
        v.title = LocalizedString(key: "words.verify.input.title", comment: "")
        v.indexTextColor = AppTheme.Color.main_green_light
        v.xSpace = 10
        return v
    }()
    
    private lazy var seedWordsView: SeedWordsView = {
        return SeedWordsView()
    }()
    
    private lazy var confirmBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "verify", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
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
                verifyWordView,
                seedWordsView,
                confirmBtn,
            ])
            
            do // auto layout
            {
                topMessageBG.snp.makeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                }
                verifyWordView.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(17)
                    make.right.equalToSuperview().offset(-17)
                    make.top.equalTo(topMessageBG.snp.bottom).offset(25)
                }
                seedWordsView.snp.makeConstraints { (make) in
                    make.left.right.equalTo(verifyWordView)
                    make.top.equalTo(verifyWordView.snp.bottom).offset(20)
                }
                confirmBtn.snp.makeConstraints { (make) in
                    make.left.right.equalTo(seedWordsView)
                    make.top.equalTo(seedWordsView.snp.bottom).offset(88)
                    make.height.equalTo(50)
                }
                scrollView.resizeContentLayout()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        verifyWordView.configure(verifyWords, indexs: randomIndexs)
        verifyWordView.clickToRemove = {
            [unowned self] index in
            self.verifyWords[index] = ""
            self.seedWordsView.cancelTap(at: index)
        }
        
        seedWordsView.configure(viewModel.getWords().shuffled(), tapDoing: {
            [unowned self] word in
            var tapIndex: Int?
            for i in 0..<self.verifyWords.count {
                if self.verifyWords[i] == "" {
                    self.verifyWords[i] = word
                    tapIndex = i
                    break
                }
            }
            self.verifyWordView.configure(self.verifyWords, indexs: self.randomIndexs)
            return tapIndex
        })
        scrollView.resizeContentLayout()
        confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func confirmAction() {
        guard randomIndexs.map({ viewModel.getWords()[$0 - 1] }) == verifyWords else {
            verifyWords = ["", "", ""]
            verifyWordView.configure(verifyWords, indexs: randomIndexs)
            seedWordsView.cancelAllTaps()
            HUD.showError(LocalizedString(key: "failToVerify", comment: ""))
            return
        }
        
        viewModel.createWallet()
    }

}
