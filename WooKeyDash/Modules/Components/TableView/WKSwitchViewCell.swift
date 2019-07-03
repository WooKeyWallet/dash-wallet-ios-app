//
//  WKSwitchViewCell.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/29.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class WKSwitchViewCell: BaseTableViewCell {
    
    struct Model {
        var isOn: Bool = false
        var title: String = ""
    }
    
    // MARK: - Properties (Private)
    
    private lazy var switchBtn: UISwitch = {
        let btn = UISwitch(frame: .zero)
        btn.onTintColor = AppTheme.Color.main_green_light
        return btn
    }()
    
    private var actionHandler: ((Any) -> Void)?
    
    
    // MARK: - Life Cycles

    override func initCell() {
        super.initCell()
        
        nameLabel.font = AppTheme.Font.text_normal
        
        addSubViews([
        nameLabel,
        switchBtn,
        ])
        
        switchBtn.addTarget(self, action: #selector(switchAction), for: .valueChanged)
    }
    
    override func frameLayout() {
        switchBtn.updateFrame(CGRect(x: width - 70, y: height * 0.5 - 15, width: 50, height: 30))
        nameLabel.updateFrame(CGRect(x: 25, y: (height - nameLabel.font.lineHeight) * 0.5, width: switchBtn.x - 40, height: nameLabel.font.lineHeight))
    }
    
    override func configure(with row: TableViewRow) {
        actionHandler = row.actionHandler
        guard let model: Model = row.serializeModel() else { return }
        nameLabel.text = model.title
        switchBtn.isOn = model.isOn
    }
    
    // MARK: - Methods (Action)
    
    @objc private func switchAction() {
        actionHandler?(switchBtn)
    }

}
