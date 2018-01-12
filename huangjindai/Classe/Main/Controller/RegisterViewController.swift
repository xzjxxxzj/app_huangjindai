//
//  RegisterViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/27.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let textH = CGFloat(40)
fileprivate var isLoading = false
//开启计时器
fileprivate var timer : Timer? = nil
fileprivate var times : Int = 60
//图片高度
fileprivate let kImageH : CGFloat = kMobileW*360/750
//手机底线及左图标
fileprivate var mobileLine = UIView()
fileprivate var mobileImg = UIImageView()

//手机验证码底线、左图标、验证码按钮
fileprivate var codeLine = UIView()
fileprivate var codeImg = UIImageView()
fileprivate var getCode = UIButton()
//新密码及左图标、右显示密码按钮
fileprivate var passLine = UIView()
fileprivate var passImg = UIImageView()
fileprivate var showBtn = UIButton()
fileprivate var isShow = false
//邀请码及左图标
fileprivate var inviteLine = UIView()
fileprivate var inviteImg = UIImageView()
//同意框是否选中
fileprivate var isAgree = true

//手机验证码请求模型
fileprivate let getCodeModel = GetMobileCode()
//修改密码请求数据
fileprivate let resetModel = RegisterUser()

class RegisterViewController: UIViewController , UITextFieldDelegate {
    
