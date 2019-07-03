//
//  SubAddressFrame.swift
//  Wookey
//
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

struct SubAddressFrame {
    
    let label: String
    let address: String
    let optionIcon: UIImage?
    
    init(model: SubAddress, usedAddress: String) {
        self.label = model.label
        self.address = model.address
        if model.address == usedAddress {
            self.optionIcon = UIImage(named: "node_option_selected")
        } else {
            self.optionIcon = UIImage(named: "node_option_normal")
        }
    }
}
