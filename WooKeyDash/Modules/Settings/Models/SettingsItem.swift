//
//  SettingsItem.swift


import UIKit

public enum SettingsItemType {
    case wallet  // 钱包管理
    case pin     // pin码
    case token   // 地址簿
    case currency// 货币单位
    case lang    // 语言
    case help    // 帮助中心
    case about   // 关于我们
}

struct SettingsItem {
    var icon: UIImage?
    var name: String = ""
    var text: String = ""
}


