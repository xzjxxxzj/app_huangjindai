//
//  UserViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/9.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let btnTitles: [(String,String)] = [("优惠券","coupon"), ("回款查询" , "repay"), ("投资记录" , "prolist"), ("债权转让" , "prolist"), ("交易记录" , "recordIco"), ("活期存钱罐" , "current") , ("我的邀请" , "inviteIco")]
fileprivate var titlesVc : [String:UIViewController] = [:]
fileprivate var userData:[String:Any] = [:]

fileprivate let contenH = kMobileH - kStatusH - kHeardH - kTabbarH + kHotH
fileprivate let heardH = kStatusH + kHeardH
fileprivate let financeH : CGFloat = 65
fileprivate let zichanH : CGFloat = 120

fileprivate var isReload = false

fileprivate var isRealName = false

class UserViewController: UIViewController {
    
    fileprivate lazy var contentView : UIScrollView = {
        let contentionView = UIScrollView(frame: CGRect(x: 0, y:0, width: kMobileW, height: kMobileH - kTabbarH + kHotH))
        contentionView.showsVerticalScrollIndicator = false
        contentionView.isScrollEnabled = true
        contentionView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        contentionView.delegate = self
        contentionView.alwaysBounceVertical = true
        contentionView.contentSize = CGSize(width: kMobileW, height: kMobileH - kTabbarH + kHotH )
        return contentionView
    }()
    
    fileprivate lazy var listView : UIView = {
        let listView = UIView(frame : CGRect(x: 0, y: heardH + zichanH, width: kMobileW, height: kMobileH - heardH - zichanH - kTabbarH))
        listView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return listView
    }()
    
