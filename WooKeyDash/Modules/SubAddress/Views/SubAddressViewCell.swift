//
//  SubAddressViewHeader.swift
//  Wookey
//
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewCell: BaseTableViewCell {
    
    // MARK: - Properties (Lazy)
    
    private lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "label_edit_btn"), for: .normal)
        return btn
    }()
    
    private lazy var labelLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.text_normal
        label.textColor = AppTheme.Color.text_dark
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.text_small
        label.textColor = AppTheme.Color.text_light
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var copyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "receive_copy"), for: .normal)
        return btn
    }()
    
    private lazy var optionImageView: UIImageView = {
        return UIImageView()
    }()
    
    private var address: String = ""
    
    private var actionHandler: ((Any) -> Void)?
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        addSubViews([
        editBtn,
        labelLabel,
        addressLabel,
        copyBtn,
        optionImageView,
        ])
        
        copyBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        editBtn.addTarget(self, action: #selector(editBtnAction), for: .touchUpInside)
    }
    
    override func frameLayout() {
        editBtn.updateFrame(CGRect(x: 19, y: 12, width: 30, height: 30))
        labelLabel.updateFrame(CGRect(x: editBtn.maxX, y: 18, width: width - 80, height: labelLabel.font.lineHeight))
        addressLabel.updateFrame(CGRect(x: 25, y: labelLabel.maxY + 11, width: 220, height: addressLabel.font.lineHeight))
        copyBtn.updateFrame(CGRect(x: addressLabel.maxX, y: addressLabel.midY - 15, width: 30, height: 30))
        optionImageView.updateFrame(CGRect(x: width - 40, y: height * 0.5 - 10, width: 20, height: 20))
    }
    
    override func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
        guard let model: SubAddressFrame = row.serializeModel() else { return }
        labelLabel.text = model.label
        addressLabel.text = model.address
        optionImageView.image = model.optionIcon
        address = model.address
    }
    
    @objc private func copyAction() {
        UIPasteboard.general.string = address
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    @objc private func editBtnAction() {
        actionHandler?(0)
    }
    
}
