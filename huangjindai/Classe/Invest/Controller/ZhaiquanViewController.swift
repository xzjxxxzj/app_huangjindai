//
//  ZhaiquanViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/2.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
//最小高度
fileprivate let minClaimsH: CGFloat = 120
//数据总高度
fileprivate var scollH : CGFloat = 0
//当前页数
fileprivate var page : Int = 1

fileprivate var collectH : CGFloat = kMobileH - kStatusH - kHeardH - kTitlesH - kTabbarH + kHotH

fileprivate var claimsList : [UIView] = [UIView]()

class ZhaiquanViewController: UIViewController {
    
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
        model.zhaiquanRequestData(params: ["page" : 1], success: { (retrunData) in
            self.collectionView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                self.claimsRequest(retrunData["data"])
            }
        }) { (error) in
            self.collectionView.mj_header.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    fileprivate func loadDataPage() {
        model.zhaiquanRequestData(params: ["page" : page], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                self.claimsRequestPage(retrunData["data"])
            }
        }) { (error) in
            self.collectionView.mj_footer.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
}
extension ZhaiquanViewController {
    @objc fileprivate func clickClaims(_ sender: UITapGestureRecognizer)
    {
        //判断用户是否登陆
        if(UserDefaults.standard.dictionary(forKey: "user") != nil) {
            let userInfo = UserDefaults.standard.dictionary(forKey: "user") ?? [:]
            let userId = userInfo["userId"] ?? ""
            let url = NetWorkTools.GETURL(url: "\(kUrl)app/apphtml/claimsDetail", params: ["userId":userId,"claimsId":sender.view?.tag ?? 0])
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

extension ZhaiquanViewController {
    fileprivate func claimsRequest(_ returnData : JSON)
    {
        scollH = 0
        page = 1
        for chilren in claimsList {
            chilren.removeFromSuperview()
        }
        claimsList = [UIView]()
        
        self.collectionView.contentSize = CGSize(width : kMobileW, height: self.collectionView.frame.height)
        //有数据
        setData(returnData)
    }
    
    fileprivate func claimsRequestPage(_ returnData : JSON)
    {
        if returnData.isEmpty {
            self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.collectionView.mj_footer.isHidden = true
            })
        } else {
            //有数据
            self.collectionView.mj_footer.endRefreshing()
            setData(returnData)
        }
    }
    
    fileprivate func setData(_ returnData : JSON) {
        page += 1
        let H = (self.collectionView.frame.height - 15)/4 > minClaimsH ? (self.collectionView.frame.height - 15)/4 : minClaimsH
        for (index, dealData) : (String, JSON) in returnData {
            let view = InvestClaimsView.investClaimsView()
            //开启用户交互
            view.isUserInteractionEnabled = true
            view.tag = dealData["claimsId"].intValue
            //添加点击事件
            let investTap = UITapGestureRecognizer(target: self, action: #selector(clickClaims(_:)))
            view.addGestureRecognizer(investTap)
            var Y : CGFloat = 0
            if index != "0" || scollH != 0{
                Y =  scollH + H + 5
            }
            scollH = Y
            view.frame = CGRect(x: 0, y: Y, width: kMobileW, height: H)
            view.setDealName(dealData["dealName"].stringValue)
            view.setRate(rate: dealData["dealRate"].floatValue, Jiaxi: dealData["dealRebate"].floatValue)
            view.setDealStatus(dealData["status"].stringValue)
            let jindu = dealData["jindu"].doubleValue
            view.setValue(CGFloat(jindu))
            view.leftDay.text = dealData["leftDay"].stringValue
            view.setZhekou(Zhekou: dealData["rates"].floatValue)
            claimsList.append(view)
            collectionView.addSubview(view)
        }
        self.collectionView.contentSize = CGSize(width : kMobileW, height: scollH + H + kHotH)
    }
}
