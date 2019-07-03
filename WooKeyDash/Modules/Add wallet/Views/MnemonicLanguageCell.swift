//
//  MnemonicLanguageCell.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/27.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class MnemonicLanguageCell: UIView {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "wallet.create.words.lang", comment: "")
        label.font = AppTheme.Font.text_normal
        label.textColor = AppTheme.Color.text_dark
        return label
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.text_normal
        label.textColor = AppTheme.Color.text_light
        return label
    }()
    
    private lazy var arrow: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "cell_arrow_right")
        return arrow
    }()
    
    private lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = AppTheme.Color.cell_line
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppTheme.Color.cell_bg
        addSubViews([
            titleLabel,
            detailLabel,
            arrow,
            bottomLine,
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
        }
        detailLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrow.snp.left).offset(-10)
            make.centerY.equalTo(titleLabel)
        }
        arrow.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.centerY.equalTo(detailLabel)
            make.size.equalTo(CGSize(width: 8, height: 13))
        }
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
    
}
