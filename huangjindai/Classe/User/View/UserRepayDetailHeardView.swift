//
//  UserRepayDetailView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/29.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class UserRepayDetailHeardView: UIView {

    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var jindu: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var youhui: UILabel!
    @IBOutlet weak var dealNameWith: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func userRepayDetailHeardView() -> UserRepayDetailHeardView {
        return Bundle.main.loadNibNamed("UserRepayDetailHeardView", owner: nil, options: nil)?.first as! UserRepayDetailHeardView
    }
    
    func setDealName(_ name : String)
    {
        let stringFrame = PublicLib.countStringFrame(string: name, font: dealName.font)
        if stringFrame.width > 200 {
            dealNameWith.constant = 200
        }else {
            dealNameWith.constant = stringFrame.width + 10
        }
        dealName.text = name
    }
}
