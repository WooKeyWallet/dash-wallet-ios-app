//
//  AddSubAddressController.swift
//  Wookey
//
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class AddSubAddressController: BaseViewController {

    // MARK: - Properties (Public)
    
    public let viewModel: SubAddressViewModel
    
    public var editIndex: Int?
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        return CustomAlertView()
    }()
    
    private lazy var textView: WKTextView = {
        let textV = WKTextView()
        textV.font = AppTheme.Font.text_small
        textV.placeholderFont = AppTheme.Font.text_small
        textV.placeholder = LocalizedString(key: "wallet.subAddress.add.placeholder", comment: "")
        textV.placeholderColor = AppTheme.Color.text_light
        textV.textColor = AppTheme.Color.text_dark
        textV.textContainer.lineFragmentPadding = 0
        textV.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        textV.backgroundColor = AppTheme.Color.alert_textView
        textV.layer.cornerRadius = 5
        textV.isScrollEnabled = false
        return textV
    }()
    
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: SubAddressViewModel) {
        self.viewModel = viewModel
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
            contentView.titleLabel.text = LocalizedString(key: "wallet.subAddress.add.title", comment: "")
            
            // textView
            contentView.customView.addSubview(textView)
            textView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
            contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
            contentView.confirmBtn.isEnabled = false
            
            textView.textDidChangedClosure = {
            [unowned self] (textView) in
                let text = textView.text ?? ""
                self.contentView.confirmBtn.isEnabled = text.count > 0
                if text.size() > 20 {
                    textView.text = String(text.prefix(text.count - 1))
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func cancelAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func confirmAction() {
        if let row = editIndex {
            viewModel.editSubAddress(label: textView.text, row: row)
        } else {
            viewModel.addSubAddress(label: textView.text)
        }
        dismiss(animated: false, completion: nil)
    }

}
