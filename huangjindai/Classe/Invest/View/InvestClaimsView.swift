//
//  InvestClaimsView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/3.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class InvestClaimsView: UIView {
    
    @IBOutlet weak var claimsView: UIView!
    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var zhekou: UILabel!
    @IBOutlet weak var leftDay: UILabel!
    @IBOutlet weak var dealRate: UILabel!
    @IBOutlet weak var jindu: UIView!
    @IBOutlet weak var jiaxi: UILabel!
    @IBOutlet weak var dealNameWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        Zhekou()
        addJindu()
    }
    fileprivate var jinduValue : CGFloat = 0
    {
        didSet
        {
            dongqilai()
        }
    }
    
    fileprivate var zhuangtai : String = "抢完"
    //进度条文字
    fileprivate lazy var jinduText: UILabel = {
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: jindu.frame.width, height: jindu.frame.height))
        text.numberOfLines = 2
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
}

extension InvestClaimsView {
    
    class func investClaimsView() -> InvestClaimsView {
        return Bundle.main.loadNibNamed("InvestClaimsView", owner: nil, options: nil)?.first as! InvestClaimsView
    }
    //特殊标的标识
    fileprivate func Zhekou() {
        zhekou.isHidden = true
        zhekou.layer.borderWidth = 1
        zhekou.layer.borderColor = UIColor.orange.cgColor
        zhekou.layer.cornerRadius = zhekou.frame.height/2
    }
    
    //设置融资进度
    func setValue(_ value : CGFloat){
        jinduValue = value
    }
    
    //设置标的名称
    func setDealName(_ name : String)
    {
        let stringFrame = PublicLib.countStringFrame(string: name, font: dealName.font)
        if stringFrame.width > 170 {
            dealNameWidth.constant = 170
        }else {
            dealNameWidth.constant = stringFrame.width + 10
        }
        dealName.text = name
    }
    //设置融资状态
    func setDealStatus(_ status : String){
        var statusTxt = "抢完"
        switch status {
        case "1":
            statusTxt = "立即购买"
        case "2":
            statusTxt = "抢完"
        default:
            break
        }
        zhuangtai = statusTxt
    }
    
    //设置利率
    func setRate(rate : Float, Jiaxi: Float)
    {
        dealRate.text = String(rate)
        if Jiaxi > 0 {
            jiaxi.isHidden = false
            let jiaxiTxt = PublicLib.setStringColer(string: "+ \(Jiaxi)%", setString: "%", color: UIColor(r: 204, g: 204, b: 204), size: jiaxi.font)
            jiaxi.attributedText = jiaxiTxt
        }else {
            jiaxi.isHidden = true
        }
    }
    //特殊标的设置
    func setZhekou(Zhekou : Float)
    {
        if Zhekou < 10 {
            zhekou.isHidden = false
            zhekou.text = "本金打\(Zhekou)折"
        } else {
            zhekou.isHidden = true
        }
    }
    
    fileprivate func addJindu(){
        jindu.addSubview(cireView)
        jindu.addSubview(jinduText)
        cireView.value = 0
        cireView.maximumValue = 100
        cireView.backgroundColor = UIColor.clear
        cireView.frame = CGRect(x: 0 , y: 0, width: jindu.frame.height, height: jindu.frame.height)
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
