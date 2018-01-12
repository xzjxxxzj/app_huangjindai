//
//  InviteDetailView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/13.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

class InviteDetailView: UIView {
    @IBOutlet weak var isGetMoney: UILabel!
    @IBOutlet weak var isInvitePeople: UILabel!
    @IBOutlet weak var guizhe: UILabel!
    @IBOutlet weak var monthRegiestNum: UILabel!
    @IBOutlet weak var monthInvestNum: UILabel!
    @IBOutlet weak var monthInvestMoney: UILabel!
    @IBOutlet weak var monthWillGetMoney: UILabel!
    @IBOutlet weak var allRegiestNum: UILabel!
    @IBOutlet weak var allInvestNum: UILabel!
    @IBOutlet weak var allInviteMoney: UILabel!
    @IBOutlet weak var allNotPayMoney: UILabel!
    @IBOutlet weak var lastView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func inviteDetailView() -> InviteDetailView {
        return  Bundle.main.loadNibNamed("InviteDetailView", owner: nil, options: nil)?.first as! InviteDetailView
    }
    
    public func setGuizhe(_ list : JSON)
    {
        if list.count > 0 {
            var contentTxt = ""
            for (_, text) : (String, JSON) in list {
                contentTxt = "\(contentTxt)\(text)\n"
            }
            //设置行间距
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            let tishiStr : NSMutableAttributedString = NSMutableAttributedString(string: contentTxt)
            tishiStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, contentTxt.count))
            guizhe.attributedText = tishiStr
            guizhe.sizeToFit()
        }
    }
}
