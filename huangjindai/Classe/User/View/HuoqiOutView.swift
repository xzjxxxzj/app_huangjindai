//
//  HuoqiOutView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/12.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

class HuoqiOutView: UIView {
    @IBOutlet weak var userMoney: UILabel!
    @IBOutlet weak var dottedLine: UIView!
    @IBOutlet weak var moneyText: UITextField!
    @IBOutlet weak var allOut: UIButton!
    @IBOutlet weak var outBtn: UIButton!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var getFee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        addDottedLine()
        moneyText.borderStyle = UITextBorderStyle.none
    }
    
    class func huoqiOutView() -> HuoqiOutView {
        return  Bundle.main.loadNibNamed("HuoqiOutView", owner: nil, options: nil)?.first as! HuoqiOutView
    }
    
    fileprivate func addDottedLine()
    {
        let imgView : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0 , width: kMobileW, height: 5))
        dottedLine.addSubview(imgView)
        UIGraphicsBeginImageContext(imgView.frame.size)
        imgView.image?.draw(in: imgView.bounds)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(CGLineCap.square)
        
        let lengths:[CGFloat] = [2,3]
        
        context.setStrokeColor(UIColor(r: 204, g: 204, b: 204).cgColor)
        context.setLineWidth(1)
        context.setLineCap(CGLineCap(rawValue: 1)!)
        context.setLineDash(phase: 0, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 5))
        context.addLine(to: CGPoint(x: kMobileW, y: 5))
        context.strokePath()
        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func setFee(_ data : JSON)
    {
        if data.count > 0 {
            fee.isHidden = false
            var contentTxt = ""
            for (_, text) : (String, JSON) in data {
                contentTxt = "\(contentTxt)\(text)\n"
            }
            //设置行间距
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            let tishiStr : NSMutableAttributedString = NSMutableAttributedString(string: contentTxt)
            tishiStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, contentTxt.count))
            fee.attributedText = tishiStr
        }
    }
}
