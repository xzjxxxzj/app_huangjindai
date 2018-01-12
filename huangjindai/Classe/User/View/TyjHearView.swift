//
//  TyjHearView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/25.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class TyjHearView: UIView {
    @IBOutlet weak var canUse: UILabel!
    @IBOutlet weak var jihuo: UILabel!
    @IBOutlet weak var jihuoBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func tyjHearView() -> TyjHearView {
        return Bundle.main.loadNibNamed("TyjHearView", owner: nil, options: nil)?.first as! TyjHearView
    }
}
