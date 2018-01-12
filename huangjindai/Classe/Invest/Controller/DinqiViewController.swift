//
//  DinqiViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/2.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
//最小高度
fileprivate let minInvestH: CGFloat = 150
//数据总高度
fileprivate var scollH : CGFloat = 0
//当前页数
fileprivate var page : Int = 1

fileprivate var collectH : CGFloat = kMobileH - kStatusH - kHeardH - kTitlesH - kTabbarH + kHotH

fileprivate var investList : [UIView] = [UIView]()

class DinqiViewController: UIViewController {
    
    fileprivate let model = InvestModel()
    
    fileprivate lazy var collectionView : UIScrollView = {
        let collectionView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kMobileW, height: collectH))
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        setUpRefresh()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        model.dinqiRequestData(params: ["page" : 1], success: { (retrunData) in
            self.collectionView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                self.investRequest(retrunData["data"])
            }
        }) { (error) in
            self.collectionView.mj_header.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }

    fileprivate func loadDataPage() {
        model.dinqiRequestData(params: ["page" : page], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                self.investRequestPage(retrunData["data"])
            }
        }) { (error) in
            self.collectionView.mj_footer.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
}

extension DinqiViewController {
    @objc fileprivate func clickInvest(_ sender: UITapGestureRecognizer)
    {
        //判断用户是否登陆
        if(UserDefaults.standard.dictionary(forKey: "user") != nil) {
            let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
            let userId = userInfo["userId"] ?? ""
            let url = NetWorkTools.GETURL(url: "\(kUrl)app/apphtml/detail", params: ["userId":userId,"dealId":sender.view?.tag ?? 0])
            let webView = WKWebViewController()
            webView.urlString = url
            //隐藏底部
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(webView, animated: true)
        } else {
            let loginViewController = LoginViewController()
            loginViewController.setLastView(toView: HomeViewController())
            self.navigationController!.pushViewController(loginViewController, animated: true)
        }
    }
}

extension DinqiViewController {
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
        if returnData.isEmpty {
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
        let H = (self.collectionView.frame.height - 15)/4 > minInvestH ? (self.collectionView.frame.height - 15)/4 : minInvestH
        for (index, dealData) : (String, JSON) in returnData {
            let view = HomeInvestView.homeInvestView()
            //开启用户交互
            view.isUserInteractionEnabled = true
            view.tag = dealData["dealId"].intValue
            //添加点击事件
            let investTap = UITapGestureRecognizer(target: self, action: #selector(clickInvest(_:)))
            view.addGestureRecognizer(investTap)
            var Y : CGFloat = 0
            if index != "0" || scollH != 0{
                Y =  scollH + H + 5
            }
            scollH = Y
            view.frame = CGRect(x: 0, y: Y, width: kMobileW, height: H)
            view.setDealName(dealData["dealName"].stringValue)
            view.month.text = dealData["dealLimit"].stringValue
            view.dealType.text = dealData["dealType"].stringValue
            view.setDealStatus(dealData["dealStatus"].stringValue)
            view.setRate(dealRate: dealData["rate"].floatValue, dealRebate: dealData["rebate"].floatValue)
            let jindu = dealData["jindu"].doubleValue
            view.setValue(CGFloat(jindu))
            view.setTeshu(isTure: dealData["isTeshu"].boolValue, teshuTxt: dealData["teshuText"].stringValue)
            view.setVoucher(dealData["useVoucher"].intValue)
            view.addLine(view.frame.height)
            investList.append(view)
            collectionView.addSubview(view)
        }
        self.collectionView.contentSize = CGSize(width : kMobileW, height: scollH + H + kHotH)
    }
}
