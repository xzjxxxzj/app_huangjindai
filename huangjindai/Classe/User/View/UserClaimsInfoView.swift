//
//  UserClaimsInfoView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/8.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class UserClaimsInfoView: UIView {
    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var dealNameWidth: NSLayoutConstraint!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var jindu: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var zrMoney: UILabel!
    @IBOutlet weak var zhekou: UILabel!
    @IBOutlet weak var yishouMoney: UILabel!
    @IBOutlet weak var leftMoney: UILabel!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func userClaimsInfoView() -> UserClaimsInfoView {
        return Bundle.main.loadNibNamed("UserClaimsInfoView", owner: nil, options: nil)?.first as! UserClaimsInfoView
    }

    func setDealName(_ name : String)
    {
        let stringFrame = PublicLib.countStringFrame(string: name, font: dealName.font)
        if stringFrame.width > 200 {
            dealNameWidth.constant = 200
        }else {
            dealNameWidth.constant = stringFrame.width + 10
        }
        dealName.text = name
    }
    
    func setRate(_ dealRate : Double, _ rebate : Double)
    {
        var rateString = "\(dealRate)%"
        if rebate > 0 {
            rateString = "\(rateString) + \(rebate)%"
        }
        rate.text = rateString
    }
    
}
