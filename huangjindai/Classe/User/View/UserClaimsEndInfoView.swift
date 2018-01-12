//
//  UserClaimsEndInfoView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/8.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserClaimsEndInfoView: UIView {
    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var dealNameWidth: NSLayoutConstraint!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var jindu: UILabel!
    @IBOutlet weak var zrMoney: UILabel!
    @IBOutlet weak var zhekou: UILabel!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var shishouMoney: UILabel!
    @IBOutlet weak var zcMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func userClaimsEndInfoView() -> UserClaimsEndInfoView {
        return Bundle.main.loadNibNamed("UserClaimsEndInfoView", owner: nil, options: nil)?.first as! UserClaimsEndInfoView
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
    
    func setList(_ buyList : JSON)
    {
        if buyList.count > 0 {
            var index : Int = 0
            for (_, text) : (String, JSON) in buyList {
                let list = ClaimsBuyListView.claimsBuyListView()
                list.oneLabel.text = text["userId"].stringValue
                list.towLabel.text = "\(text["benjin"].doubleValue)"
                list.threeLabel.text = "\(text["buyMoney"].doubleValue)"
                list.endLabel.text = text["createTime"].stringValue
                list.frame = CGRect(x: 0, y: 40 * CGFloat(index), width: kMobileW, height: 40)
                index = index + 1
                listView.addSubview(list)
            }
        }
    }
}
