//
//  LoginViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
//图片高度
fileprivate let kImageH : CGFloat = kMobileW*360/750

fileprivate let textH = CGFloat(40)
//手机底线
fileprivate var mobileLine = UIView()
//手机左图标
fileprivate var mobileImg = UIImageView()

//密码底线
fileprivate var passLine = UIView()
//密码左图标
fileprivate var passImg = UIImageView()

//登陆类型
fileprivate var isPassLogin = true

//开启计时器
fileprivate var timer : Timer? = nil
fileprivate var times : Int = 60

//是否加载状态
fileprivate var isLoading : Bool = false

//是否返回首页
fileprivate var isbackHome : Bool = false
//登录后跳转页面
fileprivate var loginToView : UIViewController?
//是否设置了跳转
fileprivate var isSetView : Bool = false
//请求数据模型
fileprivate let model = LoginModel()
//手机验证码请求模型
fileprivate let getCodeModel = GetMobileCode()

class LoginViewController: UIViewController, UITextFieldDelegate {

    let contenView = UIView(frame : CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW, height: kMobileH - kHeardH - kStatusH + kHotH))
    
    fileprivate lazy var loginImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "banner1")
        imageView.frame = CGRect(x: 0, y: 0 , width: kMobileW, height: kImageH)
        return imageView
    }()
    
    fileprivate lazy var mobileText: UITextField = {
        //定义手机输入框
        let mobileText = UITextField(frame : CGRect(x: kMobileW/8, y: kImageH + 10, width: kMobileW*3/4, height: textH))
        //设置为无边框
        mobileText.borderStyle = UITextBorderStyle.none
        //添加底线
        mobileLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileText.addSubview(mobileLine)
        //添加左边图片
        mobileImg.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //修改图片颜色
        mobileImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        mobileImg.image = UIImage(named: "ico1")!.withRenderingMode(.alwaysTemplate)
        mobileImg.contentMode = UIViewContentMode.center
        mobileText.leftView = mobileImg
        mobileText.leftViewMode = UITextFieldViewMode.always
        mobileText.placeholder = "请输入您的手机号码"
        mobileText.font = UIFont.systemFont(ofSize: 13)
        mobileText.textAlignment = .left
        //编辑时出现清除按钮
        mobileText.clearButtonMode = .whileEditing
        mobileText.keyboardType = UIKeyboardType.numberPad
        mobileText.becomeFirstResponder()
        mobileText.resignFirstResponder()
        mobileText.addTarget(self, action: #selector(targetMobile), for: .allEvents)
        return mobileText
    }()
    
    fileprivate lazy var passWordText: UITextField = {
        //定义手机输入框
        let passWordText = UITextField(frame : CGRect(x: kMobileW/8, y: kImageH + textH + 20, width: kMobileW*3/4, height: textH))
        //设置为无边框
        passWordText.borderStyle = UITextBorderStyle.none
        //添加底线
        passLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        passWordText.addSubview(passLine)
        //添加左边图片
        passImg.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //修改图片颜色
        passImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        passImg.image = UIImage(named: "ico4")!.withRenderingMode(.alwaysTemplate)
        passImg.contentMode = UIViewContentMode.center
        passWordText.leftView = passImg
        passWordText.leftViewMode = UITextFieldViewMode.always
        passWordText.placeholder = "请输入您的登录密码"
        passWordText.font = UIFont.systemFont(ofSize: 13)
        passWordText.textAlignment = .left
        //编辑时出现清除按钮
        passWordText.clearButtonMode = .whileEditing
        passWordText.keyboardType = UIKeyboardType.default
        passWordText.becomeFirstResponder()
        passWordText.resignFirstResponder()
        //设置为密码框
        passWordText.isSecureTextEntry = true
        passWordText.addTarget(self, action: #selector(targetPassWord), for: .allEvents)
        return passWordText
    }()
    
    fileprivate lazy var loginBtn: UIButton = {
        let loginBtn = UIButton(frame : CGRect(x: kMobileW/4, y: kImageH + textH*2 + 40, width: kMobileW/2, height: textH))
        loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        loginBtn.layer.cornerRadius = textH/2
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return loginBtn
    }()
    
    fileprivate lazy var losePassWord : UIButton = {
        let loseButton = UIButton(frame : CGRect(x: kMobileW/4, y: kImageH + textH*3 + 70, width: 50, height: 15))
        loseButton.setTitle("忘记密码", for: .normal)
        loseButton.setTitleColor(UIColor.blue, for: .normal)
        loseButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        loseButton.addTarget(self, action: #selector(losePass), for: .touchUpInside)
        return loseButton
    }()
    
    fileprivate lazy var register : UIButton = {
        let registerButton = UIButton(frame : CGRect(x: kMobileW*3/4 - 50, y: kImageH + textH*3 + 70, width: 50, height: 15))
        registerButton.setTitle("注册会员", for: .normal)
        registerButton.setTitleColor(UIColor.blue, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        registerButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        return registerButton
    }()
    
    fileprivate lazy var passWordLogin : UIButton = {
        let passLogin = UIButton(frame : CGRect(x: 10, y: contenView.frame.height - 40 - kHotH, width: (kMobileW-30)/2, height: 30))
        passLogin.setTitle("密码登录", for: .normal)
        passLogin.setTitleColor(UIColor(r: 102, g: 255, b: 102), for: .normal)
        passLogin.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        passLogin.addTarget(self, action: #selector(setPassLogin), for: .touchUpInside)
        return passLogin
    }()
    
    fileprivate lazy var codeLogin : UIButton = {
        let CodeLogin = UIButton(frame : CGRect(x: kMobileW/2, y: contenView.frame.height - 40 - kHotH, width: (kMobileW-30)/2, height: 30))
        CodeLogin.setTitle("验证码登录", for: .normal)
        CodeLogin.setTitleColor(UIColor(r: 204, g: 204, b: 204), for: .normal)
        CodeLogin.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        CodeLogin.addTarget(self, action: #selector(setCodeLogin), for: .touchUpInside)
        return CodeLogin
    }()
    
    fileprivate lazy var mobileCode : UIButton = {
        mobileText.width = kMobileW/2
        mobileLine.width = kMobileW/2
        passWordText.placeholder = "请输入您的验证码"
        passWordText.isSecureTextEntry = false
        let getCode = UIButton(frame : CGRect(x: kMobileW*5/8, y: kImageH + 10, width: kMobileW/4, height: textH - 10 ))
        getCode.setTitle("发送验证码", for: .normal)
        getCode.setTitleColor(UIColor.white, for: .normal)
        getCode.layer.cornerRadius = textH/2 - 5
        getCode.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        return getCode
    }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 10, width: textH - 20, height: textH - 20)
        return Loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        //设置导航栏
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        //初始化数据
        timeStop()
        isPassLogin = true
        isLoading = false
        if !isSetView {
            isbackHome = true
        }
        //清除用户登录数据
        UserDefaults.standard.removeObject(forKey: "user")
        //添加图标
        contenView.addSubview(loginImageView)
        contenView.addSubview(mobileText)
        contenView.addSubview(passWordText)
        mobileText.delegate = self
        contenView.addSubview(loginBtn)
        contenView.addSubview(losePassWord)
        contenView.addSubview(register)
        let reightLine = UIView(frame: CGRect(x: kMobileW/2, y: kImageH + textH*3 + 70, width: 1, height: 15))
        reightLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        contenView.addSubview(reightLine)
        contenView.addSubview(passWordLogin)
        contenView.addSubview(codeLogin)
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
        self.tabBarController?.tabBar.isHidden = true
    }
    
}


extension LoginViewController {
    
    public func setLastView(toView : UIViewController,IsbackHome : Bool = false)
    {
        isbackHome = IsbackHome
        loginToView = toView
        isSetView = true
    }
    
    public func loginToHome()
    {
        isSetView = false
    }
    
    func setBtn()
    {
        self.title = "登录"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(LoginViewController.back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func setLoginBtnStatus()
    {
        if isLoading {
            return
        }
        let passWord = passWordText.text ?? ""
        let passWordLenth = passWord.count
        let mobile = mobileText.text ?? ""
        let mobileLenth = mobile.count
        var minLenth : Int = 6
        if !isPassLogin {
            minLenth = 4
        }
        if passWordLenth >= minLenth && passWordLenth <= 20 && mobileLenth == 11 {
            loginBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        } else {
            loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            loginBtn.removeTarget(self, action: #selector(login), for: .touchUpInside)
        }
        
        if mobileLenth == 11 && !isPassLogin && timer == nil {
            mobileCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            mobileCode.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        } else if !isPassLogin {
            mobileCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            mobileCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func back()
    {
        if isbackHome {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            self.navigationController?.present(vc , animated: true)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func targetMobile()
    {
        mobileLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        mobileImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        passImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func targetPassWord()
    {
        passLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        passImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func login() {
        self.view.endEditing(true)
        isLoading = true
        loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        loginBtn.removeTarget(self, action: #selector(login), for: .touchUpInside)
        loginBtn.setTitle("登录中...", for: .normal)
        //添加加载旋转图
        loginBtn.addSubview(loadingView)
        loadingView.startAnimating()
        //请求数据
        let loginType = isPassLogin ? "1" : "2"
        let mobile = mobileText.text ?? ""
        let passWord = passWordText.text ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        let params = ["mobile" : mobile, "userPwd" : passWord, "loginType" : loginType, "deviceToken" : deviceToken]
        model.requestData(params, success: { (success) in
            let msg = success["msg"].string ?? ""
            if success["code"].int == 1 {
                self.loginRetrun(true, msg, success["data"])
            } else {
                self.loginRetrun(false, msg)
            }
        }) { (error) in
            self.loginRetrun(false, "网络请求失败！")
        }
    }
    
    @objc fileprivate func setPassLogin()
    {
        isPassLogin = true
        mobileCode.removeFromSuperview()
        mobileText.width = kMobileW*3/4
        mobileLine.width = kMobileW*3/4
        passImg.image = UIImage(named: "ico4")!.withRenderingMode(.alwaysTemplate)
        passWordText.text = ""
        passWordText.placeholder = "请输入您的登录密码"
        passWordText.isSecureTextEntry = true
        passWordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        passWordLogin.setTitleColor(UIColor(r: 102, g: 255, b: 102), for: .normal)
        codeLogin.setTitleColor(UIColor(r: 204, g: 204, b: 204), for: .normal)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func setCodeLogin()
    {
        if isPassLogin {
            isPassLogin = false
            contenView.addSubview(mobileCode)
            mobileText.width = kMobileW/2
            mobileLine.width = kMobileW/2
            passImg.image = UIImage(named: "ico3")!.withRenderingMode(.alwaysTemplate)
            passWordText.text = ""
            passWordText.placeholder = "请输入您的验证码"
            passWordText.isSecureTextEntry = false
            passWordText.keyboardType = UIKeyboardType.numberPad
            codeLogin.setTitleColor(UIColor(r: 102, g: 255, b: 102), for: .normal)
            passWordLogin.setTitleColor(UIColor(r: 204, g: 204, b: 204), for: .normal)
            let mobile = mobileText.text ?? ""
            let mobileLenth = mobile.count
            if mobileLenth == 11 && timer == nil {
                mobileCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
                mobileCode.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
            } else {
                mobileCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
                mobileCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
            }
            if timer == nil {
                mobileCode.setTitle("发送验证码", for: .normal)
            }
            setLoginBtnStatus()
        }
    }
    
    @objc fileprivate func sendCode() {
        mobileCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
        creatTimer()
        //发送请求
        let mobile = mobileText.text ?? ""
        let params = ["mobile" : mobile, "type" : "7"]
        getCodeModel.requestData(params, success: { (result) in
            if result["code"].int == 1 {
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 0)!, title:"发送成功！")
            } else {
                self.timeStop()
                let msg = result["msg"].string ?? ""
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title : msg)
                self.mobileCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
                self.mobileCode.addTarget(self, action: #selector(self.sendCode), for: .touchUpInside)
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
            self.mobileCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            self.mobileCode.addTarget(self, action: #selector(self.sendCode), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func losePass() {
        let losePassViewController = LosePassViewController()
        self.navigationController!.pushViewController(losePassViewController, animated: true)
    }
    
    @objc fileprivate func registerUser() {
        let registerViewController = RegisterViewController()
        self.navigationController!.pushViewController(registerViewController, animated: true)
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
        }
    }
    
    @objc fileprivate func timeAction() {
        mobileCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
        mobileCode.setTitle("\(times)s", for: .normal)
        times = times - 1
        if times < 0 && !isPassLogin{
            let mobile = mobileText.text ?? ""
            let mobileLenth = mobile.count
            mobileCode.setTitle("发送验证码", for: .normal)
            if mobileLenth == 11 {
                mobileCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
                mobileCode.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
            }
            timeStop()
        } else if times < 0 {
            timeStop()
        }
    }
}

//登陆后返回数据代理

extension LoginViewController {
    fileprivate func loginRetrun(_ type: Bool, _ msg: String, _ data:JSON = []) {
        if type {
            //写入用户数据
            let userId = data["userId"].string ?? ""
            let key2 = data["key2"].string ?? ""
            let mobile = data["mobile"].stringValue
            let userInfo = ["userId" : userId, "key2" : key2, "mobile" : mobile]
            UserDefaults.standard.set(userInfo, forKey: "user")
            if !isSetView {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                self.navigationController?.present(vc , animated: true)
            }else {
                let vc = loginToView!
                self.navigationController!.pushViewController(vc, animated: true)
            }
        } else {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:msg)
        }
        isLoading = false
        loadingView.removeFromSuperview()
        loginBtn.setTitle("登录", for: .normal)
        setLoginBtnStatus()
    }
}
