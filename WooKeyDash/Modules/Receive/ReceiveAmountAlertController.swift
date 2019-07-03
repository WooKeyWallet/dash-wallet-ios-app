//
//  ReceiveAmountAlertController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/30.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class ReceiveAmountAlertController: BaseViewController {

    // MARK: - Properties (Private)
    
    private var result: ((Int64) -> Void)?
    
    private var isConfirmable: Bool {
        return (amountField.text ?? "").count > 0
    }
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        let alertView = CustomAlertView()
        alertView.spaceWithKeyboardOnShow = 25
        return alertView
    }()
    
    private lazy var amountTitleLab: UILabel = {
        let label = UILabel()
        label.text = "DASH"
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    private lazy var currencyTitleLab: UILabel = {
        let label = UILabel()
        label.text = WKDefaults.shared.currencyCode
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    private lazy var amountField: UITextField = {
        let field = UITextField()
        field.font = AppTheme.Font.text_small
        field.textColor = AppTheme.Color.text_dark
        field.backgroundColor = AppTheme.Color.alert_textView
        field.keyboardType = UIKeyboardType.decimalPad
        return field
    }()
    
    private lazy var priceField: UITextField = {
        let field = UITextField()
        field.font = AppTheme.Font.text_small
        field.textColor = AppTheme.Color.text_dark
        field.backgroundColor = AppTheme.Color.alert_textView
        field.keyboardType = UIKeyboardType.decimalPad
        return field
    }()
    
    private lazy var feildsBGArray: [UIView] = {
        return (0...1).map({
            let bg = UIView()
            bg.tag = $0
            bg.backgroundColor = AppTheme.Color.alert_textView
            bg.layer.cornerRadius = 5
            return bg
        })
    }()
    
    
    
    
    
    // MARK: - Life Cycles
    
    required init(result: ((Int64) -> Void)?) {
        self.result = result
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = contentView
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Subviews
        {
            // contentView
            contentView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            contentView.titleStatusView.backgroundColor = AppTheme.Color.status_green
            contentView.titleLabel.text = LocalizedString(key: "receive.amount.set", comment: "")
            contentView.cancelBtn.isHidden = false
            
            // textView
            contentView.customView.addSubViews([
                amountTitleLab,
                currencyTitleLab,
            ])
            contentView.customView.addSubViews(self.feildsBGArray)
            self.feildsBGArray[0].addSubview(amountField)
            self.feildsBGArray[1].addSubview(priceField)
            
            amountTitleLab.snp.makeConstraints { (make) in
                make.top.left.equalTo(0)
            }
            currencyTitleLab.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(feildsBGArray[1])
            }
            feildsBGArray[0].snp.makeConstraints { (make) in
                make.top.equalTo(amountTitleLab.snp.bottom).offset(0)
                make.left.equalTo(0)
                make.height.equalTo(42)
            }
            feildsBGArray[1].snp.makeConstraints { (make) in
                make.top.equalTo(currencyTitleLab.snp.bottom).offset(0)
                make.left.equalTo(feildsBGArray[0].snp.right).offset(10)
                make.right.equalTo(0)
                make.height.equalTo(42)
                make.width.equalTo(feildsBGArray[0].snp.width)
                make.bottom.equalToSuperview().offset(-8)
            }
            amountField.snp.makeConstraints { (make) in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.top.bottom.equalTo(0)
            }
            priceField.snp.makeConstraints { (make) in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.top.bottom.equalTo(0)
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        contentView.confirmBtn.isEnabled = false
        /// Actions
        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        amountField.addTarget(self, action: #selector(eidtAmountAction(_:)), for: .editingChanged)
        priceField.addTarget(self, action: #selector(eidtPriceAction(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountField.becomeFirstResponder()
    }
    
    // MARK: - Methods (Public)
    
    public class func show(_ result: ((Int64) -> Void)?) {
        let vc = self.init(result: result)
        vc.modalPresentationStyle = .overCurrentContext
        AppManager.default.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    // MARK: - Methods (Public)
    
    private func checkConfirmValid() {
        contentView.confirmBtn.isEnabled = isConfirmable
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func eidtAmountAction(_ field: UITextField) {
        let text = field.text ?? ""
        if text != "" {
            let amount = DSPriceManager.sharedInstance().amount(forDashString: text)
            priceField.text = Helper.priceForDash(UInt64(amount))
        } else {
            priceField.text = ""
        }
        checkConfirmValid()
    }
    
    @objc private func eidtPriceAction(_ field: UITextField) {
        let text = field.text ?? ""
        if text != "" {
            let amount = DSPriceManager.sharedInstance().amount(forLocalCurrencyString: text)
            amountField.text = DSPriceManager.sharedInstance().attributedString(forDashAmount: amount)?.string
        } else {
            amountField.text = ""
        }
        checkConfirmValid()
    }
    
    @objc private func cancelAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func confirmAction(_ text: String) {
        let amount = DSPriceManager.sharedInstance().amount(forDashString: amountField.text!)
        result?(amount)
        self.dismiss(animated: false, completion: nil)
    }

}
