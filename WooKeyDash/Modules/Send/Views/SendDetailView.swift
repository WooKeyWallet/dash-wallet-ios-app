//
//  SendDetailView.swift


import UIKit

class SendDetailView: UIView {

    // MARK: - Properties (Lazy)
    
    public lazy var toAddressField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "send.address", comment: "")
        field.placeholder = LocalizedString(key: "send.address", comment: "")
        field.keyboardType = .alphabet
        return field
    }()
    
    public lazy var amountField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "send.amount", comment: "")
        field.placeholder = LocalizedString(key: "send.amount", comment: "")
        field.keyboardType = .decimalPad
        return field
    }()
    
    public lazy var addressSelectBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "toAddress_select"), for: .normal)
        return btn
    }()
    
    private lazy var dashText: UILabel = {
        let label = UILabel()
        label.text = "Dash"
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        return label
    }()
    
    public lazy var allinBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "amount_allin"), for: .normal)
        return btn
    }()
    
    public lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    public lazy var feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    public lazy var sendBtn: UIButton = {
        return UIButton.createCommon([UIButton.TitleAttributes.init(LocalizedString(key: "send", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)], backgroundColor: AppTheme.Color.main_blue)
    }()
    
    
    private lazy var addressLine = { UIView() }()
    private lazy var amountLine = { UIView() }()
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.configureConstraints()
    }
    
    // MARK: - Configure
    
    internal func configureView() {
        
        backgroundColor = AppTheme.Color.page_common
        
        addressLine.backgroundColor = UIColor(hex: 0xC3C7CB)
        amountLine.backgroundColor = UIColor(hex: 0xC3C7CB)
        
        addSubViews([
        toAddressField,
        addressSelectBtn,
        amountField,
        dashText,
        allinBtn,
        priceLabel,
        feeLabel,
        sendBtn,
        
        addressLine,
        amountLine,
        ])
    }
    
    internal func configureConstraints() {
        toAddressField.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-65)
        }
        addressSelectBtn.snp.makeConstraints { (make) in
            make.left.equalTo(toAddressField.snp.right).offset(12)
            make.top.equalTo(toAddressField.snp.top).offset(14)
            make.width.height.equalTo(22)
        }
        addressLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(toAddressField)
            make.height.equalTo(1)
        }
        
        amountField.snp.makeConstraints { (make) in
            make.left.equalTo(toAddressField)
            make.right.equalTo(dashText.snp.left)
            make.top.equalTo(toAddressField.snp.bottom).offset(15)
        }
        dashText.snp.makeConstraints { (make) in
            make.right.equalTo(addressLine)
            make.bottom.equalTo(amountLine).offset(-12)
        }
        allinBtn.snp.makeConstraints { (make) in
            make.left.equalTo(dashText.snp.right).offset(12)
            make.top.equalTo(amountField.snp.top).offset(14)
            make.width.height.equalTo(22)
        }
        amountLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(amountField)
            make.left.right.equalTo(addressLine)
            make.height.equalTo(1)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(amountLine)
            make.top.equalTo(amountLine.snp.bottom).offset(4)
        }
        feeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel)
            make.bottom.equalTo(priceLabel.snp.bottom).offset(19)
        }
        
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.height.equalTo(50)
            make.top.equalTo(feeLabel.snp.bottom).offset(46)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    

}
