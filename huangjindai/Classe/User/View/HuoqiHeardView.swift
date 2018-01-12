//
//  HuoqiView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/11.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class HuoqiHeardView: UIView {
    @IBOutlet weak var yesterdayShouyi: UILabel!
    @IBOutlet weak var allMoney: UILabel!
    @IBOutlet weak var dottedLine: UIView!
    @IBOutlet weak var allShouyi: UILabel!
    @IBOutlet weak var wanFenShouyi: UILabel!
    @IBOutlet weak var rate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        addDottedLine()
    }
    
    class func huoqiHeardView() -> HuoqiHeardView {
        let heardView =  Bundle.main.loadNibNamed("HuoqiHeardView", owner: nil, options: nil)?.first as! HuoqiHeardView
        heardView.backgroundColor = UIColor(r: 99, g: 119, b: 246)
        return heardView
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
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.setLineCap(CGLineCap(rawValue: 1)!)
        context.setLineDash(phase: 0, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 5))
        context.addLine(to: CGPoint(x: kMobileW, y: 5))
        context.strokePath()
        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
}
