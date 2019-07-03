//
//  CreateWalletViewController.swift


import UIKit


class CreateWalletViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: CreateWalletViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CreateWalletView = {
        let contentV = CreateWalletView(style: viewModel.style)
        contentV.backgroundColor = AppTheme.Color.page_common
        return contentV
    }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: CreateWalletViewModel) {
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
        do {
            self.navigationItem.title = viewModel.navigationTitle()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            contentView.walletNameField.addTarget(self, action: #selector(self.walletNameEidtingAction(_:)), for: .editingChanged)
            contentView.langSelectView.addTapGestureRecognizer(target: self, selector: #selector(selectLangAction))
            contentView.agreementBtn.addTarget(self, action: #selector(self.agreementAction(_:)), for: .touchDown)
            contentView.serviceBookBtn.handleCustomTap(for: contentView.serviceBookBtn.enabledTypes[0]) { [unowned self] (_) in
                self.navigationController?.pushViewController(self.viewModel.toServiceBook(), animated: true)
            }
            contentView.nextBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        }
        
        do /// ViewModel -> View
        {
            viewModel.nameTextState.observe(contentView.walletNameField) { (text, field) in
                field.text = text
            }
            
            viewModel.nameErrorState.observe(contentView.walletNameField) { (msg, field) in
                field.errorMessage = msg
            }
            
            viewModel.langState.observe(contentView.langSelectView.detailLabel) { (lang, label) in
                label.text = lang.localizedString
            }

            viewModel.agreementState.observe(contentView.agreementBtn) { (bool, btn) in
                btn.isSelected = bool
            }
            
            viewModel.nextState.observe(contentView.nextBtn) { (bool, btn) in
                btn.isEnabled = bool
            }
            
            viewModel.pushState.observe(self) { (vc, strongSelf) in
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func walletNameEidtingAction(_ sender: UITextField) {
        viewModel.nameFieldInput(sender.text!)
    }
    
    @objc private func selectLangAction() {
        viewModel.mnemonicSelectAction()
    }
    
    @objc private func agreementAction(_ sender: UIButton) {
        viewModel.agreementClick()
    }
    
    @objc private func confirmAction() {
        viewModel.nextClick()
    }

}
