//
//  WalletSyncings.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/24.
//  Copyright © 2019 WooKey. All rights reserved.
//

import Foundation

struct WalletSyncings: Equatable {
    
    let progress: CGFloat
    let estimatedBlockHeight: UInt32
    let lastBlockHeight: UInt32
    let leftBlockHeight: UInt32
    
    var leftBlocksString: String {
        if estimatedBlockHeight == 0 {
            return ""
        }
        return String(leftBlockHeight)
    }
    
    let finished: Bool
        
    init(chainManager: DSChainManager) {
        
        let chain = chainManager.chain
        let estimatedBlockHeight = chain.estimatedBlockHeight
        let lastBlockHeight = chain.lastBlockHeight
        let leftInfo = estimatedBlockHeight.subtractingReportingOverflow(lastBlockHeight)
        let leftBlocks: UInt32
        
        if leftInfo.overflow || estimatedBlockHeight == 0 {
            leftBlocks = 1
        } else {
            leftBlocks = leftInfo.partialValue
        }
        
        let finished = leftBlocks == 0
        let progress = finished ? 1 : CGFloat(chainManager.syncProgress)
        
        self.progress = progress
        self.lastBlockHeight = lastBlockHeight
        self.estimatedBlockHeight = estimatedBlockHeight
        self.leftBlockHeight = leftBlocks
        self.finished = finished
    }
}
