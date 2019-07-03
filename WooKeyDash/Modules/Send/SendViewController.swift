//
//  SendViewController.swift


import UIKit

class SendViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let viewModel: SendViewModel
    

    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var header: SendViewHeader = {
        return SendViewHeader()
    }()
    
    private lazy var detailView: SendDetailView = {
        return SendDetailView()
    }()
    
    // MARK: - Life Cycles
    
    required init(viewModel: SendViewModel) {
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
            scrollView.backgroundColor = AppTheme.Color.page_common
            view.addSubview(scrollView)

            let separatorView = UIView()
            separatorView.backgroundColor = AppTheme.Color.tableView_bg
            
            scrollView.contentView.addSubViews([
            header,
            separatorView,
            detailView,
            ])
            
            header.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
            separatorView.snp.makeConstraints { (make) in
                make.top.equalTo(header.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(10)
            }
            detailView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(separatorView.snp.bottom)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_item_scan"), style: .plain, target: self, action: #selector(self.scanAction))
            
            detailView.toAddressField.tag = 19_1
            detailView.toAddressField.delegate = self
            detailView.amountField.tag = 19_2
            detailView.amountField.delegate = self
            
            detailView.sendBtn.addTarget(self, action: #selector(self.sendAction), for: .touchUpInside)
            detailView.addressSelectBtn.addTarget(self, action: #selector(self.addressSelectAction), for: .touchUpInside)
            detailView.allinBtn.addTarget(self, action: #selector(self.allinAction), for: .touchUpInside)
        }
        
        do /// ViewModel ->
        {
            viewModel.configureHeader(header)
            
            viewModel.pushState.observe(self) { (vc, _Self) in
                _Self.navigationController?.pushViewController(vc, animated: true)
            }
            
            viewModel.addressState.observe(detailView.toAddressField) { (text, field) in
                guard field.text != text else { return }
                field.text = text
            }
            viewModel.amountState.observe(detailView.amountField) { (text, field) in
                guard field.text != text else { return }
                field.text = text
            }
            viewModel.priceState.observe(detailView.priceLabel) { (text, label) in
                label.text = text
            }
            viewModel.feeState.observe(detailView.feeLabel) { (text, label) in
                label.text = text
            }
            
            viewModel.sendState.observe(self) { (enable, strongSelf) in
                strongSelf.detailView.sendBtn.isEnabled = enable
                if enable {
                    strongSelf.scrollView.resizeContentLayout()
                }
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func scanAction() {
        navigationController?.pushViewController(viewModel.toScan(), animated: true)
    }
    
    @objc private func sendAction() {
        viewModel.send()
    }
    
    @objc private func addressSelectAction() {
        let vc = viewModel.toSelectAddress()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func allinAction() {
        viewModel.allin()
    }

}


// MARK: - TextView Delegate

extension SendViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 19_1:
            viewModel.inputAddress(textView.text)
        case 19_2:
            viewModel.inputAmount(textView.text)
        default:
            break
        }
    }
}
