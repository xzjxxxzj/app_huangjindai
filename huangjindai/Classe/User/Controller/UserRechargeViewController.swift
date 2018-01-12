//
//  UserRechargeViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/21.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class UserRechargeViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate let rechargeView = RechargeView.rechargeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setBtn()
        rechargeView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        rechargeView.money.delegate = self
        rechargeView.money.addTarget(self, action: #selector(targetMoney), for: .allEvents)
        rechargeView.rechargeClick.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        view.addSubview(rechargeView)
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
    
    fileprivate func setBtn()
    {
        self.title = "充值"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let jine = rechargeView.money.text ?? "0"
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
            return true
        default:
            return false
        }
    }
    
    @objc fileprivate func back()
    {
         self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func targetMoney()
    {
        let money = rechargeView.money.text ?? ""
        if money.count <= 0 {
            rechargeView.rechargeClick.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            rechargeView.rechargeClick.removeTarget(self, action: #selector(clickRecharge), for: .touchUpInside)
        } else {
            rechargeView.rechargeClick.backgroundColor = UIColor(r: 102, g: 102, b: 255)
            rechargeView.rechargeClick.addTarget(self, action: #selector(clickRecharge), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func clickRecharge()
    {
        self.view.endEditing(true)
        let money = rechargeView.money.text ?? "0"
        let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        let userId = userInfo["userId"] ?? ""
        let url = NetWorkTools.GETURL(url: "\(kUrl)app/page/recharge", params: ["userId":userId,"money":money])
        let webView = WKWebViewController()
        webView.setIsCanBack(false)
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
}
