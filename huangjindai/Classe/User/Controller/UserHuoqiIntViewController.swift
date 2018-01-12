//
//  UserHuoqiIntViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/12.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//
import UIKit
import SwiftyJSON

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

fileprivate var canInMoney : Double = 0
fileprivate var rate : Double = 0

class UserHuoqiIntViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate lazy var intView : HuoqiInView = {
        let intView = HuoqiInView.huoqiInView()
        intView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        intView.moneyTest.addTarget(self, action: #selector(moneyChuange), for: .allEvents)
        intView.moneyTest.delegate = self
        return intView
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
        view.addSubview(intView)
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
        self.title = "活期转入"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var jine = intView.moneyTest.text ?? "0"
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
            if Double(jine)! > canInMoney {
                intView.moneyTest.text = "\(canInMoney)"
                return false
            }
            return true
        default:
            return false
        }
    }
}

extension UserHuoqiIntViewController
{
    fileprivate func loadData()
    {
        model.huoqiInInfo(params: ["userId" : userData["userId"] ?? ""], success: { (result) in
            if result["code"].intValue == 1 {
                let info = result["data"]["info"]
                let userMoneyText = PublicLib.setStringColer(string: "账户余额(元)：\(info["userMoney"].doubleValue)", setString: "\(info["userMoney"].doubleValue)", color: UIColor.orange, size: self.intView.userMoney.font)
                self.intView.userMoney.attributedText = userMoneyText
                self.intView.leftMoney.text = "个人剩余可投：\(info["leftMoney"].doubleValue)元"
                let canIn : Double = info["leftMoney"].doubleValue > info["userMoney"].doubleValue ? info["userMoney"].doubleValue : info["leftMoney"].doubleValue
                self.intView.moneyTest.placeholder = "余额可转入\(canIn)元"
                canInMoney = canIn
                rate = info["rate"].doubleValue
                if canInMoney > 0 {
                    self.intView.allIn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
                    self.intView.allIn.addTarget(self, action: #selector(self.allInMoney), for: .touchUpInside)
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

extension UserHuoqiIntViewController
{
    @objc fileprivate func clickBtn()
    {
        self.intView.InBtn.backgroundColor = UIColor(r: 201, g: 201, b: 201)
        self.intView.InBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        self.intView.InBtn.setTitle("提交中...", for: .normal)
        //添加加载旋转图
        self.intView.InBtn.addSubview(loadingView)
        loadingView.startAnimating()
        
        let jine = intView.moneyTest.text ?? "0"
        if jine.count > 0 && Double(jine)! > 0 && Double(jine)! <= canInMoney {
            model.doHuoqiIn(params: ["userId" : userData["userId"] ?? "","money" : jine], success: { (result) in
                if result["code"].intValue == 1 {
                    let vc = UserHuoqiViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    if result["code"].intValue == 2 {
                        self.notLogin()
                    }else {
                        self.loadingView.removeFromSuperview()
                        self.intView.InBtn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
                        self.intView.InBtn.setTitle("转入", for: .normal)
                        self.intView.InBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
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
        let jine = intView.moneyTest.text ?? "0"
        if jine.count > 0 && Double(jine)! > 0 {
            self.intView.InBtn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
            self.intView.InBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
            let shouyi : Double = floor(Double(jine)! * rate/36500 * 30*100) / 100.00
            self.intView.shouyi.text = "预计每30日收益(元)：\(shouyi)"
            self.intView.shouyi.isHidden = false
        }else {
            self.intView.InBtn.backgroundColor = UIColor(r: 201, g: 201, b: 201)
            self.intView.InBtn.removeTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func allInMoney()
    {
        intView.moneyTest.text = "\(canInMoney)"
        moneyChuange()
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
