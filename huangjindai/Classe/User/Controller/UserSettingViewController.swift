//
//  UserSettingViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/11.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
import LocalAuthentication

fileprivate let setListH : CGFloat = 50

fileprivate var bankUrl : String = kUrl + "app/apphtml/sinaBankCard"
fileprivate var payUrl : String = kUrl + "app/apphtml/sinaPwd"
fileprivate let model  = UserSettingModel()
fileprivate let userDate = UserDefaults.standard.dictionary(forKey: "user")!

//用户认证信息
fileprivate var userNameData : String = ""
fileprivate var userCardData : String = ""

class UserSettingViewController: UIViewController {

    fileprivate lazy var contenView :UIView = {
        let contenView = UIView(frame : CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH - kTabbarH + kHotH))
        return contenView
    }()
    
    fileprivate lazy var userInfo : SettingView = {
        let infoView = SettingView.settingView()
        infoView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: setListH)
        infoView.setName.text = "账户信息"
        infoView.setImage.isHidden = true
        infoView.setValue.text = userDate["mobile"] as? String
        infoView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return infoView
    }()
    
    fileprivate lazy var bankInfo : SettingView = {
        let bankView = SettingView.settingView()
        bankView.frame = CGRect(x: 0, y: setListH, width: kMobileW, height: setListH)
        bankView.setName.text = "银行卡管理"
        bankView.setValue.text = "前往新浪"
        bankView.isUserInteractionEnabled = true
        let bankTag = UITapGestureRecognizer()
        bankTag.addTarget(self, action: #selector(bankClick))
        bankView.addGestureRecognizer(bankTag)
        bankView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return bankView
    }()
    
    fileprivate lazy var realName : SettingView = {
        let nameView = SettingView.settingView()
        nameView.frame = CGRect(x: 0, y: setListH*2, width: kMobileW, height: setListH)
        nameView.setName.text = "实名认证"
        nameView.setValue.text = "未认证"
        nameView.setValue.textColor = UIColor(r: 91, g: 91, b: 91)
        nameView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        nameView.isUserInteractionEnabled = true
        let nameTag = UITapGestureRecognizer()
        nameTag.addTarget(self, action: #selector(nameClick))
        nameView.addGestureRecognizer(nameTag)
        return nameView
    }()
    
    fileprivate lazy var payKey : SettingView = {
        let payView = SettingView.settingView()
        payView.frame = CGRect(x: 0, y: setListH*3 + 15, width: kMobileW, height: setListH)
        payView.setName.text = "支付密码"
        payView.setValue.text = "前往新浪"
        payView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        payView.isUserInteractionEnabled = true
        let payTag = UITapGestureRecognizer()
        payTag.addTarget(self, action: #selector(payClick))
        payView.addGestureRecognizer(payTag)
        return payView
    }()
    
    fileprivate lazy var passWord : SettingView = {
        let passView = SettingView.settingView()
        passView.frame = CGRect(x: 0, y: setListH*4 + 15, width: kMobileW, height: setListH)
        passView.setName.text = "登录密码"
        passView.setValue.text = "修改"
        passView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        passView.isUserInteractionEnabled = true
        let passTag = UITapGestureRecognizer()
        passTag.addTarget(self, action: #selector(passClick))
        passView.addGestureRecognizer(passTag)
        return passView
    }()
    
    fileprivate lazy var mobile : SettingView = {
        let mobileView = SettingView.settingView()
        mobileView.frame = CGRect(x: 0, y: setListH*5 + 15, width: kMobileW, height: setListH)
        mobileView.setName.text = "手机绑定"
        mobileView.setValue.text = "已绑定"
        mobileView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        mobileView.isUserInteractionEnabled = true
        let mobileTag = UITapGestureRecognizer()
        mobileTag.addTarget(self, action: #selector(mobileClick))
        mobileView.addGestureRecognizer(mobileTag)
        return mobileView
    }()
    
    fileprivate lazy var shoushiPass : OpenView = {
        let shoushi = OpenView.openView()
        shoushi.frame = CGRect(x: 0, y: setListH*6 + 30, width: kMobileW, height: setListH)
        shoushi.openName.text = "手势密码"
        shoushi.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        let isLock =  UserDefaults.standard.string(forKey: "userLock")
        if isLock == nil {
            shoushi.openValue.isOn = false
        }else {
            shoushi.openValue.isOn = true
        }
        shoushi.openValue.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        shoushi.openValue.addTarget(self, action: #selector(shoushiClick), for: .valueChanged)
        return shoushi
    }()
    
    fileprivate lazy var zhiwenPass : OpenView = {
        let zhiwen = OpenView.openView()
        zhiwen.frame = CGRect(x: 0, y: setListH*7 + 30, width: kMobileW, height: setListH)
        zhiwen.openName.text = "指纹解锁"
        zhiwen.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        let isLock =  UserDefaults.standard.bool(forKey: "userTouch")
        if !isLock {
            zhiwen.openValue.isOn = false
        }else {
            zhiwen.openValue.isOn = true
        }
        zhiwen.openValue.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        zhiwen.openValue.addTarget(self, action: #selector(zhiwenClick), for: .valueChanged)
        return zhiwen
    }()
    
    fileprivate lazy var loginOut : UIButton = {
        let out = UIButton(frame: CGRect(x: 20, y: setListH*8 + 45, width: kMobileW - 40, height: setListH))
        out.setTitle("安全退出", for: .normal)
        out.titleLabel?.textColor = UIColor.white
        out.backgroundColor = UIColor(r: 51, g: 153, b: 0)
        out.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        out.layer.cornerRadius = 3
        out.addTarget(self, action: #selector(loginOutClick), for: .touchUpInside)
        return out
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        setBtn()
        reload()
        view.addSubview(contenView)
        contenView.addSubview(userInfo)
        contenView.addSubview(bankInfo)
        contenView.addSubview(realName)
        contenView.addSubview(payKey)
        contenView.addSubview(passWord)
        contenView.addSubview(mobile)
        contenView.addSubview(shoushiPass)
        if isSupportTouchID() {
            contenView.addSubview(zhiwenPass)
        } else {
            loginOut.frame = CGRect(x: 20, y: setListH*7 + 45, width: kMobileW - 40, height: setListH)
        }
        contenView.addSubview(loginOut)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.title = "账户详情"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func isSupportTouchID() -> Bool {
        let context = LAContext()
        let isOpen = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return isOpen
    }
    
    fileprivate func reload()
    {
        let userId = userDate["userId"] as! String
        model.requestData(params: ["userId" : userId], success: { (result) in
            if result["code"].intValue == 1 {
                self.setBtnValue(result["data"])
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
    
    fileprivate func setBtnValue(_ data : JSON)
    {
        if data["realName"].stringValue != "" {
            realName.setValue.text = "已认证"
            realName.setValue.textColor = UIColor(r: 169, g: 169, b: 169)
            userNameData = data["realName"].stringValue
            userCardData = data["idcardNo"].stringValue
        } else {
            userNameData = ""
            userCardData = ""
        }
    }
}

extension UserSettingViewController {
    @objc fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func payClick() {
        let userId = userDate["userId"] as! String
        let webView = WKWebViewController()
        let url = NetWorkTools.GETURL(url: payUrl, params: ["userId":userId])
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    @objc fileprivate func bankClick() {
        let userId = userDate["userId"] as! String
        let webView = WKWebViewController()
        let url = NetWorkTools.GETURL(url: bankUrl, params: ["userId":userId])
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    @objc fileprivate func nameClick() {
        let nameView = SetNameViewController()
        if userNameData != "" {
            nameView.setName(name: userNameData, cardNo: userCardData,isSet: true)
        }
        self.navigationController?.pushViewController(nameView, animated: true)
    }
    
    @objc fileprivate func passClick() {
        let passView = SetPassWordViewController()
        self.navigationController?.pushViewController(passView, animated: true)
    }
    
    @objc fileprivate func mobileClick() {
        let mobileView = ChuangeMobileViewController()
        self.navigationController?.pushViewController(mobileView, animated: true)
    }
    
    @objc fileprivate func shoushiClick() {
        if !shoushiPass.openValue.isOn {
            UserDefaults.standard.removeObject(forKey: "userLock")
        } else {
            let setLock = LockSettingView()
            self.view.addSubview(setLock)
            setLock.backgroundColor = UIColor.white
            setLock.frame = CGRect(x: 0, y: 30, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        }
    }
    
    @objc fileprivate func zhiwenClick() {
        if !shoushiPass.openValue.isOn {
            UserDefaults.standard.removeObject(forKey: "userTouch")
        } else {
            isShowLock = false
            UserDefaults.standard.set(true, forKey: "userTouch")
        }
    }
    
    @objc fileprivate func loginOutClick() {
        let contenView = LoginViewController()
        contenView.setLastView(toView: UserViewController(),IsbackHome: true)
        self.navigationController!.pushViewController(contenView, animated: true)
    }
}
