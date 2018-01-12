//
//  ResetLockViewController.swif
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
//图片高度
fileprivate let textH = CGFloat(40)
//手机底线
fileprivate var mobileLine = UIView()
//手机左图标
fileprivate var mobileImg = UIImageView()

//用户数据
fileprivate var userInfo : [String: Any] = [:]
//密码底线
fileprivate var passLine = UIView()
//密码左图标
fileprivate var passImg = UIImageView()
//下一个页面
fileprivate var nextViewVc : UIViewController?
//是否加载状态
fileprivate var isLoading : Bool = false
//请求数据模型
fileprivate let model = UserCheckPassWord()

class ResetLockViewController: UIViewController {
    
    let contenView = UIView(frame : CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW, height: kMobileH - kHeardH - kStatusH + kHotH))
    
    
    fileprivate lazy var mobileText: UITextField = {
        //定义手机输入框
        let mobileText = UITextField(frame : CGRect(x: kMobileW/8, y: 20, width: kMobileW*3/4, height: textH))
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
        let userMobile : String = (userInfo["mobile"] as? String)!
        mobileText.text = PublicLib.subString(string: userMobile, start: 2, lenth: -3, replay: "*****")
        mobileText.font = UIFont.systemFont(ofSize: 13)
        mobileText.textAlignment = .left
        mobileText.isUserInteractionEnabled = false
        return mobileText
    }()
    
    fileprivate lazy var passWordText: UITextField = {
        //定义手机输入框
        let passWordText = UITextField(frame : CGRect(x: kMobileW/8, y: textH + 40, width: kMobileW*3/4, height: textH))
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
        passWordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        passWordText.becomeFirstResponder()
        passWordText.resignFirstResponder()
        //设置为密码框
        passWordText.isSecureTextEntry = true
        passWordText.addTarget(self, action: #selector(targetPassWord), for: .allEvents)
        return passWordText
    }()
    
    fileprivate lazy var loginBtn: UIButton = {
        let loginBtn = UIButton(frame : CGRect(x: kMobileW/4, y: textH*2 + 60, width: kMobileW/2, height: textH))
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
        userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        //设置导航栏
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        //初始化数据
        isLoading = false
        //添加图标
        contenView.addSubview(mobileText)
        contenView.addSubview(passWordText)
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
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setNextView(nextViewC : UIViewController) {
        nextViewVc = nextViewC
    }
}


extension ResetLockViewController {
    
    func setBtn()
    {
        self.title = "验证密码"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func setLoginBtnStatus()
    {
        if isLoading {
            return
        }
        let passWord = passWordText.text ?? ""
        let passWordLenth = passWord.count
        if passWordLenth >= 6 && passWordLenth <= 26 {
            loginBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            loginBtn.addTarget(self, action: #selector(nextView), for: .touchUpInside)
        } else {
            loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            loginBtn.removeTarget(self, action: #selector(nextView), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func back()
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc fileprivate func targetPassWord()
    {
        passLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        passImg.tintColor = UIColor(r: 153, g: 153, b: 153)
        mobileLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        mobileImg.tintColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func nextView() {
        isLoading = true
        loginBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        loginBtn.removeTarget(self, action: #selector(nextView), for: .touchUpInside)
        loginBtn.setTitle("验证中...", for: .normal)
        //添加加载旋转图
        loginBtn.addSubview(loadingView)
        loadingView.startAnimating()
        //请求数据
        let userId = userInfo["userId"] as? String
        let passWord = passWordText.text ?? ""
        let params : [String : String] = ["userId" : userId!, "passWord" : passWord]
        model.requestData(params, success: { (success) in
            let msg = success["msg"].string ?? ""
            if success["code"].intValue == 1 {
                self.loginRetrun(true, msg, success["data"])
            } else {
                if success["code"].intValue == 2 {
                    self.notLogin()
                }else {
                     self.loginRetrun(false, msg)
                }
            }
        }) { (error) in
            self.loginRetrun(false, "网络请求失败！")
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
    
    fileprivate func loginRetrun(_ type: Bool, _ msg: String, _ data:JSON = []) {
        if type {
            let VC = nextViewVc!
            self.navigationController!.pushViewController(VC, animated: true)
        } else {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:msg)
        }
        isLoading = false
        loadingView.removeFromSuperview()
        loginBtn.setTitle("下一步", for: .normal)
        setLoginBtnStatus()
    }
}


