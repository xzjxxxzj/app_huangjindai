//
//  UserRepayDetailViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/29.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let detailH : CGFloat = 275
fileprivate let statusH : CGFloat = 90
fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!
fileprivate var dealId : Int = 0

class UserRepayDetailViewController: UIViewController {

    fileprivate var dealOrderId : Int = 0
    
    fileprivate lazy var collectionView : UICollectionView = {
        // 1.创建layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        // 2.创建UICollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:kStatusH + kHeardH - kHotH, width:kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH), collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    fileprivate lazy var infoView : UserRepayDetailHeardView = {
        let infoView = UserRepayDetailHeardView.userRepayDetailHeardView()
        infoView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: detailH)
        return infoView
    }()
    
    fileprivate lazy var statusView : UserRepayListHearView = {
        let statusView = UserRepayListHearView.userRepayListHearView()
        statusView.frame = CGRect(x: 0, y: detailH, width: kMobileW, height: statusH)
        return statusView
    }()
    
    fileprivate lazy var listView :UserRepayListView = {
        let listView = UserRepayListView.userRepayListView()
        listView.btn.addTarget(self, action: #selector(dealDetail), for: .touchUpInside)
        return listView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setBtn()
        loadData()
        view.backgroundColor = UIColor.white
        collectionView.addSubview(infoView)
        collectionView.addSubview(statusView)
        view.addSubview(collectionView)
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
    
    func setOrder(_ id : Int)
    {
        dealOrderId = id
    }
    
    fileprivate func setBtn()
    {
        self.title = "回款计划"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func dealDetail()
    {
        let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        let userId = userInfo["userId"] ?? ""
        let url = NetWorkTools.GETURL(url: "\(kUrl)app/apphtml/detail", params: ["userId":userId,"dealId":dealId])
        let webView = WKWebViewController()
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
}

extension UserRepayDetailViewController
{
    fileprivate func loadData()
    {
        let userId = userData["userId"] ?? ""
        model.getUserRepayDetail(params: ["userId" : userId,"dealOrderId" : dealOrderId], success: { (result) in
            if result["code"].intValue == 1 {
                if result["data"]["dealInfo"].count > 0 {
                    let dealInfo : JSON = result["data"]["dealInfo"]
                    dealId = dealInfo["dealId"].intValue
                    self.infoView.setDealName(dealInfo["dealName"].stringValue)
                    self.infoView.month.text = "\(dealInfo["dealLimit"].doubleValue)"
                    self.infoView.jindu.text = dealInfo["jindu"].stringValue
                    var rate : String = "\(dealInfo["rate"].doubleValue)"
                    if dealInfo["rebate"].doubleValue > 0 {
                        rate = rate + " + \(dealInfo["rebate"].doubleValue)"
                    }
                    self.infoView.rate.text = rate
                }
                
                if result["data"]["dealOrderInfo"].count > 0 {
                    let dealOrderInfo : JSON = result["data"]["dealOrderInfo"]
                    self.infoView.money.text = "\(dealOrderInfo["loanMoney"].doubleValue)"
                    self.infoView.time.text = dealOrderInfo["createTime"].stringValue
                    if dealOrderInfo["addRates"].doubleValue > 0 {
                        self.infoView.youhui.text = "\(dealOrderInfo["addRates"].doubleValue)%加息券"
                    }else if dealOrderInfo["voucherMoney"].doubleValue > 0 {
                        self.infoView.youhui.text = "\(dealOrderInfo["voucherMoney"].doubleValue)元代金券"
                    }else {
                        self.infoView.youhui.text = "未使用"
                    }
                }
                
                if result["data"]["repayList"].count > 0 {
                    var H : CGFloat = 0
                    for (_, list) : (String, JSON) in result["data"]["repayList"] {
                        self.listView.setList(list["payTime"].stringValue, "\(list["money"].doubleValue)", list["type"].intValue, list["status"].intValue)
                        H = H + 40
                    }
                    H = H + 70
                    self.listView.frame = CGRect(x: 0, y: detailH + statusH, width: kMobileW, height: H)
                    self.collectionView.contentSize = CGSize(width : kMobileW, height: detailH + statusH + H)
                }
                self.collectionView.addSubview(self.listView)
            }else if result["code"].intValue == 2 {
                self.notLogin()
            }
        }, failture: { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        })
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
