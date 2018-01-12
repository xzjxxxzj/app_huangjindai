//
//  UserHuoqiViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/11.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!
fileprivate var lastView : UIViewController?
fileprivate let heardH : CGFloat = 200
fileprivate let btnH : CGFloat = 40
fileprivate let investHeardH : CGFloat = 45
fileprivate let investH : CGFloat = 150
fileprivate var scroH : CGFloat = 0
fileprivate var investList : [UIView] = [UIView]()

class UserHuoqiViewController: UIViewController {
    
    fileprivate lazy var collectionView : UIScrollView = {
        let collectView = UIScrollView(frame: CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH - kTabbarH + kHotH))
        collectView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        collectView.isScrollEnabled = true
        collectView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        collectView.contentSize = CGSize(width: kMobileW, height: kMobileH - kStatusH - kHeardH - kTabbarH + kHotH)
        collectView.showsVerticalScrollIndicator = false
        return collectView
    }()
    
    fileprivate lazy var heardView : HuoqiHeardView = {
        let heardView = HuoqiHeardView.huoqiHeardView()
        heardView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: heardH)
        heardView.backgroundColor = UIColor(r: 99, g: 119, b: 246)
        return heardView
    }()
    
    fileprivate lazy var recordBtn : BtnView = {
        let btnView = BtnView.btnView()
        btnView.backgroundColor = UIColor.white
        btnView.frame = CGRect(x: 0, y: heardH + 10 , width: kMobileW, height: btnH)
        //开启交互
        btnView.isUserInteractionEnabled = true
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(btnClick))
        btnView.addGestureRecognizer(btnTap)
        
        btnView.btnImage.image = UIImage(named: "currentIco")
        btnView.btnName.text = "交易记录"
        return btnView
    }()
    
    fileprivate lazy var InvestHeard : UIView = {
        let heardView =  Bundle.main.loadNibNamed("HuoqiInvestHeardView", owner: nil, options: nil)?.first as! UIView
        heardView.backgroundColor = UIColor.white
        heardView.frame = CGRect(x: 0, y: heardH + btnH + 20, width: kMobileW, height: investHeardH)
        return heardView
    }()
    
    fileprivate lazy var btnView : UIView = {
        let btnView = UIView(frame: CGRect(x: 0, y: kMobileH - kHotH - kTabbarH, width: kMobileW, height: kTabbarH))
        let zhuanchuButton = UIButton(frame: CGRect(x: 0, y: 0, width: kMobileW/2, height: kTabbarH))
        zhuanchuButton.setTitle("转出至余额", for: .normal)
        zhuanchuButton.setTitleColor(UIColor(r: 88, g: 105, b: 218), for: .normal)
        zhuanchuButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        zhuanchuButton.backgroundColor = UIColor.white
        zhuanchuButton.addTarget(self, action: #selector(zhuanchu), for: .touchUpInside)
        btnView.addSubview(zhuanchuButton)
        
        let zhuanruButton = UIButton(frame: CGRect(x: kMobileW/2, y: 0, width: kMobileW/2, height: kTabbarH))
        zhuanruButton.setTitle("转入", for: .normal)
        zhuanruButton.setTitleColor(UIColor.white, for: .normal)
        zhuanruButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        zhuanruButton.backgroundColor = UIColor(r: 99, g: 119, b: 246)
        zhuanruButton.addTarget(self, action: #selector(zhuanru), for: .touchUpInside)
        btnView.addSubview(zhuanruButton)
        return btnView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRefresh()
        loadData()
        setBtn()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        view.addSubview(btnView)
        collectionView.addSubview(heardView)
        collectionView.addSubview(recordBtn)
        collectionView.addSubview(InvestHeard)
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
    
    func setlastView(_ Vc : UIViewController)
    {
        lastView = Vc
    }
    
    fileprivate func setBtn()
    {
        self.title = "活期"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.pushViewController(lastView!, animated: true)
    }
    
    @objc fileprivate func btnClick()
    {
        let vc = UserHuoqiRecordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func zhuanchu()
    {
        let vc = UserHuoqiOutViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func zhuanru()
    {
        let vc = UserHuoqiIntViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UserHuoqiViewController {
    
    fileprivate func setUpRefresh() {
        
        // MARK: - 下拉刷新
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            self?.loadData()
        })
    }
    
    fileprivate func loadData() {
        let userId = userData["userId"] ?? ""
        model.huoqiInfo(params: ["userId" : userId], success: { (result) in
            if result["code"].intValue == 1 {
                self.collectionView.mj_header.endRefreshing()
                if result["data"]["info"].count > 0 {
                    self.huoqi(result["data"]["info"])
                }
                if result["data"]["dealInfo"].count > 0 {
                    self.investInfo(result["data"]["dealInfo"])
                }
            }else if result["code"].intValue == 2 {
                self.notLogin()
            }
        }, failture: { (error) in
            self.collectionView.mj_header.endRefreshing()
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
    
    fileprivate func huoqi(_ huoqiData : JSON)
    {
        heardView.allMoney.text = "总金额：\(huoqiData["huoqiMoney"].doubleValue)"
        heardView.yesterdayShouyi.text = "\(huoqiData["yesterDayMoney"].doubleValue)"
        heardView.allShouyi.text = "\(huoqiData["allMoney"].doubleValue)"
        heardView.wanFenShouyi.text = "\(huoqiData["tenThousandReturns"].doubleValue)"
        heardView.rate.text = "\(huoqiData["rate"].doubleValue)%"
    }
    
    fileprivate func investInfo(_ investData : JSON)
    {
        for chilren in investList {
            chilren.removeFromSuperview()
        }
        investList = [UIView]()
        
        scroH = heardH + investHeardH + btnH + 20
        for (_, dealData) : (String, JSON) in investData {
            let investView = HomeInvestView.homeInvestView()
            let Y = scroH
            investView.frame = CGRect(x: 0, y: Y, width: kMobileW, height: investH)
            collectionView.addSubview(investView)
            scroH = scroH + investH + 3
            investView.addLine(investView.frame.height)
            //开启用户交互
            investView.isUserInteractionEnabled = true
            //添加点击事件
            let investTap = UITapGestureRecognizer(target: self, action: #selector(clickInvest(_:)))
            investView.addGestureRecognizer(investTap)
            investView.tag = dealData["dealId"].intValue
            investView.setDealName(dealData["dealName"].stringValue)
            investView.month.text = dealData["dealLimit"].stringValue
            investView.dealType.text = dealData["dealType"].stringValue
            investView.setRate(dealRate: dealData["rate"].floatValue, dealRebate: dealData["rebate"].floatValue)
            let jindu = dealData["jindu"].doubleValue
            investView.setDealStatus(dealData["dealStatus"].stringValue)
            investView.setValue(CGFloat(jindu))
            investView.setTeshu(isTure: dealData["isTeshu"].boolValue, teshuTxt: dealData["teshuText"].stringValue)
            investView.setVoucher(dealData["useVoucher"].intValue)
            investList.append(investView)
        }
        collectionView.contentSize = CGSize(width: kMobileW, height: scroH )
    }
    
    @objc fileprivate func clickInvest(_ sender : UITapGestureRecognizer)
    {
        let view = sender.view
        let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        let userId = userInfo["userId"] ?? ""
        let url = NetWorkTools.GETURL(url: "\(kUrl)app/apphtml/detail", params: ["userId":userId,"dealId":view?.tag ?? 0])
        let webView = WKWebViewController()
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
}
