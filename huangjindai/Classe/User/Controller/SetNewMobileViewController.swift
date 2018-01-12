//
//  SetNewMobileViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/17.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
//高度
fileprivate let textH = CGFloat(40)
//手机底线
fileprivate var mobileLine = UIView()
//验证码底线
fileprivate var codeLine = UIView()
//密码底线
fileprivate var passLine = UIView()
//是否加载状态
fileprivate var isLoading : Bool = false

fileprivate var getCode = UIButton()

//开启计时器
fileprivate var timer : Timer? = nil
fileprivate var times : Int = 60

fileprivate let userDate = UserDefaults.standard.dictionary(forKey: "user")!
//请求数据模型
fileprivate let model = UserSettingModel()
//手机验证码请求模型
fileprivate let getCodeModel = GetMobileCode()

class SetNewMobileViewController: UIViewController,UITextFieldDelegate {

    let contenView = UIView(frame : CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW, height: kMobileH - kHeardH - kStatusH + kHotH))
    
    fileprivate lazy var mobileText: UITextField = {
        //定义手机输入框
        let mobileText = UITextField(frame : CGRect(x: kMobileW/8, y: 30, width: kMobileW*3/4, height: textH))
        //设置为无边框
        mobileText.borderStyle = UITextBorderStyle.none
        //添加底线
        mobileLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileText.addSubview(mobileLine)
        mobileText.placeholder = "请输入新手机号码"
        mobileText.font = UIFont.systemFont(ofSize: 13)
        mobileText.textAlignment = .left
        //添加右按钮
        getCode.frame = CGRect(x: 0, y: textH, width: kMobileW/4, height: textH - 10 )
        getCode.setTitle("发送验证码", for: .normal)
        getCode.setTitleColor(UIColor.white, for: .normal)
        getCode.layer.cornerRadius = textH/2 - 5
        getCode.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        getCode.contentMode = UIViewContentMode.center
        getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileText.addTarget(self, action: #selector(targetMobile), for: .allEvents)
        mobileText.rightView = getCode
        mobileText.rightViewMode = UITextFieldViewMode.always
        
        //编辑时出现清除按钮
        mobileText.clearButtonMode = .whileEditing
        mobileText.keyboardType = UIKeyboardType.numberPad
        mobileText.becomeFirstResponder()
        mobileText.resignFirstResponder()
        return mobileText
    }()
    
    fileprivate lazy var codeText: UITextField = {
        //定义手机输入框
        let codeText = UITextField(frame : CGRect(x: kMobileW/8, y: textH + 40, width: kMobileW*3/4, height: textH))
        //设置为无边框
        codeText.borderStyle = UITextBorderStyle.none
        //添加底线
        codeLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        codeText.addSubview(codeLine)
        codeText.placeholder = "请输入手机验证码"
        codeText.keyboardType = UIKeyboardType.numbersAndPunctuation
        codeText.becomeFirstResponder()
        codeText.resignFirstResponder()
        codeText.addTarget(self, action: #selector(targetCode), for: .allEvents)
        codeText.font = UIFont.systemFont(ofSize: 13)
        codeText.textAlignment = .left
        
        //编辑时出现清除按钮
        codeText.clearButtonMode = .whileEditing
        codeText.keyboardType = UIKeyboardType.numberPad
        codeText.becomeFirstResponder()
        codeText.resignFirstResponder()
        
        return codeText
    }()
    
    fileprivate lazy var passText: UITextField = {
        //定义手机输入框
        let passText = UITextField(frame : CGRect(x: kMobileW/8, y: textH*2 + 50, width: kMobileW*3/4, height: textH))
        //设置为无边框
        passText.borderStyle = UITextBorderStyle.none
        //添加底线
        passLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        passText.addSubview(passLine)
        passText.placeholder = "请输入登录密码"
        passText.keyboardType = UIKeyboardType.numbersAndPunctuation
        passText.becomeFirstResponder()
        passText.resignFirstResponder()
        passText.addTarget(self, action: #selector(targetCode), for: .allEvents)
        passText.font = UIFont.systemFont(ofSize: 13)
        passText.textAlignment = .left
        passText.addTarget(self, action: #selector(targetPass), for: .allEvents)
        passText.isSecureTextEntry = true
        //编辑时出现清除按钮
        passText.clearButtonMode = .whileEditing
        passText.keyboardType = UIKeyboardType.numbersAndPunctuation
        passText.becomeFirstResponder()
        passText.resignFirstResponder()
        
        return passText
    }()
    
    fileprivate lazy var loginBtn: UIButton = {
        let loginBtn = UIButton(frame : CGRect(x: kMobileW/4, y: textH*3 + 60, width: kMobileW/2, height: textH))
        loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        loginBtn.layer.cornerRadius = textH/2
        loginBtn.setTitle("下一步", for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return loginBtn
    }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 10, width: textH - 20, height: textH - 20)
        return Loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化数据
        isLoading = false
        timeStop()
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        //添加图标
        contenView.addSubview(mobileText)
        mobileText.delegate = self
        contenView.addSubview(codeText)
        contenView.addSubview(passText)
        contenView.addSubview(loginBtn)
        contenView.backgroundColor = UIColor.white
        view.addSubview(contenView)
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

}

extension SetNewMobileViewController {
    
    fileprivate func setBtn()
    {
        self.title = "验证手机号码"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func clickBtn()
    {
        isLoading = true
        loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        loginBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        loginBtn.setTitle("验证中...", for: .normal)
        //添加加载旋转图
        loginBtn.addSubview(loadingView)
        loadingView.startAnimating()
        //请求数据
        let userId = (userDate["userId"] as? String)!
        let newMobile = mobileText.text ?? ""
        let passWord = passText.text ?? ""
        let codeValue = codeText.text ?? ""
        let params = ["userId" : userId, "newMobile": newMobile, "mobileCode" : codeValue,"passWord" : passWord]
        model.setNewMobile(params: params, success: { (success) in
            let msg = success["msg"].string ?? ""
            if success["code"].intValue == 1 {
                self.setRetrun(true, msg, success["data"])
            } else {
                if success["code"].intValue == 2 {
                    self.notLogin()
                }else {
                    self.setRetrun(false, msg)
                }
            }
        }) { (error) in
            self.setRetrun(false, "网络请求失败！")
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
    
    fileprivate func setBtnStatus()
    {
        if isLoading {
            return
        }
        let mobile = mobileText.text ?? ""
        let mobileLenth = mobile.count
        if mobileLenth == 11 && timer == nil {
            getCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            getCode.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        } else {
            getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            getCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
        }
        
        let code = codeText.text ?? ""
        let codeLenth = code.count
        
        let pass = passText.text ?? ""
        let passLenth = pass.count
        
        if codeLenth >= 4 && passLenth > 4 && mobileLenth == 11 {
            self.loginBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            self.loginBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        } else {
            self.loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            self.loginBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        }
    }
    
    fileprivate func setRetrun(_ type: Bool, _ msg: String, _ data:JSON = [])
    {
        if type {
            timeStop()
            let settingView = UserSettingViewController()
            self.navigationController?.pushViewController(settingView, animated: true)
        } else {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:msg)
        }
        isLoading = false
        loadingView.removeFromSuperview()
        loginBtn.setTitle("下一步", for: .normal)
        setBtnStatus()
    }
    
    /**
     *  创建定时器
     */
    fileprivate func creatTimer() -> Void {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(timeAction), userInfo: nil, repeats: true)
    }
    
    /**
     *  定时器暂停
     */
    fileprivate func timeStop() -> Void {
        if (timer != nil) {
            timer?.fireDate = Date.distantFuture
            timer = nil
            times = 60
            getCode.setTitle("发送验证码", for: .normal)
            getCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            getCode.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let mobile = mobileText.text ?? ""
        if mobile.count > 10 && string != "" {
            return false
        }
        switch string {
        case "0","1","2","3","4","5","6","7","8","9","":
            return true
        default:
            return false
        }
    }
}


extension SetNewMobileViewController {
    
    @objc fileprivate func timeAction() {
        getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        getCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
        getCode.setTitle("\(times)s", for: .normal)
        times = times - 1
        if times < 0 {
            timeStop()
        } else if times < 0 {
            timeStop()
        }
    }
    
    @objc fileprivate func sendCode() {
        getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        getCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
        creatTimer()
        //发送请求
        let mobile = mobileText.text ?? ""
        let params = ["mobile" : mobile, "type" : "5"]
        getCodeModel.requestData(params, success: { (result) in
            if result["code"].int == 1 {
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 0)!, title:"发送成功！")
            } else {
                self.timeStop()
                let msg = result["msg"].string ?? ""
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title : msg)
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
            getCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            getCode.addTarget(self, action: #selector(self.sendCode), for: .touchUpInside)
        }
    }
    
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func targetCode()
    {
        codeLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setBtnStatus()
    }
    
    @objc fileprivate func targetMobile()
    {
        mobileLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setBtnStatus()
    }
    
    @objc fileprivate func targetPass()
    {
        passLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setBtnStatus()
    }
}
