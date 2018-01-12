//
//  RechargeView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/21.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class RechargeView: UIView {

    @IBOutlet weak var money: UITextField!
    @IBOutlet weak var rechargeClick: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func rechargeView() -> RechargeView {
        return Bundle.main.loadNibNamed("RechargeView", owner: nil, options: nil)?.first as! RechargeView
    }

}
