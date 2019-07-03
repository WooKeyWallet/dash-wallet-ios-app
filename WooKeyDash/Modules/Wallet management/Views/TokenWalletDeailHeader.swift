//
//  TokenWalletDeailHeader.swift


import UIKit

class TokenWalletDeailHeaderCell: BaseTableViewCell {
    
    // MARK: - Properties (Private)
    
    private var actionHandler: ((Any) -> Void)?
    

    // MARK: - Properties (Lazy)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.textAlignment = .center
        label.font = AppTheme.Font.text_small
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_huge
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.textAlignment = .center
        label.font = AppTheme.Font.text_small
        return label
    }()
    
    
    // MARK: - Life Cycle
    
    override func initCell() {
        super.initCell()
        configureViews()
        configureConstaints()
    }
    
    private func configureViews() {
        backgroundColor = AppTheme.Color.page_common
        addSubViews([
            titleLabel,
            amountLabel,
            priceLabel,
        ])
    }
    
    private func configureConstaints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(25)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(amountLabel.snp.bottom).offset(3)
        }
    }
    
    override func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
        guard let model: TokenWalletDetail = row.serializeModel() else { return }
        titleLabel.text = LocalizedString(key: "assets.prefix", comment: "") + "(\(model.token))"
        amountLabel.text = model.assets
        priceLabel.text = model.price
    }
    
    // MARK: - Methods (Action)
    
    @objc private func copyAction() {
        actionHandler?(0)
    }
}
