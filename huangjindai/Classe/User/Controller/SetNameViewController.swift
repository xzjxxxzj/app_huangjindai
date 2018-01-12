//
//  SetNameViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/16.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate var isSetName : Bool = false
fileprivate var realName : String = ""
fileprivate var idcardNo : String = ""
//高度
fileprivate let textH = CGFloat(40)
//名称底线
fileprivate var nameLine = UIView()

//卡号底线
fileprivate var cardLine = UIView()
//是否加载状态
fileprivate var isLoading : Bool = false
//请求数据模型
fileprivate let model = UserSettingModel()

class SetNameViewController: UIViewController {

    let contenView = UIView(frame : CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW, height: kMobileH - kHeardH - kStatusH + kHotH))
    
    fileprivate lazy var nameText: UITextField = {
        //定义手机输入框
        let nameText = UITextField(frame : CGRect(x: kMobileW/8, y: 20, width: kMobileW*3/4, height: textH))
        //设置为无边框
        nameText.borderStyle = UITextBorderStyle.none
        //添加底线
        nameLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        nameLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        nameText.addSubview(nameLine)
        if isSetName {
            nameText.text = realName
            nameText.isUserInteractionEnabled = false
            let label = UILabel()
            label.text = "认证通过"
            label.textColor = UIColor(r: 102, g: 102, b: 255)
            label.font = UIFont.systemFont(ofSize: 13)
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            nameText.textColor = UIColor(r: 204, g: 204, b: 204)
            //修改图片颜色
            label.contentMode = UIViewContentMode.center
            nameText.rightView = label
            nameText.rightViewMode = UITextFieldViewMode.always
        } else {
            nameText.placeholder = "请输入姓名"
            nameText.clearButtonMode = .whileEditing
            nameText.keyboardType = UIKeyboardType.numbersAndPunctuation
            nameText.becomeFirstResponder()
            nameText.resignFirstResponder()
            nameText.addTarget(self, action: #selector(targetName), for: .allEvents)
        }
        nameText.font = UIFont.systemFont(ofSize: 13)
        nameText.textAlignment = .left
        return nameText
    }()
    
    fileprivate lazy var cardText: UITextField = {
        //定义手机输入框
        let cardText = UITextField(frame : CGRect(x: kMobileW/8, y: textH + 40, width: kMobileW*3/4, height: textH))
        //设置为无边框
        cardText.borderStyle = UITextBorderStyle.none
        //添加底线
        cardLine.frame = CGRect(x: 0, y: textH - 2, width: kMobileW*3/4, height: 1)
        cardLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        cardText.addSubview(cardLine)
        if isSetName {
            cardText.text = PublicLib.subString(string: idcardNo, start: 2, lenth: -3, replay: "*****")
            cardText.textColor = UIColor(r: 204, g: 204, b: 204)
            cardText.isUserInteractionEnabled = false
        } else {
            cardText.placeholder = "请输入身份证号码"
            cardText.clearButtonMode = .whileEditing
            cardText.keyboardType = UIKeyboardType.numbersAndPunctuation
            cardText.becomeFirstResponder()
            cardText.resignFirstResponder()
            cardText.addTarget(self, action: #selector(targetCard), for: .allEvents)
        }
        cardText.font = UIFont.systemFont(ofSize: 13)
        cardText.textAlignment = .left
        return cardText
    }()
    
    fileprivate lazy var setNameBtn: UIButton = {
        let setNameBtn = UIButton(frame : CGRect(x: kMobileW/4, y: textH*2 + 60, width: kMobileW/2, height: textH))
        setNameBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setNameBtn.layer.cornerRadius = textH/2
        setNameBtn.setTitle("验证", for: .normal)
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
        contenView.addSubview(nameText)
        contenView.addSubview(cardText)
        if !isSetName {
            contenView.addSubview(setNameBtn)
        }
        contenView.backgroundColor = UIColor.white
        view.addSubview(contenView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        isSetName = false
        realName = ""
        idcardNo = ""
    }
    
    func setName(name : String,cardNo : String,isSet : Bool)
    {
        realName = name
        idcardNo = cardNo
        isSetName = isSet
    }
}

extension SetNameViewController {
    func setBtn()
    {
        if isSetName {
            self.title = "认证信息"
        } else {
            self.title = "实名认证"
        }
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func setLoginBtnStatus()
    {
        if isLoading {
            return
        }
        let nameString = nameText.text ?? ""
        let cardString = cardText.text ?? ""
        let cardLenth = cardString.count
        if cardLenth == 18 && nameString != "" {
            setNameBtn.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            setNameBtn.addTarget(self, action: #selector(nextView), for: .touchUpInside)
        } else {
            setNameBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            setNameBtn.removeTarget(self, action: #selector(nextView), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func back()
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc fileprivate func targetCard()
    {
        cardLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        nameLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func targetName()
    {
        nameLine.backgroundColor = UIColor(r: 153, g: 204, b: 255)
        cardLine.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setLoginBtnStatus()
    }
    
    @objc fileprivate func nextView() {
        isLoading = true
        setNameBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        setNameBtn.removeTarget(self, action: #selector(nextView), for: .touchUpInside)
        setNameBtn.setTitle("验证中...", for: .normal)
        //添加加载旋转图
        setNameBtn.addSubview(loadingView)
        loadingView.startAnimating()
        //请求数据
        let userData = UserDefaults.standard.dictionary(forKey: "user")!
        let userId = userData["userId"] as! String
        let realName = nameText.text ?? ""
        let idCard = cardText.text ?? ""
        let params : [String : String] = ["userId" : userId, "realName" : realName, "idCardNo" : idCard]
        model.setNameData(params: params, success: { (success) in
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
            let VC = UserSettingViewController()
            self.navigationController!.pushViewController(VC, animated: true)
        } else {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:msg)
        }
        isLoading = false
        loadingView.removeFromSuperview()
        setNameBtn.setTitle("验证", for: .normal)
        setLoginBtnStatus()
    }
}
