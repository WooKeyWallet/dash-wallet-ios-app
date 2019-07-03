//
//  ReceiveViewController.swift


import UIKit

class ReceiveViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let viewModel: ReceiveViewModel
    

    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var receiveView: ReceiveView = {
        return ReceiveView()
    }()
    
    
    // MARK: - Life Cycles
    
    init(viewModel: ReceiveViewModel) {
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
            navigationItem.title = viewModel.navigationTitle
        }
        
        do /// Subviews
        {
            scrollView.backgroundColor = AppTheme.Color.tableView_bg
            view.addSubview(scrollView)
            
            receiveView.addressTipLabel.text = viewModel.receiveTips
            scrollView.contentView.addSubview(receiveView)
            
            receiveView.snp.makeConstraints { (make) in
                make.top.equalTo(18)
                make.left.equalTo(25)
                make.right.equalTo(-25)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            // Btns
            receiveView.amountSetBtn.addTarget(self, action: #selector(amountSetAction(_:)), for: .touchUpInside)
            receiveView.showHideAddrBtn.addTarget(self, action: #selector(self.showHideAddressAction), for: .touchUpInside)
            receiveView.subAddressBtn.addTarget(self, action: #selector(self.toSubAddressAction), for: .touchUpInside)
            receiveView.copyAddressBtn.addTarget(self, action: #selector(self.copyAddressAction), for: .touchUpInside)
        }
        
        do /// ViewModel ->
        {
            
            viewModel.addressState.observe(self) { (text, _Self) in
                _Self.receiveView.addressView.text = text
                _Self.scrollView.resizeContentLayout()
            }
            
            viewModel.qrcodeState.observe(receiveView.qrcodeView) { (qrcode, imageView) in
                imageView.image = qrcode
            }
            
            viewModel.amountState.observe(receiveView.amountLabel) { (text, label) in
                label.text = text
            }
            
            viewModel.priceState.observe(receiveView.priceLabel) { (text, label) in
                label.text = text
            }
            
            viewModel.configure(receiveView: receiveView)
        }
                
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func amountSetAction(_ sender: UIButton) {
        let isSelected = sender.isSelected
        if isSelected {
            viewModel.removeAmount()
            sender.isSelected = false
        } else {
            ReceiveAmountAlertController.show { [unowned self] (amount) in
                self.viewModel.add(amount: amount)
                sender.isSelected = true
            }
        }
    }
    
    @objc private func showHideAddressAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        receiveView.addressView.isSecureTextEntry = sender.isSelected
        viewModel.showHideAddress(sender.isSelected)
    }
    
    @objc private func copyAddressAction() {
        viewModel.copyAddress()
    }
    
    @objc private func toSubAddressAction() {
        if let vc = viewModel.toSubAddress() {
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}

