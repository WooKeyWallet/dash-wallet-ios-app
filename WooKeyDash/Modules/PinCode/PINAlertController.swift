//
//  PINAlertController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/28.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class PINAlertController: BaseViewController {

    // MARK: - Properties (Private)
    
    private var loginHandler: ((Bool) -> Void)?
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        let alertView = CustomAlertView()
        alertView.showConfirm = false
        return alertView
    }()
    
    private lazy var pwdBG: UIView = {
        let bg = UIView()
        bg.backgroundColor = AppTheme.Color.alert_textView
        bg.layer.cornerRadius = 5
        return bg
    }()
    
    private lazy var pinCodeView = {
        PinCodeView()
    }()
    
    private lazy var errorMessageLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_warning
        label.font = AppTheme.Font.text_smaller
        label.numberOfLines = 0
        return label
    }()
    
    
    // MARK: - Life Cycles
    
    required init(loginHandler: ((Bool) -> Void)?) {
        self.loginHandler = loginHandler
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
            contentView.titleLabel.text = LocalizedString(key: "pin.alert.title", comment: "")
            contentView.confirmBtn.isHidden = true
            contentView.cancelBtn.isHidden = false
            
            // textView
            contentView.customView.addSubViews([
                pinCodeView,
                errorMessageLab,
                ])
            pinCodeView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.width.equalTo(225)
                make.height.equalTo(40)
                make.centerX.equalToSuperview()
            }
            errorMessageLab.snp.makeConstraints { (make) in
                make.top.equalTo(pinCodeView.snp.bottom).offset(10)
                make.left.right.equalTo(pinCodeView)
                make.bottom.equalToSuperview()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        //        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        pinCodeView.textChangedState.observe(self) { (text, _Self) in
            guard text.count == 6 else { return }
            _Self.confirmAction(text)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeView.becomeFirstResponder()
    }
    
    // MARK: - Methods (Public)
    
    public class func show(_ cancelHidden: Bool = true, loginResult: ((Bool) -> Void)?) {
        guard WKAuthenticator.shared.hasPin else {
            loginResult?(true)
            return
        }
        let vc = self.init(loginHandler: loginResult)
        vc.modalPresentationStyle = .overCurrentContext
        vc.contentView.cancelBtn.isHidden = cancelHidden
        AppManager.default.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func pwdInputAction(_ field: UITextField) {
        
    }
    
    @objc private func cancelAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func confirmAction(_ text: String) {
        guard WKAuthenticator.shared.verifyPasscode(text) else {
            self.errorMessageLab.text = LocalizedString(key: "wallet.login.error", comment: "")
            loginHandler?(false)
            self.pinCodeView.reset()
            return
        }
        loginHandler?(true)
        self.dismiss(animated: false, completion: nil)
    }

}
