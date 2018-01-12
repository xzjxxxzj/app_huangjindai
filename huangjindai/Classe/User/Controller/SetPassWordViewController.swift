//
//  SetPassWordViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/16.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
//高度
fileprivate let textH = CGFloat(40)
//旧密码底线
fileprivate var oldLine = UIView()

//新密码底线
fileprivate var newLine = UIView()
//重复密码底线
fileprivate var perLine = UIView()
//是否加载状态
fileprivate var isLoading : Bool = false

fileprivate var showBtn = UIButton()
fileprivate var isShow = false
//请求数据模型
fileprivate let model = UserSettingModel()

class SetPassWordViewController: UIViewController {

    let contenView = UIView(frame : CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW, height: kMobileH - kHeardH - kStatusH + kHotH))
    
    fileprivate lazy var oldText: UITextField = {
        //定义手机输入框
        let oldText = UITextField(frame : CGRect(x: kMobileW/8, y: 20, width: kMobileW*3/4, height: textH))
        //设置为无边框
        oldText.borderStyle = UITextBorderStyle.none
        //添加底线
        oldLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        oldLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        oldText.addSubview(oldLine)
        oldText.placeholder = "请输入原密码"
        oldText.clearButtonMode = .whileEditing
        oldText.keyboardType = UIKeyboardType.numbersAndPunctuation
        oldText.becomeFirstResponder()
        oldText.resignFirstResponder()
        oldText.addTarget(self, action: #selector(targetOld), for: .allEvents)
        oldText.font = UIFont.systemFont(ofSize: 13)
        oldText.textAlignment = .left
        oldText.isSecureTextEntry = true
        return oldText
    }()
    
    fileprivate lazy var newText: UITextField = {
        //定义手机输入框
        let newText = UITextField(frame : CGRect(x: kMobileW/8, y: textH + 30, width: kMobileW*3/4, height: textH))
        //设置为无边框
        newText.borderStyle = UITextBorderStyle.none
        //添加底线
        newLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        newLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        newText.addSubview(newLine)
        
        showBtn.setImage(UIImage(named: "hideIco"), for: .normal)
        showBtn.frame = CGRect(x: 0, y: textH, width: 30, height: 30)
        showBtn.contentMode = UIViewContentMode.center
        showBtn.addTarget(self, action: #selector(targetShow), for: .touchUpInside)
        newText.rightView = showBtn
        newText.rightViewMode = UITextFieldViewMode.always
        
        newText.placeholder = "请输入6-26位登录密码"
        newText.clearButtonMode = .whileEditing
        newText.keyboardType = UIKeyboardType.numbersAndPunctuation
        newText.becomeFirstResponder()
        newText.resignFirstResponder()
        newText.addTarget(self, action: #selector(targetNew), for: .allEvents)
        newText.font = UIFont.systemFont(ofSize: 13)
        newText.textAlignment = .left
        newText.isSecureTextEntry = true
        return newText
    }()
    
    fileprivate lazy var perText: UITextField = {
        //定义手机输入框
        let perText = UITextField(frame : CGRect(x: kMobileW/8, y: textH*2 + 40, width: kMobileW*3/4, height: textH))
        //设置为无边框
        perText.borderStyle = UITextBorderStyle.none
        //添加底线
        perLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        perLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        perText.addSubview(perLine)
        
        perText.placeholder = "再次输入您的登录密码"
        perText.clearButtonMode = .whileEditing
        perText.keyboardType = UIKeyboardType.numbersAndPunctuation
        perText.becomeFirstResponder()
        perText.resignFirstResponder()
        perText.addTarget(self, action: #selector(targetPer), for: .allEvents)
        perText.font = UIFont.systemFont(ofSize: 13)
        perText.textAlignment = .left
        perText.isSecureTextEntry = true
        return perText
    }()
    
    fileprivate lazy var chuangeBtn: UIButton = {
        let setNameBtn = UIButton(frame : CGRect(x: kMobileW/4, y: textH*3 + 50, width: kMobileW/2, height: textH))
        setNameBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setNameBtn.layer.cornerRadius = textH/2
        setNameBtn.setTitle("修改", for: .normal)
        setNameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return setNameBtn
    }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 10, width: textH - 20, height: textH - 20)
        return Loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        //初始化数据
        isLoading = false
        //添加图标
        contenView.addSubview(oldText)
        contenView.addSubview(newText)
        contenView.addSubview(perText)
        contenView.addSubview(chuangeBtn)
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

extension SetPassWordViewController {
    func setBtn()
    {
        self.title = "修改登录密码"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func setLoginBtnStatus()
    {
        if isLoading {
            return
        }
        let oldString = oldText.text ?? ""
        let newString = newText.text ?? ""
        let perString = perText.text ?? ""
        let oldLenth = oldString.count
        let newLenth = newString.count
        if newLenth >= 6 && newLenth <= 26 && oldLenth >= 5 && newString == perString {
            chuangeBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            chuangeBtn.addTarget(self, action: #selector(nextView), for: .touchUpInside)
        } else {
            chuangeBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            chuangeBtn.removeTarget(self, action: #selector(nextView), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func back()
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc fileprivate func targetOld()
    {
        oldLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        newLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        perLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func targetNew()
    {
        newLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        oldLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        perLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func targetPer()
    {
        perLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        oldLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        newLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func targetShow()
    {
        if !isShow {
            showBtn.setImage(UIImage(named: "showIco"), for: .normal)
            newText.isSecureTextEntry = false
            perText.isSecureTextEntry = false
            isShow = true
        } else {
            showBtn.setImage(UIImage(named: "hideIco"), for: .normal)
            newText.isSecureTextEntry = true
            perText.isSecureTextEntry = true
            isShow = false
        }
    }
    
    @objc fileprivate func nextView() {
        isLoading = true
        chuangeBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        chuangeBtn.removeTarget(self, action: #selector(nextView), for: .touchUpInside)
        chuangeBtn.setTitle("提交中...", for: .normal)
        //添加加载旋转图
        chuangeBtn.addSubview(loadingView)
        loadingView.startAnimating()
        //请求数据
        let userData = UserDefaults.standard.dictionary(forKey: "user")!
        let userId = userData["userId"] as! String
        let oldPass = oldText.text ?? ""
        let newPass = newText.text ?? ""
        let params : [String : String] = ["userId" : userId, "pwd" : oldPass, "newPwd" : newPass]
        model.resetPass(params: params, success: { (success) in
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
            let VC = LoginViewController()
            self.navigationController!.pushViewController(VC, animated: true)
        } else {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:msg)
        }
        isLoading = false
        loadingView.removeFromSuperview()
        chuangeBtn.setTitle("修改", for: .normal)
        setLoginBtnStatus()
    }
}
