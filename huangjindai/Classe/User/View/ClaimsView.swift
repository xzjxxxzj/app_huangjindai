//
//  ClaimsView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/6.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClaimsView: UIView {
    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var dealNameWidth: NSLayoutConstraint!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var jindu: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var zrmoney: UITextField!
    @IBOutlet weak var zhekou: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var jiazhi: UILabel!
    @IBOutlet weak var shishou: UILabel!
    @IBOutlet weak var feeMoney: UILabel!
    @IBOutlet weak var tishiImg: UIImageView!
    @IBOutlet weak var tishiTetle: UILabel!
    @IBOutlet weak var tishiContent: UILabel!
    @IBOutlet weak var claimsBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        setZrjin()
        tishiImg.isHidden = true
        tishiTetle.isHidden = true
        tishiContent.isHidden = true
    }
    
    class func claimsView() -> ClaimsView {
        return Bundle.main.loadNibNamed("ClaimsView", owner: nil, options: nil)?.first as! ClaimsView
    }

    fileprivate func setZrjin()
    {
        zrmoney.borderStyle = UITextBorderStyle.none
        zrmoney.clearButtonMode = .whileEditing
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
    
    func setTishi(_ content : JSON)
    {
        if content.count > 0 {
            tishiImg.isHidden = false
            tishiTetle.isHidden = false
            tishiContent.isHidden = false
            var contentTxt = ""
            for (_, text) : (String, JSON) in content {
                contentTxt = "\(contentTxt)\(text)\n"
            }
            //设置行间距
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            let tishiStr : NSMutableAttributedString = NSMutableAttributedString(string: contentTxt)
            tishiStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, contentTxt.count))
            tishiContent.attributedText = tishiStr
        }
    }
}
