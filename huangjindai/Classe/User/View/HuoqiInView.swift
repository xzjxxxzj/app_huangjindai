//
//  HuoqiInView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/12.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class HuoqiInView: UIView {
    @IBOutlet weak var leftMoney: UILabel!
    @IBOutlet weak var dottedLine: UIView!
    @IBOutlet weak var moneyTest: UITextField!
    @IBOutlet weak var allIn: UIButton!
    @IBOutlet weak var userMoney: UILabel!
    @IBOutlet weak var InBtn: UIButton!
    @IBOutlet weak var shouyi: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        addDottedLine()
        moneyTest.borderStyle = UITextBorderStyle.none
    }
    
    class func huoqiInView() -> HuoqiInView {
        return  Bundle.main.loadNibNamed("HuoqiInView", owner: nil, options: nil)?.first as! HuoqiInView
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

}
