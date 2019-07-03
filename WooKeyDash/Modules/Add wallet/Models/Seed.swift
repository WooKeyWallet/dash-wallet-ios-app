//   
//   Seed.swift
//   WooKeyDash
//   
//  Created by WooKey Team on 2019/5/20
//   Copyright © 2019 WooKey. All rights reserved.
//   
	

import Foundation

public struct Seed {
    
    public let length = 12
    public let words: [String]
    
    public init?(words: [String]) {
        if words.count != length {
            return nil
        }
        self.words = words
    }
    
    public init?(sentence: String) {
        self.words = sentence.components(separatedBy: " ")
        if self.words.count != length {
            return nil
        }
    }
    
}


extension Seed {
    
    public var wordsWithoutChecksum: [String] {
        get {
            let slice = self.words[0 ..< self.length - 1]
            return Array(slice)
        }
    }
    
    public var sentence: String {
        get {
            return self.words.joined(separator: " ")
        }
    }
    
}
