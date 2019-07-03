//
//  PinCodeView.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/28.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class PinCodeView: UIView {
    
    // MARK: - Properties (Public)
    
    lazy var textChangedState = { Postable<String>() }()
    

    // MARK: - Properties (Private)
    
    private lazy var textField: UITextField = {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        field.keyboardType = UIKeyboardType.numberPad
        field.textColor = UIColor.white
        field.tintColor = UIColor.white
        return field
    }()
    
    private lazy var dotsArray: [UIView] = {
        (0...5).map({ i -> UIView in
            let dot = UIView()
            dot.layer.cornerRadius = 12.5
            dot.backgroundColor = AppTheme.Color.words_bg
            return dot
        })
    }()
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.white
        self.configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(textField)
        addSubViews(dotsArray)
        
        textField.addTarget(self, action: #selector(editingChangedAction), for: .editingChanged)
        addTapGestureRecognizer(target: self, selector: #selector(touchEditingAction))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var X = CGFloat(0)
        let Y = height * 0.5 - 12.5
        let space = (width - CGFloat(dotsArray.count) * 25) / 5
        dotsArray.forEach { (sub) in
            sub.updateFrame(CGRect(x: X, y: Y, width: 25, height: 25))
            X = sub.maxX + space
        }
    }
    
    private func updateDotColorsIfNeed(_ text: String) {
        stride(from: 0, to: dotsArray.count, by: 1).forEach { (i) in
            let dot = dotsArray[i]
            if i < text.count {
                dot.backgroundColor = AppTheme.Color.main_green_light
            } else {
                dot.backgroundColor = AppTheme.Color.words_bg
            }
        }
    }
    
    // MARK: - Methods (Action)
    
    @objc func reset() {
        textField.text = ""
        updateDotColorsIfNeed("")
    }
    
    @objc private func editingChangedAction() {
        let text = textField.text ?? ""
        guard text.count <= dotsArray.count else {
            textField.text = String(text.prefix(dotsArray.count))
            return
        }
        updateDotColorsIfNeed(text)
        textChangedState.newState(text)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @objc private func touchEditingAction() {
        textField.becomeFirstResponder()
    }
    
}
