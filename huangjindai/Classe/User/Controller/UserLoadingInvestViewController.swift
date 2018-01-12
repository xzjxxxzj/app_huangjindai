//
//  UserLoadingInvestViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/1.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//
import UIKit
import MJRefresh
import SwiftyJSON
//列表高度
fileprivate let listH: CGFloat = 120
//数据总高度
fileprivate var scollH : CGFloat = 0
//当前页数
fileprivate var page : Int = 1

fileprivate var collectH : CGFloat = kMobileH - kStatusH - kHeardH - kTitlesH + kHotH

fileprivate var investList : [UIView] = [UIView]()
fileprivate let model = UserAccountModel()

fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

class UserLoadingInvestViewController: UIViewController {
    
    fileprivate lazy var collectionView : UIScrollView = {
        let collectionView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kMobileW, height: collectH))
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        setUpRefresh()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UserLoadingInvestViewController {
    
    fileprivate func setUpRefresh() {
        // MARK: - 下拉
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            self?.loadData()
            self?.collectionView.mj_footer.isHidden = false
            self?.collectionView.mj_footer.resetNoMoreData()
        })
        // MARK: - 上拉
        self.collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadDataPage()
        })
    }
    
    fileprivate func loadData() {
        let userId = userData["userId"] ?? ""
        model.getInvestList(params: ["userId" : userId,"status" : 6,"page" : 1], success: { (retrunData) in
            self.collectionView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                self.investRequest(retrunData["data"])
            }else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            self.collectionView.mj_header.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    fileprivate func loadDataPage() {
        let userId = userData["userId"] ?? ""
        model.getInvestList(params: ["userId" : userId,"status" : 6,"page" : page], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                self.investRequestPage(retrunData["data"])
            }else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            self.collectionView.mj_footer.endRefreshing()
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
    
    fileprivate func investRequest(_ returnData : JSON)
    {
        scollH = 0
        page = 1
        for chilren in investList {
            chilren.removeFromSuperview()
        }
        investList = [UIView]()
        
        self.collectionView.contentSize = CGSize(width : kMobileW, height: self.collectionView.frame.height)
        //有数据
        setData(returnData)
    }
    
    fileprivate func investRequestPage(_ returnData : JSON)
    {
        if returnData["list"].isEmpty {
            self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.collectionView.mj_footer.isHidden = true
            })
        }else {
            //有数据
            self.collectionView.mj_footer.endRefreshing()
            setData(returnData)
        }
    }
    
    fileprivate func setData(_ returnData : JSON) {
        page += 1
        for (index, investData) : (String, JSON) in returnData["list"] {
            let view = UserInvestListView.userInvestListView()
            var Y : CGFloat = 0
            if index != "0" || scollH != 0{
                Y =  scollH + listH
            }
            scollH = Y
            view.frame = CGRect(x: 0, y: Y, width: kMobileW, height: listH)
            view.setDealName(investData["dealName"].stringValue)
            view.time.text = investData["createTime"].stringValue
            view.firstMoney.text = "\(investData["loanMoney"].doubleValue)"
            view.centerName.text = "融资期限（ 月 ）"
            view.centerMoney.text = "\(investData["dealLimit"].doubleValue)"
            view.endName.text = "年化收益"
            var rate : String = "\(investData["rate"].doubleValue)%"
            if investData["rebate"].doubleValue > 0 {
                rate = rate + "+\(investData["rebate"].doubleValue)%"
            }
            view.endMoney.text = rate
            //开启交互
            view.isUserInteractionEnabled = true
            view.tag = investData["dealOrderId"].intValue
            let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewClick(_:)))
            view.addGestureRecognizer(viewTap)
            investList.append(view)
            collectionView.addSubview(view)
        }
        self.collectionView.contentSize = CGSize(width : kMobileW, height: scollH + listH + kHotH)
    }
    
    @objc fileprivate func viewClick(_ sender: UITapGestureRecognizer)
    {
        let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
        let userId = userInfo["userId"] ?? ""
        let url = NetWorkTools.GETURL(url: "\(kUrl)app/apphtml/detail", params: ["userId":userId,"dealId":sender.view?.tag ?? 0])
        let webView = WKWebViewController()
        webView.urlString = url
        //隐藏底部
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webView, animated: true)
    }
}
