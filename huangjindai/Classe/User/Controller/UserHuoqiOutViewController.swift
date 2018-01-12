//
//  UserHuoqiOutViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/12.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

fileprivate var allMoney : Double = 0
fileprivate var fee : Double = 0
fileprivate var minFee : Double = 0

class UserHuoqiOutViewController: UIViewController, UITextFieldDelegate {

    fileprivate lazy var outView : HuoqiOutView = {
        let outView = HuoqiOutView.huoqiOutView()
        outView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        outView.moneyText.addTarget(self, action: #selector(moneyChuange), for: .allEvents)
        outView.moneyText.delegate = self
        return outView
    }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 10, width: 30, height: 30)
        return Loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setBtn()
        automaticallyAdjustsScrollViewInsets = false
        loadData()
        view.addSubview(outView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        isToHome = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //结束编辑时收起键盘，点击空白处
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isToHome = false
    }
    
    fileprivate func setBtn()
    {
        self.title = "活期转出"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var jine = outView.moneyText.text ?? "0"
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
            if Double(jine)! > allMoney {
                outView.moneyText.text = "\(allMoney)"
                return false
            }
            return true
        default:
            return false
        }
    }
}

extension UserHuoqiOutViewController
{
    fileprivate func loadData()
    {
        model.huoqiOutInfo(params: ["userId" : userData["userId"] ?? ""], success: { (result) in
            if result["code"].intValue == 1 {
                let info = result["data"]["info"]
                self.outView.userMoney.text = "账户余额：\(info["userMoney"].doubleValue)"
                self.outView.moneyText.placeholder = "可转出\(info["huoqiMoney"].doubleValue)元"
                allMoney = info["huoqiMoney"].doubleValue
                if allMoney > 0 {
                    self.outView.allOut.backgroundColor = UIColor(r: 99, g: 119, b: 254)
                    self.outView.allOut.addTarget(self, action: #selector(self.allOutMoney), for: .touchUpInside)
                }
                if result["data"]["tishi"].count > 0 {
                    self.outView.setFee(result["data"]["tishi"])
                }
                if result["data"]["fee"].count > 0 {
                    fee = result["data"]["fee"]["fee"].doubleValue
                    minFee = result["data"]["fee"]["minFee"].doubleValue
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

extension UserHuoqiOutViewController
{
    @objc fileprivate func clickBtn()
    {
        self.outView.outBtn.backgroundColor = UIColor(r: 201, g: 201, b: 201)
        self.outView.outBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        self.outView.outBtn.setTitle("提交中...", for: .normal)
        //添加加载旋转图
        self.outView.outBtn.addSubview(loadingView)
        loadingView.startAnimating()
        
        let jine = outView.moneyText.text ?? "0"
        if jine.count > 0 && Double(jine)! > 0 && Double(jine)! <= allMoney {
            model.doHuoqiOut(params: ["userId" : userData["userId"] ?? "","money" : jine], success: { (result) in
                if result["code"].intValue == 1 {
                    let vc = UserHuoqiViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    if result["code"].intValue == 2 {
                        self.notLogin()
                    }else {
                        self.loadingView.removeFromSuperview()
                        self.outView.outBtn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
                        self.outView.outBtn.setTitle("转出", for: .normal)
                        self.outView.outBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
                        AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:result["msg"].stringValue)
                    }
                }
            }) { (error) in
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
            }
        }
    }
    
    @objc fileprivate func moneyChuange()
    {
        let jine = outView.moneyText.text ?? "0"
        if jine.count > 0 && Double(jine)! > 0 {
            self.outView.outBtn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
            self.outView.outBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
            var feeMoney : Double = 0
            if fee > 0 {
                feeMoney = (Double(jine)! * fee > minFee) ? Double(jine)! * fee : minFee
                feeMoney = floor(feeMoney*100) / 100.00
            }
            if feeMoney > 0 {
                self.outView.getFee.text = "本次转出需收取手续费：\(feeMoney)元"
                self.outView.getFee.isHidden = false
            }
        }else {
            self.outView.outBtn.backgroundColor = UIColor(r: 201, g: 201, b: 201)
            self.outView.outBtn.removeTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func allOutMoney()
    {
        outView.moneyText.text = "\(allMoney)"
        moneyChuange()
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
