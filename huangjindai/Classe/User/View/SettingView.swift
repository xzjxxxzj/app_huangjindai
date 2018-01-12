//
//  SettingView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/12.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class SettingView: UIView {
    @IBOutlet weak var setName: UILabel!
    @IBOutlet weak var setValue: UILabel!
    @IBOutlet weak var setImage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func settingView() -> SettingView {
        return Bundle.main.loadNibNamed("SettingView", owner: nil, options: nil)?.first as! SettingView
    }
}
