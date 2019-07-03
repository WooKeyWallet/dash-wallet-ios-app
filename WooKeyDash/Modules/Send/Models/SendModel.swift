//
//  SendModel.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/6/4.
//  Copyright © 2019 WooKey. All rights reserved.
//

import Foundation

struct SendModel {
    let tx: DSTransaction
    let address: String
    let amount: UInt64
    let fee: UInt64
    let request: DSPaymentProtocolRequest
    
    init(tx: DSTransaction,
    address: String,
     amount: UInt64,
        fee: UInt64,
        request: DSPaymentProtocolRequest)
    {
        self.tx = tx
        self.address = address
        self.amount = amount
        self.fee = fee
        self.request = request
    }
}
