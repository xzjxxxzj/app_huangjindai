//
//  UserInviteViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/13.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")

class UserInviteViewController: UIViewController,UITextFieldDelegate {

    fileprivate lazy var setView : SetInviteView = {
        let setView = SetInviteView.setInviteView()
        setView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        setView.inviteCode.delegate = self
        setView.inviteCode.addTarget(self, action: #selector(codeChange), for: .allEvents)
        return setView
    }()
    
    fileprivate lazy var inviteView : InviteView = {
        let inviteView = InviteView.inviteView()
        inviteView.copyBtn.addTarget(self, action: #selector(copyClick), for: .touchUpInside)
        inviteView.detailBtn.addTarget(self, action: #selector(detailClick), for: .touchUpInside)
        inviteView.shareBtn.addTarget(self, action: #selector(shareClick), for: .touchUpInside)
        inviteView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        return inviteView
    }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 5, width: 30, height: 30)
        return Loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        setBtn()
        loadData()
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
        self.title = "我的邀请"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func loadData()
    {
        model.inviteInfo(params: ["userId" : userData?["userId"] ?? ""], success: { (result) in
            if result["code"].intValue == 1 {
                let inviteInfo = result["data"]
                if inviteInfo["inviteCode"].stringValue == "" {
                    self.view.addSubview(self.setView)
                }else {
                    self.inviteDataSet(inviteInfo)
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

//设置邀请码处理
extension UserInviteViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        for str in string {
            let strS = "\(str)"
            //转ascii码
            let code = UnicodeScalar(strS)?.value
            //判断是不是数字和字母
            if code! < 48 || (code! > 57 && code! < 65) || code! > 122 {
                return false
            }
        }
        return true
    }
    
    @objc fileprivate func codeChange()
    {
        let code = setView.inviteCode.text ?? ""
        if code.count >= 6 && code.count <= 20 {
            setView.setBtn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
            setView.setBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        }else {
            setView.setBtn.backgroundColor = UIColor(r: 201, g: 201, b: 201)
            setView.setBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func clickBtn()
    {
        self.view.endEditing(true)
        setView.setBtn.backgroundColor = UIColor(r: 201, g: 201, b: 201)
        setView.setBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        setView.setBtn.setTitle("提交中...", for: .normal)
        //添加加载旋转图
        setView.setBtn.addSubview(loadingView)
        loadingView.startAnimating()
        
        let code = setView.inviteCode.text ?? ""
        model.doSetInviteCode(params: ["userId" : userData?["userId"] ?? "","code" : code], success: { (result) in
            if result["code"].intValue == 1 {
                self.setView.removeFromSuperview()
                self.inviteDataSet(result["data"])
            }else {
                if result["code"].intValue == 2 {
                    self.notLogin()
                }else {
                    self.loadingView.removeFromSuperview()
                    self.setView.setBtn.backgroundColor = UIColor(r: 99, g: 119, b: 254)
                    self.setView.setBtn.setTitle("生成邀请码", for: .normal)
                    self.setView.setBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
                    AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:result["msg"].stringValue)
                }
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
}
//邀请界面
extension UserInviteViewController {
    
    fileprivate func inviteDataSet(_ inviteData : JSON)
    {
        self.inviteView.setLink(inviteData["link"].stringValue)
        self.inviteView.code.setTitle(inviteData["inviteCode"].stringValue, for: .normal)
        self.view.addSubview(self.inviteView)
    }
    
    @objc fileprivate func detailClick()
    {
        let vc = UserInviteDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func copyClick()
    {
        let urlString = self.inviteView.link.text ?? ""
        if urlString.count > 0 {
            UIPasteboard.general.string = urlString
            
            let alertController = UIAlertController(title: "复制成功", message: "链接已经复制到剪切板！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的",style: .cancel, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func shareClick()
    {
        let text : String = "邀请分享"
        let image : UIImage = UIImage(named: "logo")!
        let url : NSURL = NSURL(string: inviteView.link.text!)!
        let activityItems = [text,image,url] as [Any]
        let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityType.print,UIActivityType.copyToPasteboard,UIActivityType.assignToContact,UIActivityType.saveToCameraRoll]
        self.present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = { (activity: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed {
                print("分享成功！")
            }
        }
    }
}
