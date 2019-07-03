//
//  CreateWalletView.swift


import UIKit
import ActiveLabel

class CreateWalletView: UIScrollView {
    
    // MARK: - Properties
    
    private var style: WalletCreateStyle = .new
    
    private lazy var BG: UIView = {
        let bg = UIView()
        bg.backgroundColor = AppTheme.Color.page_common
        return bg
    }()
    
    private lazy var topMessageBG: TopMessageBanner = {
        let list: [String]
        switch style {
        case .new:
            list = [LocalizedString(key: "wallet.create.tip1", comment: "")]
        case .recovery:
            list = [LocalizedString(key: "wallet.create.tip0", comment: "")]
        }
        return TopMessageBanner.init(messages: list)
    }()
    
    public lazy var walletNameField: WKFloatingLabelTextField = {
        let field = WKFloatingLabelTextField.createTextField()
        field.title = LocalizedString(key: "wallet.create.name", comment: "")
        field.placeholder = LocalizedString(key: "wallet.create.name", comment: "")
        return field
    }()
    
//    public lazy var walletPwdField: WKFloatingLabelTextField = {
//        let field = WKFloatingLabelTextField.createTextField()
//        field.title = LocalizedString(key: "wallet.create.pwd", comment: "")
//        field.placeholder = LocalizedString(key: "wallet.create.pwd", comment: "")
//        field.keyboardType = .alphabet
//        return field
//    }()
//
//    public lazy var walletPwdConfirmField: WKFloatingLabelTextField = {
//        let field = WKFloatingLabelTextField.createTextField()
//        field.title = LocalizedString(key: "wallet.create.pwdConfirm", comment: "")
//        field.placeholder = LocalizedString(key: "wallet.create.pwdConfirm", comment: "")
//        field.keyboardType = .alphabet
//        return field
//    }()
//
//    public lazy var walletPwdMSGField: WKFloatingLabelTextField = {
//        let field = WKFloatingLabelTextField.createTextField()
//        field.title = LocalizedString(key: "wallet.create.pwdMsg", comment: "")
//        field.placeholder = LocalizedString(key: "wallet.create.pwdMsg", comment: "")
//        return field
//    }()
    
    public lazy var agreementBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_select_no"), for: .normal)
        btn.setImage(UIImage(named: "btn_select_yes"), for: .selected)
        return btn
    }()
    
    public lazy var serviceBookBtn: ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.textColor = AppTheme.Color.text_light
        let customType = ActiveType.custom(pattern: "\\\(LocalizedString(key: "wallet.create.servicebook", comment: ""))\\b")
        label.enabledTypes = [customType]
        label.text = "\(LocalizedString(key: "wallet.create.agreement", comment: "")) \(LocalizedString(key: "wallet.create.servicebook", comment: ""))"
        label.customColor[customType] = AppTheme.Color.text_click
        label.customSelectedColor[customType] = AppTheme.Color.text_click.highlighted()
        label.font = AppTheme.Font.text_small
        return label
    }()
    
    public lazy var langSelectView: MnemonicLanguageCell = {
        MnemonicLanguageCell(frame: .zero)
    }()
    
    public lazy var nextBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "next", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
            ], backgroundColor: AppTheme.Color.main_blue)
        return btn
    }()
    
    public lazy var pwdRankView: RankView = {
        let rankView = RankView.init(max: 4)
        rankView.level = 3
        return rankView
    }()
    
    public lazy var pwdSecureTextEntryBtn: UIButton = {
        let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        btn.setImage(UIImage(named: "eye_on"), for: .normal)
        btn.setImage(UIImage(named: "eye_off"), for: .selected)
        btn.showsTouchWhenHighlighted = false
        return btn
    }()
    
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init(style: WalletCreateStyle) {
        super.init(frame: .zero)
        self.style = style
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureConstraints()
        setNeedsLayout()
        layoutIfNeeded()
        BG.height = nextBtn.maxY + 40
        self.contentSize.height = BG.height
    }
    
    private func configureView() {
        self.backgroundColor = AppTheme.Color.page_common
        addSubview(BG)
        BG.addSubview(topMessageBG)
        BG.addSubview(walletNameField)
//        BG.addSubview(walletPwdField)
//        BG.addSubview(walletPwdConfirmField)
//        BG.addSubview(walletPwdMSGField)
        BG.addSubViews(langSelectView)
        BG.addSubview(agreementBtn)
        BG.addSubview(serviceBookBtn)
        BG.addSubview(nextBtn)
        
//        walletPwdField.rightView = pwdRankView
//        walletPwdField.rightViewMode = .always
//        walletPwdConfirmField.rightView = pwdSecureTextEntryBtn
//        walletPwdConfirmField.rightViewMode = .always
    }
    
    private func configureConstraints() {
        BG.frame = UIScreen.main.bounds
        topMessageBG.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        walletNameField.snp.makeConstraints { (make) in
            make.top.equalTo(topMessageBG.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
            make.height.equalTo(52)
        }
//        walletPwdField.snp.makeConstraints { (make) in
//            make.left.right.equalTo(walletNameField)
//            make.top.equalTo(walletNameField.snp.bottom).offset(15)
//            make.height.equalTo(52)
//        }
//        walletPwdConfirmField.snp.makeConstraints { (make) in
//            make.left.right.equalTo(walletPwdField)
//            make.top.equalTo(walletPwdField.snp.bottom).offset(15)
//            make.height.equalTo(52)
//        }
//        walletPwdMSGField.snp.makeConstraints { (make) in
//            make.left.right.equalTo(walletPwdConfirmField)
//            make.top.equalTo(walletPwdConfirmField.snp.bottom).offset(15)
//            make.height.equalTo(52)
//        }
        langSelectView.snp.makeConstraints { (make) in
            make.top.equalTo(walletNameField.snp.bottom).offset(34)
            make.left.right.equalTo(walletNameField)
            make.height.equalTo(38)
        }
        agreementBtn.snp.makeConstraints { (make) in
            make.left.equalTo(langSelectView).offset(-5)
            make.top.equalTo(langSelectView.snp.bottom).offset(8)
            make.height.equalTo(30)
            make.width.equalTo(25)
        }
        serviceBookBtn.snp.makeConstraints { (make) in
            make.left.equalTo(agreementBtn.snp.right)
            make.right.equalTo(walletNameField)
            make.top.equalTo(agreementBtn).offset(15 - AppTheme.Font.text_small.lineHeight*0.5)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(serviceBookBtn.snp.bottom).offset(50)
            make.left.right.equalTo(walletNameField)
            make.height.equalTo(50)
        }
        pwdRankView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 14, height: 28))
        }
    }
    
}
