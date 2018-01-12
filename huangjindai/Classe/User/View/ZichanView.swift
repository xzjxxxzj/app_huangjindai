//
//  ZichanView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/10.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class ZichanView: UIView {
    @IBOutlet weak var keyong: UILabel!
    
    @IBOutlet weak var shouyi: UILabel!
    
    @IBOutlet weak var benjin: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func zichanView() -> ZichanView {
        return Bundle.main.loadNibNamed("ZichanView", owner: nil, options: nil)?.first as! ZichanView
    }
}

