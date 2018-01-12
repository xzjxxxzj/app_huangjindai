//
//  UserInvestListView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/1.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class UserInvestListView: UIView {
    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var dealNameWith: NSLayoutConstraint!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstMoney: UILabel!
    @IBOutlet weak var centerName: UILabel!
    @IBOutlet weak var centerMoney: UILabel!
    @IBOutlet weak var endName: UILabel!
    @IBOutlet weak var endMoney: UILabel!
    @IBOutlet weak var line: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addLine()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func userInvestListView() -> UserInvestListView {
        return Bundle.main.loadNibNamed("UserInvestListView", owner: nil, options: nil)?.first as! UserInvestListView
    }
    
    func addLine()
    {
        let imgView : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0 , width: kMobileW - 40, height: 3))
        line.addSubview(imgView)
        UIGraphicsBeginImageContext(imgView.frame.size)
        imgView.image?.draw(in: imgView.bounds)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(CGLineCap.square)
        
        let lengths:[CGFloat] = [2,3]
        
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(1)
        context.setLineCap(CGLineCap(rawValue: 1)!)
        context.setLineDash(phase: 0, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 3))
        context.addLine(to: CGPoint(x: kMobileW - 20, y: 3))
        context.strokePath()
        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func setDealName(_ name : String)
    {
        let stringFrame = PublicLib.countStringFrame(string: name, font: dealName.font)
        if stringFrame.width > 160 {
            dealNameWith.constant = 160
        }else {
            dealNameWith.constant = stringFrame.width + 10
        }
        dealName.text = name
    }
}
