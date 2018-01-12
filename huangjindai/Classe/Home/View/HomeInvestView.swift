//
//  HomeInvestView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/31.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class HomeInvestView: UIView {
    @IBOutlet weak var dealNameWith: NSLayoutConstraint!
    
    @IBOutlet weak var dealName: UILabel!
    
    @IBOutlet weak var teshuTag: UILabel!
    
    @IBOutlet weak var month: UILabel!
    
    @IBOutlet weak var rate: UILabel!
    
    @IBOutlet weak var dealType: UILabel!
    
    @IBOutlet weak var investView: UIView!
    
    @IBOutlet weak var dealId: UILabel!
    
    @IBOutlet weak var daijinquan: UILabel!
    
    @IBOutlet weak var jiaxiquan: UILabel!
    
    @IBOutlet weak var randView: UIView!
    
    @IBOutlet weak var daijinquanYs: NSLayoutConstraint!
    
    fileprivate var jinduValue : CGFloat = 0
    {
        didSet
        {
            dongqilai()
        }
    }
    
    fileprivate var zhuangtai : String = "融资中"
    {
        didSet
        {
            dongqilai()
        }
    }
    //进度条文字
    fileprivate lazy var jinduText: UILabel = {
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: randView.frame.width, height: randView.frame.height))
        text.numberOfLines = 2
        text.text = "0%\n融资中"
        text.font = UIFont.systemFont(ofSize: 11)
        text.textAlignment = NSTextAlignment.center
        text.textColor = UIColor(r: 204, g: 204, b: 204)
        return text
    }()
    //圆形进度条
    fileprivate lazy var cireView: JinduView = {
        let cireView = JinduView.init(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        return cireView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        teshu()
        daijin()
        jiaxi()
        addJindu()
    }
}

extension HomeInvestView {
    
    class func homeInvestView() -> HomeInvestView {
        return Bundle.main.loadNibNamed("HomeInvestView", owner: nil, options: nil)?.first as! HomeInvestView
    }
    //特殊标的标识
    fileprivate func teshu() {
        teshuTag.isHidden = true
        teshuTag.layer.borderWidth = 1
        teshuTag.layer.borderColor = UIColor.orange.cgColor
        teshuTag.layer.cornerRadius = teshuTag.frame.height/2
    }
    
    //设置标的名称
    func setDealName(_ name : String)
    {
        let stringFrame = PublicLib.countStringFrame(string: name, font: dealName.font)
        if stringFrame.width > 170 {
            dealNameWith.constant = 170
        }else {
            dealNameWith.constant = stringFrame.width + 10
        }
        dealName.text = name
    }
    
    //代金券
    fileprivate func daijin() {
        daijinquan.isHidden = true
        daijinquan.layer.borderWidth = 1
        daijinquan.layer.borderColor = UIColor.orange.cgColor
        daijinquan.layer.cornerRadius = daijinquan.frame.height/2
    }
    //加息券
    fileprivate func jiaxi() {
        jiaxiquan.isHidden = true
        jiaxiquan.layer.borderWidth = 1
        jiaxiquan.layer.borderColor = UIColor.orange.cgColor
        jiaxiquan.layer.cornerRadius = jiaxiquan.frame.height/2
    }
    //底部虚线
    func addLine(_ y : CGFloat) {
        let imgView : UIImageView = UIImageView(frame: CGRect(x: 0, y: y - 35 , width: kMobileW, height: 10))
        investView.addSubview(imgView)
        UIGraphicsBeginImageContext(imgView.frame.size)
        imgView.image?.draw(in: imgView.bounds)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(CGLineCap.square)
        
        let lengths:[CGFloat] = [2,3]
        
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(1)
        context.setLineCap(CGLineCap(rawValue: 1)!)
        context.setLineDash(phase: 0, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 10))
        context.addLine(to: CGPoint(x: kMobileW, y: 10))
        context.strokePath()
        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    //设置融资进度
    func setValue(_ value : CGFloat){
        jinduValue = value
    }
    //设置融资状态
    func setDealStatus(_ status : String){
        var statusTxt = "融资中"
        switch status {
        case "4":
            statusTxt = "待发布"
        case "6":
            statusTxt = "融资中"
        case "7":
            statusTxt = "融资结束"
        case "8":
            statusTxt = "还款中"
        case "9":
            statusTxt = "已还清"
        default:
            break
        }
        zhuangtai = statusTxt
    }
    //设置标的代金券、加息券显示
    func setVoucher(_ voucher : Int){
        if voucher == 0 {
            daijinquan.isHidden = false
            jiaxiquan.isHidden = false
        } else if voucher == 1 {
            jiaxiquan.isHidden = false
            daijinquan.isHidden = true
            //修改约束让加息券位于进度条正中间
            daijinquanYs.constant = 92.5
        } else if voucher == 2 {
            daijinquan.isHidden = false
            jiaxiquan.isHidden = true
            daijinquanYs.constant = 47.5
        } else {
            jiaxiquan.isHidden = true
            daijinquan.isHidden = true
        }
    }
    //设置利率
    func setRate(dealRate : Float, dealRebate: Float)
    {
        var rateTxt = "\(dealRate)"
        if dealRebate > 0 {
            rateTxt = "\(rateTxt)+\(dealRebate)"
        }
        rate.text = rateTxt
    }
    //特殊标的设置
    func setTeshu(isTure:Bool, teshuTxt:String)
    {
        if isTure {
            teshuTag.isHidden = false
            teshuTag.text = teshuTxt
        } else {
            teshuTag.isHidden = true
        }
    }
    
    fileprivate func addJindu(){
        randView.addSubview(cireView)
        randView.addSubview(jinduText)
        cireView.value = 0
        cireView.maximumValue = 100
        cireView.backgroundColor = UIColor.clear
        cireView.frame = CGRect(x: 0 , y: 0, width: randView.frame.height, height: randView.frame.height)
        dongqilai()
    }
    //进度条动态
    @objc fileprivate func dongqilai() {
        if jinduValue > 0 && jinduValue < 100 {
            if (cireView.value + 2) <= jinduValue {
                cireView.value += 2
            }else {
                cireView.value = jinduValue
                jinduText.text = "\(cireView.value)% \n \(zhuangtai)"
                return
            }
            jinduText.text = "\(cireView.value)% \n \(zhuangtai)"
        } else {
            cireView.value = jinduValue
            jinduText.text = "\(zhuangtai)"
            return
        }
        self.perform(#selector(dongqilai), with: self, afterDelay: 0.05)
    }
}