    fileprivate lazy var financeView : FinanceView = {
        let finance = FinanceView.financeView()
        finance.frame = CGRect(x: 0, y: 0 , width: kMobileW, height: financeH)
        finance.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        finance.tixian.addTarget(self, action: #selector(goTixian), for: .touchUpInside)
        finance.chongzhi.addTarget(self, action: #selector(goChongzhi), for: .touchUpInside)
        return finance
    }()
    
    fileprivate lazy var zichanView : ZichanView = {
        let zichan = ZichanView.zichanView()
        zichan.frame = CGRect(x: 0, y: heardH, width: kMobileW, height: zichanH)
        zichan.backgroundColor = UIColor.clear
        return zichan
    }()
    
    //设置拉伸背景
    fileprivate lazy var lashenView : UIImageView = {
        let lashen = UIImageView(frame: CGRect(x: 0, y: 0, width: kMobileW, height: kStatusH + kHeardH + zichanH))
        lashen.image = UIImage(named: "back")
        return lashen
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        if userData.isEmpty {
            login()
        }else {
            titlesVc = ["优惠券":UserCardViewController(),"回款查询":UserRepayInfoViewController(),"投资记录":UserInvestInfoViewController(),"债权转让":UserClaimsListViewController(),"交易记录":UserRecordViewController(),"我的邀请" : UserInviteViewController()]
            self.automaticallyAdjustsScrollViewInsets = false
            //设置IOS11 顶部不为-64
            if #available(iOS 11.0, *) {
                contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
            
            heardBnt()
            view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
            contentView.addSubview(lashenView)
            lashenView.addSubview(zichanView)
            contentView.addSubview(listView)
            listView.addSubview(financeView)
            view.addSubview(contentView)
            setBtnList()
            loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.dictionary(forKey: "user") != nil {
            openLock()
        }
        isToHome = true
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isToHome = false
        self.navigationController?.navigationBar.setBackgroundImage(nil,for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func openLock()
    {
        let isLock =  UserDefaults.standard.string(forKey: "userLock")
        let isTouch = UserDefaults.standard.bool(forKey: "userTouch")
        if (isLock != nil || isTouch == true) && isShowLock {
            let lockVc = LockViewController()
            self.navigationController?.pushViewController(lockVc, animated: true)
        }
    }
    
    fileprivate func login()
    {
        let contenView = LoginViewController()
        contenView.setBtn()
        contenView.setLastView(toView: UserViewController(),IsbackHome: true)
        self.navigationController!.pushViewController(contenView, animated: true)
    }
    
    fileprivate func heardBnt() {
        //设置头部左侧LOGO
        let userImage : UIBarButtonItem = UIBarButtonItem(imageName: "accountImg", target: self, action: #selector(userSetting))
        let mobileLabel : UILabel = UILabel()
        mobileLabel.text = userData["mobile"] as? String
        mobileLabel.font = UIFont.systemFont(ofSize: 15)
        mobileLabel.textColor = UIColor(r: 102, g: 102, b: 102)
        mobileLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 15)
        let userMobile : UIBarButtonItem = UIBarButtonItem(customView: mobileLabel)
        self.navigationItem.leftBarButtonItems = [userImage,userMobile]
        //设置头部右侧
        let sizi = CGSize(width: 40, height: 44)
        let scanBtn = UIBarButtonItem(imageName: "settingIco", target: self, action: #selector(userSetting), highImageName: "setting", size: sizi)
        
        self.navigationItem.rightBarButtonItems = [scanBtn]
    }
    
    fileprivate func setBtnList()
    {
        let btnStartH : CGFloat = financeH
        let btnH : CGFloat = 52
        var index: CGFloat = 0
        var Y = btnStartH
        for (name,image) in btnTitles {
            let btnView = BtnView.btnView()
            btnView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
            Y = btnStartH + (btnH)*index
            btnView.frame = CGRect(x: 0, y: Y , width: kMobileW, height: btnH)
            btnView.tag = Int(index)
            //开启交互
            btnView.isUserInteractionEnabled = true
            let btnTap = UITapGestureRecognizer(target: self, action: #selector(btnClick(_:)))
            btnView.addGestureRecognizer(btnTap)
            
            index += 1
            listView.addSubview(btnView)
            btnView.btnImage.image = UIImage(named: image)
            btnView.btnName.text = name
        }
        contentView.contentSize = CGSize(width: kMobileW, height: Y + zichanH + btnH + heardH + kHotH*2)
        var listFrame = listView.frame
        if listFrame.height < (Y + btnH) {
            listFrame.size.height = Y + btnH
            listView.frame = listFrame
        }
    }
    
    fileprivate func loadData() {
        let model = UserAccountModel()
        model.requestData(params: ["userId" : userData["userId"] as! String], success: { (result) in
            if result["code"].intValue == 1 {
                self.zichanView.keyong.text = result["data"]["finance"]["available"].stringValue
                self.zichanView.benjin.text = result["data"]["finance"]["notPay"].stringValue
                self.zichanView.shouyi.text = result["data"]["finance"]["interestAvailable"].stringValue
                self.financeView.zichan.text = "总资产：\(result["data"]["finance"]["total"].stringValue)元"
                isRealName = result["data"]["isRealName"].boolValue
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

extension UserViewController {
    @objc fileprivate func userSetting()
    {
        let settingView = UserSettingViewController()
        self.navigationController?.pushViewController(settingView, animated: true)
    }
    
    @objc fileprivate func btnClick(_ sender: UITapGestureRecognizer)
    {
        let currView = sender.view
        let tag = currView?.tag
        let btnData = btnTitles[tag!]
        let title : String = btnData.0
        if title == "活期存钱罐" {
            let vc = UserHuoqiViewController()
            vc.setlastView(UserViewController())
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = titlesVc[title] ?? nil
            if vc != nil {
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
    
    @objc fileprivate func goTixian()
    {
        let withView = UserWithdrawViewController()
        self.navigationController?.pushViewController(withView, animated: true)
    }
    
    @objc fileprivate func goChongzhi()
    {
        if isRealName {
            let rechargeView = UserRechargeViewController()
            self.navigationController?.pushViewController(rechargeView, animated: true)
        }else {
            let alertController = UIAlertController(title: "系统提示", message: "您还未进行实名认证，无法充值，是否立即实名", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title : "取消",style: .cancel, handler:nil)
            let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
                self.setName()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func setName()
    {
        let setNameView = SetNameViewController()
        self.navigationController?.pushViewController(setNameView, animated: true)
    }
}

extension UserViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsety = scrollView.contentOffset.y
        if currentOffsety <= -54 {
            isReload = true
        }
        if currentOffsety == 0 && isReload {
            isReload = false
            loadData()
        }
        var lashenFrame = lashenView.frame
        lashenFrame.origin.y = currentOffsety
        lashenFrame.size.height = zichanH + heardH - currentOffsety
        lashenView.frame = lashenFrame
        zichanView.frame.origin.y = heardH - currentOffsety
    }
}
