//
//  UserWithdrawViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/21.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate var userMoney :String = "0"
fileprivate var isFee : Bool = false
fileprivate var freeMoney : Double = 0
fileprivate var minFee : Double = 0
fileprivate var feeRate : Double = 0

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

class UserWithdrawViewController: UIViewController, UITextFieldDelegate {

    fileprivate let withView = WithdrawView.withdrawView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setBtn()
        withView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        withView.money.delegate = self
        withView.money.addTarget(self, action: #selector(targetMoney), for: .allEvents)
        withView.clickBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        withView.allWith.addTarget(self, action: #selector(allWithMoney), for: .touchUpInside)
        view.addSubview(withView)
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //结束编辑时收起键盘，点击空白处
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isToHome = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isToHome = false
    }
    
    fileprivate func setBtn()
    {
        self.title = "提现"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var jine = withView.money.text ?? "0"
        let ran = jine.components(separatedBy: ".")
        if ran.count > 1 && string == "."{
            return false
        }
        if ran.count == 2 && string != "" {
            if ran[1].count >= 2 {
                return false
            }
        }
        if range.location == 0 && string == "." {
            return false
        }
        if range.location == 1 && jine == "0" && string != "." {
            return false
        }
        switch string {
        case "0","1","2","3","4","5","6","7","8","9","",".":
            jine = jine + string
            if Double(jine)! > Double(userMoney)! {
                withView.money.text = userMoney
                return false
            }
            return true
        default:
            return false
        }
    }
    
}

extension UserWithdrawViewController
{
    fileprivate func loadData()
    {
        model.getWithInfo(params: ["userId" : userData["userId"] ?? ""], success: { (result) in
            if result["code"].intValue == 1 {
                if result["data"]["minMoney"].stringValue != "" {
                    self.withView.minMoney.text = "单笔最低提现金额：\(result["data"]["minMoney"].doubleValue)元"
                }
                if result["data"]["willTime"].stringValue != "" {
                    self.withView.willTime.text = "预计到账时间：\(result["data"]["willTime"].stringValue)"
                }
                if result["data"]["userMoney"].stringValue != "" {
                    let userMoneyString = PublicLib.setStringColer(string: "可提现金额：\(result["data"]["userMoney"].doubleValue)元", setString: "\(result["data"]["userMoney"].doubleValue)", color: UIColor.orange, size: self.withView.userMoney.font)
                    userMoney = result["data"]["userMoney"].stringValue
                    self.withView.userMoney.attributedText = userMoneyString
                }
                if result["data"]["tishi"].arrayValue != [] {
                    self.withView.tishiImage.isHidden = false
                    self.withView.tishiTitle.isHidden = false
                    self.withView.tishi.numberOfLines = 0
                    
                    var tishiString :String = ""
                    for (_, tishiData) : (String, JSON) in result["data"]["tishi"] {
                        tishiString = "\(tishiString)\(tishiData.stringValue)\n"
                    }
                    //设置行间距
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 5
                    let tishiStr : NSMutableAttributedString = NSMutableAttributedString(string: tishiString)
                    tishiStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, tishiString.count))
                    self.withView.tishi.attributedText = tishiStr
                }
                
                if result["data"]["fee"].dictionaryValue != [:] {
                    isFee = true
                    freeMoney = result["data"]["fee"]["freeMoney"].double ?? 0.0
                    minFee = result["data"]["fee"]["minFee"].double ?? 0.0
                    feeRate = result["data"]["fee"]["feeRate"].double ?? 0.0
                } else {
                    self.withView.fee.isHidden = true
                    isFee = false
                }
            } else {
                if result["code"].intValue == 2 {
                    self.notLogin()
                }else {
                     AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:result["msg"].stringValue)
                }
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    fileprivate func notLogin()
    {
        let alertController = UIAlertController(title: "系统提示", message: "您的账号在其它APP登录", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
            let vc = LoginViewController()
            vc.loginToHome()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UserWithdrawViewController
{
    
    @objc fileprivate func targetMoney()
    {
        let money = withView.money.text ?? ""
        var moneyNum : Double = 0
        if money.count >= 1 {
            moneyNum = Double(money)!
            if isFee {
                var fee : Double = 0
                if moneyNum < freeMoney {
                    fee = floor(moneyNum*feeRate*100) / 100.00
                    if fee < minFee {
                        fee = minFee
                    }
                }
                if fee > 0 {
                    let feeMoneyStr = PublicLib.setStringColer(string: "手续费：\(fee)元", setString: "\(fee)", color: UIColor.orange, size: self.withView.fee.font)
                    self.withView.fee.attributedText = feeMoneyStr
                    self.withView.fee.isHidden = false
                } else {
                    self.withView.fee.isHidden = true
                }
            }
        } else {
            self.withView.fee.isHidden = true
        }
        if money.count <= 0 || moneyNum < 3.0 {
            withView.clickBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            withView.clickBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        } else {
            withView.clickBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            withView.clickBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func clickBtn()
    {
        self.view.endEditing(true)
        let money = withView.money.text ?? "0"
        let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        let userId = userInfo["userId"] ?? ""
        let url = NetWorkTools.GETURL(url: "\(kUrl)app/page/userWithDraw", params: ["userId":userId,"money":money])
        let webView = WKWebViewController()
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    @objc fileprivate func allWithMoney()
    {
        withView.money.text = userMoney
        targetMoney()
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
