//
//  PinCodeConfirmViewController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/28.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class PinCodeConfirmViewController: BaseViewController {

    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Private)
    
    private let pinCode: String
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "pin.confirm.subTitle", comment: "")
        label.font = AppTheme.Font.text_normal.medium()
        label.textColor = AppTheme.Color.text_dark
        return label
    }()
    
    private lazy var pinCodeView = {
        PinCodeView()
    }()
    
    
    // MARK: - Life Cycles
    
    required init(pinCode: String) {
        self.pinCode = pinCode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "pin.set.title", comment: "")
        }
        
        do /// Subviews
        {
            view.addSubViews([
                subTitleLabel,
                pinCodeView,
            ])
            
            do // auto layout
            {
                subTitleLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(124+UIApplication.shared.statusBarFrame.height)
                    make.centerX.equalToSuperview()
                }
                pinCodeView.snp.makeConstraints { (make) in
                    make.top.equalTo(subTitleLabel.snp.bottom).offset(50)
                    make.width.equalTo(250)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(40)
                }
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        pinCodeView.textChangedState.observe(self) { (text, _Self) in
            guard text.count == 6 else {
                return
            }
            guard text == _Self.pinCode else {
                _Self.pinCodeView.reset()
                HUD.showError(LocalizedString(key: "confirm_password_invalid", comment: ""))
                return
            }
            let hasPin = WKAuthenticator.shared.hasPin
            WKAuthenticator.shared.setPasscode(text)
            if hasPin {
                HUD.showSuccess(LocalizedString(key: "pin.change.success", comment: ""))
                AppManager.default.rootViewController?.popTo(2)
            } else {
                HUD.showSuccess(LocalizedString(key: "pin.set.success", comment: ""))
                AppManager.default.rootIn()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeView.becomeFirstResponder()
    }
}