    let contenView = UIView(frame : CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW, height: kMobileH - kHeardH - kStatusH + kHotH))
    
    fileprivate lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "banner1")
        imageView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: kImageH)
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
    
    fileprivate lazy var mobileCodeText: UITextField = {
        //定义手机输入框
        let codeText = UITextField(frame : CGRect(x: kMobileW/8, y: kImageH + textH + 20, width: kMobileW*3/4, height: textH))
        //设置为无边框
        codeText.borderStyle = UITextBorderStyle.none
        //添加底线
        codeLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW/2, height: 1)
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        codeText.addSubview(codeLine)
        //添加左边图片
        codeImg.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //修改图片颜色
        codeImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        codeImg.image = UIImage(named: "ico3")!.withRenderingMode(.alwaysTemplate)
        codeImg.contentMode = UIViewContentMode.center
        codeText.leftView = codeImg
        codeText.leftViewMode = UITextFieldViewMode.always
        //添加右按钮
        getCode.frame = CGRect(x: 0, y: textH, width: kMobileW/4, height: textH - 10 )
        getCode.setTitle("发送验证码", for: .normal)
        getCode.setTitleColor(UIColor.white, for: .normal)
        getCode.layer.cornerRadius = textH/2 - 5
        getCode.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        getCode.contentMode = UIViewContentMode.center
        codeText.rightView = getCode
        codeText.rightViewMode = UITextFieldViewMode.always
        
        codeText.placeholder = "请输入手机验证码"
        codeText.font = UIFont.systemFont(ofSize: 12)
        codeText.textAlignment = .left
        //编辑时出现清除按钮
        codeText.clearButtonMode = .whileEditing
        codeText.keyboardType = UIKeyboardType.numberPad
        codeText.becomeFirstResponder()
        codeText.resignFirstResponder()
        
        codeText.addTarget(self, action: #selector(targetCodeText), for: .allEvents)
        return codeText
    }()
    
    fileprivate lazy var passWordText: UITextField = {
        //定义手机输入框
        let passWordText = UITextField(frame : CGRect(x: kMobileW/8, y: kImageH + 10 + (textH + 10)*2, width: kMobileW*3/4, height: textH))
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
        showBtn.setImage(UIImage(named: "hideIco"), for: .normal)
        showBtn.frame = CGRect(x: 0, y: textH, width: 30, height: 30)
        showBtn.contentMode = UIViewContentMode.center
        showBtn.addTarget(self, action: #selector(targetShow), for: .touchUpInside)
        passWordText.rightView = showBtn
        passWordText.rightViewMode = UITextFieldViewMode.always
        passWordText.placeholder = "请输入6-20位登录密码"
        passWordText.font = UIFont.systemFont(ofSize: 12)
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
    
    fileprivate lazy var inviteText: UITextField = {
        //定义手机输入框
        let inviteText = UITextField(frame : CGRect(x: kMobileW/8, y: kImageH + 10 + (textH + 10)*3, width: kMobileW*3/4, height: textH))
        //设置为无边框
        inviteText.borderStyle = UITextBorderStyle.none
        //添加底线
        inviteLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        inviteLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        inviteText.addSubview(inviteLine)
        //添加左边图片
        inviteImg.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //修改图片颜色
        inviteImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        inviteImg.image = UIImage(named: "ico5")!.withRenderingMode(.alwaysTemplate)
        inviteImg.contentMode = UIViewContentMode.center
        inviteText.leftView = inviteImg
        inviteText.leftViewMode = UITextFieldViewMode.always
        inviteText.placeholder = "邀请码（选填）"
        inviteText.font = UIFont.systemFont(ofSize: 12)
        inviteText.textAlignment = .left
        //编辑时出现清除按钮
        inviteText.clearButtonMode = .whileEditing
        
        inviteText.keyboardType = UIKeyboardType.default
        inviteText.becomeFirstResponder()
        inviteText.resignFirstResponder()
        inviteText.addTarget(self, action: #selector(targetInvite), for: .allEvents)
        return inviteText
    }()
    
    fileprivate lazy var checkAgree: UIButton = {
        let checkAgree = UIButton(frame : CGRect(x: kMobileW/8 + 6 , y: kImageH + 10 + (textH + 10)*4, width: 15, height: 15))
        checkAgree.layer.borderWidth = 1
        checkAgree.layer.cornerRadius = 2
        checkAgree.layer.borderColor = UIColor(r: 204, g: 204, b: 204).cgColor
        checkAgree.setImage(UIImage(named:"checkedIco"), for: .normal)
        checkAgree.addTarget(self, action: #selector(checkAgreeBox), for: .touchUpInside)
        return checkAgree
    }()
    
    fileprivate lazy var checkBtn: UILabel = {
        let agreeLabel = UILabel(frame : CGRect(x: kMobileW/8 + 25 , y: kImageH + 10 + (textH + 10)*4, width: kMobileW*7/8 - 25 , height: 15))
        let string = "阅读并同意"
        agreeLabel.text = string
        agreeLabel.font = UIFont.systemFont(ofSize: 10)
        agreeLabel.textColor = UIColor.black
        agreeLabel.textAlignment = NSTextAlignment.left
        agreeLabel.isUserInteractionEnabled = true
        let fuwuButton = UIButton(frame : CGRect(x: 50 , y: 0, width: 65 , height: 15))
        fuwuButton.setTitle("《服务协议》", for: .normal)
        fuwuButton.setTitleColor(UIColor.blue, for: .normal)
        fuwuButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        fuwuButton.addTarget(self, action: #selector(clickFuwu), for: .touchUpInside)
        agreeLabel.addSubview(fuwuButton)
        let douhao = UILabel(frame : CGRect(x: 115, y: 0, width: 5, height: 15))
        douhao.text = "，"
        douhao.font = UIFont.systemFont(ofSize: 10)
        douhao.textColor = UIColor.black
        agreeLabel.addSubview(douhao)
        let yinsiButton = UIButton(frame : CGRect(x: 120 , y: 0, width: 65 , height: 15))
        yinsiButton.setTitle("《隐私条款》", for: .normal)
        yinsiButton.setTitleColor(UIColor.blue, for: .normal)
        yinsiButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        yinsiButton.addTarget(self, action: #selector(clickYinsi), for: .touchUpInside)
        agreeLabel.addSubview(yinsiButton)
        return agreeLabel
    }()
    
    fileprivate lazy var submitBtn: UIButton = {
        let submitBtn = UIButton(frame : CGRect(x: kMobileW/4, y: kImageH + 10 + (textH + 10)*5, width: kMobileW/2, height: textH))
        submitBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        submitBtn.layer.cornerRadius = textH/2
        submitBtn.setTitle("提交注册", for: .normal)
        submitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return submitBtn
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
        isShow = false
        isAgree = true
        timeStop()
        //设置导航栏
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        automaticallyAdjustsScrollViewInsets = false
        //添加图标
        contenView.addSubview(imageView)
        //手机号码
        contenView.addSubview(mobileText)
        mobileText.delegate = self
        //添加验证码
        contenView.addSubview(mobileCodeText)
        //添加密码
        contenView.addSubview(passWordText)
        //添加邀请码
        contenView.addSubview(inviteText)
        //同意协议选择框和按钮
        contenView.addSubview(checkAgree)
        contenView.addSubview(checkBtn)
        //添加提交框
        contenView.addSubview(submitBtn)
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

extension RegisterViewController {
    
    fileprivate func setBtn()
    {
        self.title = "注册"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(RegisterViewController.back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func clickBtn()
    {
        self.view.endEditing(true)
        isLoading = true
        let passWork = passWordText.text ?? ""
        submitBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        submitBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        submitBtn.setTitle("注册中...", for: .normal)
        //添加加载旋转图
        submitBtn.addSubview(loadingView)
        loadingView.startAnimating()
        //请求数据
        let mobile = mobileText.text ?? ""
        let mobileCode = mobileCodeText.text ?? ""
        let invite = inviteText.text ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        let params = ["mobile" : mobile, "randCode" : mobileCode, "userPwd" : passWork, "inviteCode" : invite,"deviceToken" : deviceToken]
        resetModel.requestData(params, success: { (success) in
            let msg = success["msg"].string ?? ""
            if success["code"].int == 1 {
                self.setRetrun(true, msg, success["data"])
            } else {
                self.setRetrun(false, msg)
            }
        }) { (error) in
            self.setRetrun(false, "网络请求失败！")
        }
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
        
        let mobileCode = mobileCodeText.text ?? ""
        let mobileCodeLenth = mobileCode.count
        
        let passWork = passWordText.text ?? ""
        let passWorkLenth = passWork.count
        
        if mobileLenth == 11 && mobileCodeLenth >= 4 && passWorkLenth >= 6 && passWorkLenth <= 20 && isAgree {
            self.submitBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            self.submitBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        } else {
            self.submitBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            self.submitBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        }
    }
    
    fileprivate func setRetrun(_ type: Bool, _ msg: String, _ data:JSON = [])
    {
        if type {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 0)!, title:msg)
            timeStop()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                let homeViewController = HomeViewController()
                self.navigationController!.pushViewController(homeViewController, animated: true)
                //写入用户数据
                let userId = data["userId"].string ?? ""
                let key2 = data["key2"].string ?? ""
                let mobile = data["mobile"].stringValue
                let userInfo = ["userId" : userId, "key2" : key2, "mobile" : mobile]
                UserDefaults.standard.set(userInfo, forKey: "user")
            })
        } else {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:msg)
            isLoading = false
            loadingView.removeFromSuperview()
            submitBtn.setTitle("提交修改", for: .normal)
            setBtnStatus()
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
            
            let mobile = mobileText.text ?? ""
            let mobileLenth = mobile.count
            getCode.setTitle("发送验证码", for: .normal)
            if mobileLenth == 11 {
                getCode.backgroundColor = UIColor(r: 102, g: 102, b: 255)
                getCode.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
            } else {
                getCode.backgroundColor = UIColor(r: 204, g: 204, b: 204)
                getCode.removeTarget(self, action: #selector(sendCode), for: .touchUpInside)
            }
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


extension RegisterViewController {
    
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
        let params = ["mobile" : mobile, "type" : "1"]
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
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc fileprivate func targetShow()
    {
        if !isShow {
            showBtn.setImage(UIImage(named: "showIco"), for: .normal)
            passWordText.isSecureTextEntry = false
            isShow = true
        } else {
            showBtn.setImage(UIImage(named: "hideIco"), for: .normal)
            passWordText.isSecureTextEntry = true
            isShow = false
        }
    }
    
    @objc fileprivate func targetMobile()
    {
        mobileLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        mobileImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        codeImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        passImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        inviteLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        inviteImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        setBtnStatus()
    }
    
    @objc fileprivate func targetCodeText()
    {
        codeLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        codeImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        passImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        inviteLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        inviteImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        setBtnStatus()
    }
    
    @objc fileprivate func targetPassWord()
    {
        passLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        passImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        codeImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        inviteLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        inviteImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        setBtnStatus()
    }
    
    @objc fileprivate func targetInvite()
    {
        inviteLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        inviteImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        codeLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        codeImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        passLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        passImg.tintColor = UIColor(r: 204, g: 204, b: 204)
    }
    
    @objc fileprivate func checkAgreeBox()
    {
        if isAgree {
            isAgree = false
            checkAgree.setImage(nil, for: .normal)
        } else {
            isAgree = true
            checkAgree.setImage(UIImage(named:"checkedIco"), for: .normal)
        }
        setBtnStatus()
    }
    
    @objc fileprivate func clickFuwu()
    {
        let webView = WKWebViewController()
        webView.setIsCanBack(false)
        webView.urlString = "http://www.baidu.com"
        //隐藏底部
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    @objc fileprivate func clickYinsi()
    {
        let webView = WKWebViewController()
        webView.setIsCanBack(false)
        webView.urlString = "http://www.baidu.com"
        //隐藏底部
        self.navigationController?.pushViewController(webView, animated: true)
    }
}
