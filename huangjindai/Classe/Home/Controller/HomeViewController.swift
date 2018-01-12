//
//  HomeViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/19.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON

private var url : [String] = []
//图片描述栏 高度
private let statusH : CGFloat = 100
//活期高度
private let collectH : CGFloat = kMobileH - kStatusH - kHeardH - kTabbarH + kHotH
private let pageH : CGFloat = collectH - kBannerH - statusH
private let huoqiH : CGFloat = pageH/2 - 2 > 150 ? pageH/2 - 2 : 150

class HomeViewController: UIViewController {
    
    var contentView : UIScrollView = UIScrollView()
    
    fileprivate lazy var collectionView : UIScrollView = {[weak self] in
        let collectionView = UIScrollView(frame: CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: collectH))
        collectionView.isScrollEnabled = true
        collectionView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        collectionView.contentSize = CGSize(width: kMobileW, height: kBannerH + statusH + huoqiH*2 + kHotH)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return collectionView
    }()
    
    fileprivate lazy var addHeard : HeardViewController = HeardViewController()
    fileprivate let model = HomeModel()
    
    //图片栏懒加载
    fileprivate lazy var homeStatus : HomeStatusView = {
        let statusView = HomeStatusView.homeStatusView()
        statusView.frame = CGRect(x: 0, y:kBannerH , width: kMobileW, height: statusH)
        return statusView
    }()
    //活期栏目
    fileprivate lazy var huoqi : HomeHuoqiView = {
        let huoqiView = HomeHuoqiView.homeHuoqiView()
        huoqiView.frame = CGRect(x: 0, y: 0 , width: kMobileW, height: huoqiH)
        return huoqiView
    }()
    //标的栏目
    fileprivate lazy var invest : HomeInvestView = {
        let investView = HomeInvestView.homeInvestView()
        investView.frame = CGRect(x: 0, y: self.huoqi.frame.height, width: kMobileW, height: huoqiH)
        return investView
    }()
    
    //添加子内容控制器
    fileprivate lazy var pageView : PageContentView = {[weak self] in
        let contentFrame = CGRect(x: 0, y:kBannerH + statusH , width: kMobileW, height: pageH)
        var childVcs = [UIViewController]()
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        childVcs.append(vc)
        let contentView = PageContentView(frame : contentFrame, childVcs : childVcs, parentVc : self)
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tabIndex > 0 {
            self.tabBarController?.selectedIndex = tabIndex
            tabIndex = 0
        }
        view.backgroundColor = UIColor.white
        setUpRefresh()
        loadData()
        setHomeUI()
    }
    
    fileprivate func setUpRefresh() {
        
        // MARK: - 下拉刷新
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            self?.loadData()
        })
    }
    
    fileprivate func loadData() {
        model.requestData(success: { (result) in
            self.collectionView.mj_header.endRefreshing()
            if result["data"]["banner"].count > 0 {
                self.banner(result["data"]["banner"])
            }
            if result["data"]["huoqi"].count > 0 {
                self.huoqiRequest(result["data"]["huoqi"])
            }
            if result["data"]["deal"].count > 0 {
                self.dealRequest(result["data"]["deal"])
            }
        }, failture: { (error) in
            self.collectionView.mj_header.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
extension HomeViewController {
    fileprivate func setHomeUI() {
        //设置导航栏
        addHeard.heardBnt(UIcontroller: self)
        addHeard.delegate = self
        //添加可滑动视图
        contentView = collectionView
        view.addSubview(contentView)
        //关闭自动调整内边距
        automaticallyAdjustsScrollViewInsets = false
        //设置图片描述栏目
        contentView.addSubview(homeStatus)
        //添加子控制器
        contentView.addSubview(pageView)
        //在子控制器里面加上活期控制器
        pageView.addSubview(huoqi)
    }
    
    //设置banner
    fileprivate func setBanner(_ bannerPath : [String])
    {
        let cycle = bannerView.init(width: kMobileW, height: kBannerH)
        cycle.delegate = self
        contentView.addSubview(cycle)
        cycle.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(kMobileW)
            make.height.equalTo(kBannerH)
        }
        cycle.imageURLs = bannerPath
    }
}

extension HomeViewController : BannerViewDelegate {
    func clickScrollView(index: NSInteger) {
        if url[index] != "" {
            let webView = WKWebViewController()
            webView.urlString = url[index]
            //隐藏底部
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(webView, animated: true)
        }
    }
    
    @objc fileprivate func huoqiClick() {
        //判断用户是否登陆
        if(UserDefaults.standard.dictionary(forKey: "user") != nil) {
            let vc = UserHuoqiViewController()
            vc.setlastView(HomeViewController())
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let loginViewController = LoginViewController()
            loginViewController.setLastView(toView: HomeViewController())
            self.navigationController!.pushViewController(loginViewController, animated: true)
        }
    }
    
    @objc fileprivate func clickInvest(_ sender : UITapGestureRecognizer) {
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

extension HomeViewController {
    fileprivate func huoqiRequest(_ huoqiData: JSON) {
        huoqi.huoqiRate.text = huoqiData["rate"].string ?? "0"
        huoqi.wanfenshouyi.attributedText = PublicLib.setStringColer(string: "万份收益：\(huoqiData["tenThousandReturns"].string ?? "0") 元", setString: huoqiData["tenThousandReturns"].string ?? "0", color: UIColor.orange,size: huoqi.wanfenshouyi.font)
        huoqi.yestdayMoney.attributedText = PublicLib.setStringColer(string: "昨日收益：\(huoqiData["allInterst"].string ?? "0") 元", setString: huoqiData["allInterst"].string ?? "0", color: UIColor.orange,size: huoqi.wanfenshouyi.font)
        
        huoqi.huoqiButton.addTarget(self, action: #selector(huoqiClick), for: .touchUpInside)
    }
    
    fileprivate func banner(_ bannerData : JSON) {
        var bannerPath: [String] = []
        url = []
        for (_, subJson) : (String, JSON) in bannerData {
            bannerPath.append(subJson["image"].string ?? "")
            url.append(subJson["url"].string ?? "")
        }
        if !bannerPath.isEmpty {
            setBanner(bannerPath)
        }
    }
    
    fileprivate func dealRequest(_ dealData : JSON) {
        //添加标的
        pageView.addSubview(invest)
        invest.addLine(invest.frame.height)
        //开启用户交互
        invest.isUserInteractionEnabled = true
        //添加点击事件
        let investTap = UITapGestureRecognizer(target: self, action: #selector(clickInvest(_:)))
        invest.addGestureRecognizer(investTap)
        
        invest.tag = dealData["dealId"].intValue
        invest.setDealName(dealData["dealName"].stringValue)
        invest.month.text = dealData["dealLimit"].stringValue
        invest.dealType.text = dealData["dealType"].stringValue
        invest.setRate(dealRate: dealData["rate"].floatValue, dealRebate: dealData["rebate"].floatValue)
        let jindu = dealData["jindu"].doubleValue
        invest.setDealStatus(dealData["dealStatus"].stringValue)
        invest.setValue(CGFloat(jindu))
        invest.setTeshu(isTure: dealData["isTeshu"].boolValue, teshuTxt: dealData["teshuText"].stringValue)
        invest.setVoucher(dealData["useVoucher"].intValue)
    }
}

extension HomeViewController : msgClickDelete {
    func msgClick() {
        //判断用户是否登陆
        if(UserDefaults.standard.dictionary(forKey: "user") != nil) {
            self.hidesBottomBarWhenPushed = true
            let msgViewController = UserMsgControllerView()
            self.navigationController?.pushViewController(msgViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        } else {
            let loginViewController = LoginViewController()
            loginViewController.setLastView(toView: HomeViewController())
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }
    }
}


