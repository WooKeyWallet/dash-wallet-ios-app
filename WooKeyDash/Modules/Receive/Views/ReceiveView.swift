//
//  ReceiveView.swift


import UIKit

class ReceiveView: UIView {

    // MARK: - Properties (Lazy)
    
    private lazy var topBG: UIImageView = {
        let bg = UIImageView(image: UIImage(named: "receive_top_bg"))
        bg.contentMode = .scaleToFill
        bg.backgroundColor = AppTheme.Color.tableView_bg
        return bg
    }()
    
    private lazy var triangleView: TriangleView = {
        let view = TriangleView.init(color: AppTheme.Color.main_green_light, style: .down)
        view.backgroundColor = AppTheme.Color.page_common
        return view
    }()
    
    public lazy var qrcodeView: UIImageView = {
        let qrcodeView = UIImageView()
        qrcodeView.contentMode = .scaleToFill
        return qrcodeView
    }()
    
    public lazy var amountSetBtn: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.setTitle(LocalizedString(key: "receive.amount.set", comment: ""), for: .normal)
        btn.setTitle(LocalizedString(key: "receive.amount.clear", comment: ""), for: .selected)
        btn.setTitleColor(AppTheme.Color.text_click, for: .normal)
        btn.setTitleColor(AppTheme.Color.text_click, for: .selected)
        btn.titleLabel?.font = AppTheme.Font.text_small
        return btn
    }()
    
    public lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_large.medium()
        label.textAlignment = .center
        return label
    }()
    
    public lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sepratorView: UIView = {
        let sepratorView = UIView()
        sepratorView.backgroundColor = AppTheme.Color.page_common
        return sepratorView
    }()
    
    public lazy var addressView: WKTextView = {
        let textView = createTextView()
        textView.font = AppTheme.Font.text_smaller
        textView.isEditable = false
        textView.delegate = self
        return textView
    }()
    
    public lazy var addressTipLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppTheme.Font.text_smaller
        label.textColor = AppTheme.Color.text_warning
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var showHideAddrBtn: UIButton = {
        let btn = createIconBtn(icon: UIImage(named: "receive_address_show"))
        btn.setImage(UIImage(named: "receive_address_hidden"), for: .selected)
        return btn
    }()
    
    public lazy var subAddressBtn: UIButton = {
        return createIconBtn(icon: UIImage(named: "receive_subaddress"))
    }()
    
    public lazy var copyAddressBtn: UIButton = {
        return createIconBtn(icon: UIImage(named: "receive_copy"))
    }()
    
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sepratorView.setBrokenLine()
        layer.setDefaultShadowStyle()
    }
    
    
    // MARK: - Configures
    
    internal func configureView() {
        
        backgroundColor = AppTheme.Color.page_common
        
        addSubViews([
        topBG,
//        triangleView,
        qrcodeView,
        amountSetBtn,
        amountLabel,
        priceLabel,
        sepratorView,
        addressView,
        addressTipLabel,
        showHideAddrBtn,
        subAddressBtn,
        copyAddressBtn,
        ])
    }
    
    internal func configureConstraints() {
        
        
        topBG.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(47)
        }
//        triangleView.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(topBG.snp.bottom)
//            make.width.equalTo(16)
//            make.height.equalTo(6)
//        }
        qrcodeView.snp.makeConstraints { (make) in
            make.top.equalTo(topBG.snp.bottom).offset(40)
            make.size.equalTo(120)
            make.centerX.equalToSuperview()
        }
        amountSetBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalTo(qrcodeView.snp.bottom).offset(9)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(amountSetBtn.snp.bottom).offset(10)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(amountLabel.snp.bottom).offset(3)
        }
        sepratorView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(priceLabel.snp.bottom).offset(22)
            make.height.equalTo(3)
        }
        addressView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(sepratorView.snp.bottom).offset(25)
        }
        addressTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(54)
            make.right.equalTo(-54)
            make.top.equalTo(addressView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        copyAddressBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.bottom.equalTo(addressView).offset(-5)
        }
        subAddressBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.equalTo(copyAddressBtn.snp.left).offset(-5)
            make.bottom.equalTo(copyAddressBtn)
        }
        showHideAddrBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.equalTo(subAddressBtn.snp.left).offset(-6)
            make.bottom.equalTo(subAddressBtn)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    // MARK: - Methods (Private)
    
    private func createTextView() -> WKTextView {
        let textView = WKTextView()
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 50, right: 10)
        textView.backgroundColor = AppTheme.Color.alert_textView
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.placeholderFont = AppTheme.Font.text_normal
        textView.font = AppTheme.Font.text_normal
        textView.textColor = AppTheme.Color.text_dark
        textView.placeholderColor = AppTheme.Color.text_light
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byCharWrapping
        return textView
    }
    
    private func createIconBtn(icon: UIImage?) -> UIButton {
        let btn = UIButton()
        btn.setImage(icon, for: .normal)
        return btn
    }
    
}

// MARK: -

extension ReceiveView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return !textView.isSecureTextEntry
    }
}
