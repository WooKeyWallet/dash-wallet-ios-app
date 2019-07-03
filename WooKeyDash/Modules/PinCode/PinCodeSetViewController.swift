//
//  PinCodeSetViewController.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/28.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class PinCodeSetViewController: BaseViewController {

    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Private)
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var topMessageBG: TopMessageBanner = {
        return TopMessageBanner.init(messages: [
            LocalizedString(key: "pin.set.tip1", comment: ""),
            LocalizedString(key: "pin.set.tip2", comment: "")
            ])
    }()
    
    private lazy var pinCodeView = {
        PinCodeView()
    }()
    
    
    // MARK: - Life Cycles
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "pin.set.title", comment: "")
        }
        
        do /// Subviews
        {
            view.addSubViews([
                topMessageBG,
                pinCodeView,
            ])
            
            do // auto layout
            {
                topMessageBG.snp.makeConstraints { (make) in
                    make.top.equalTo(44+UIApplication.shared.statusBarFrame.height)
                    make.left.right.equalToSuperview()
                }
                pinCodeView.snp.makeConstraints { (make) in
                    make.top.equalTo(topMessageBG.snp.bottom).offset(50)
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
            let vc = PinCodeConfirmViewController(pinCode: text)
            _Self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeView.becomeFirstResponder()
    }
    

}
