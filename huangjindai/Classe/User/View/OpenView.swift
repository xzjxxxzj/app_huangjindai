//
//  OpenView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/12.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class OpenView: UIView {
    @IBOutlet weak var openName: UILabel!
    @IBOutlet weak var openValue: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func openView() -> OpenView {
        return Bundle.main.loadNibNamed("OpenView", owner: nil, options: nil)?.first as! OpenView
    }
}
