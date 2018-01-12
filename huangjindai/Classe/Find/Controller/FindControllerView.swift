//
//  FindControllerView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/8.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
import Kingfisher

fileprivate let model = FindModel()
fileprivate let viewH : CGFloat = 100
fileprivate var scollH : CGFloat = 0
//当前页数
fileprivate var page : Int = 1
fileprivate var linkUrl : String = ""
//存放新闻view
fileprivate var newVews : [UIView] = [UIView]()

class FindControllerView: UIViewController {
    fileprivate var newsView : UIView = UIView(frame : CGRect(x: 0, y:kStatusH + kHeardH - kHotH , width: kMobileW, height: kMobileH - kStatusH - kHeardH - kTabbarH + kHotH))
    
    fileprivate lazy var contentView : UIScrollView = {
        let view = UIScrollView(frame : CGRect(x: 0, y: 0, width: kMobileW, height: newsView.frame.height))
        view.autoresizingMask = UIViewAutoresizing.flexibleHeight
        view.contentSize = CGSize(width: kMobileW, height: newsView.frame.height)
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = true
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return view
    }()
    
    fileprivate lazy var addHeard : HeardViewController = HeardViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUI()
        self.automaticallyAdjustsScrollViewInsets = false
        newsView.addSubview(contentView)
        view.addSubview(newsView)
        setUpRefresh()
        page = 1
        loadData(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setUI()
    {
        //设置导航栏
        addHeard.heardBnt(UIcontroller: self)
        addHeard.delegate = self
    }
}

extension FindControllerView {
    fileprivate func setUpRefresh() {
        
        // MARK: - 下拉
        self.contentView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            page = 1
            self?.loadData(true)
            self?.contentView.mj_footer.isHidden = false
            self?.contentView.mj_footer.resetNoMoreData()
        })
        // MARK: - 上拉
        self.contentView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData()
        })
    }
    
    fileprivate func loadData(_ isDown : Bool = false) {
        model.requestData(params: ["page" : page], success: { (retrunData) in
            self.contentView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                page += 1
                if isDown {
                    scollH = 0
                    for chilren in newVews {
                        chilren.removeFromSuperview()
                    }
                    newVews = [UIView]()
                    self.contentView.contentSize = CGSize(width : kMobileW, height: self.contentView.frame.height + kHotH)
                }
                if retrunData["data"].isEmpty {
                    self.contentView.mj_footer.endRefreshingWithNoMoreData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        self.contentView.mj_footer.isHidden = true
                    })
                }else {
                    //有数据
                    self.contentView.mj_footer.endRefreshing()
                    linkUrl = retrunData["linkUrl"].stringValue
                    for (index, data) : (String,JSON) in retrunData["data"] {
                        let view = NewsView.newsView()
                        //开启用户交互
                        view.isUserInteractionEnabled = true
                        view.tag = data["id"].intValue
                        //添加点击事件
                        let newsTap = UITapGestureRecognizer(target: self, action: #selector(self.clickNews(_:)))
                        view.addGestureRecognizer(newsTap)
                        var Y : CGFloat = 0
                        if index != "0" || scollH != 0{
                            Y =  scollH + viewH + 5
                        }
                        scollH = Y
                        view.frame = CGRect(x: 0, y: Y, width: kMobileW, height: viewH)
                        view.setTitle(data["title"].stringValue)
                        view.setContent(data["description"].stringValue)
                        //时间戳转换
                        let dateMatter : DateFormatter = DateFormatter()
                        dateMatter.dateFormat = "yyyy-MM-dd"
                        let timeInterVal : TimeInterval = TimeInterval(data["createTime"].intValue)
                        let date = Date(timeIntervalSince1970 : timeInterVal)
                        view.createTime.text = dateMatter.string(from: date)
                        view.newsImage?.kf.setImage(with: URL(string: data["thumb"].stringValue))
                        newVews.append(view)
                        self.contentView.addSubview(view)
                    }
                    self.contentView.contentSize = CGSize(width : kMobileW, height: scollH + viewH + kHotH)
                }
            }
        }) { (error) in
            self.contentView.mj_header.endRefreshing()
            self.contentView.mj_footer.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
}

extension FindControllerView : msgClickDelete {
    func msgClick() {
        //判断用户是否登陆
        if(UserDefaults.standard.dictionary(forKey: "user") != nil) {
            self.hidesBottomBarWhenPushed = true
            let msgViewController = UserMsgControllerView()
            self.navigationController?.pushViewController(msgViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        } else {
            self.hidesBottomBarWhenPushed = true
            let loginViewController = LoginViewController()
            loginViewController.setLastView(toView: FindControllerView())
            self.navigationController?.pushViewController(loginViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    @objc fileprivate func clickNews(_ sender: UITapGestureRecognizer)
    {
        let currView = sender.view
        let tag = currView?.tag
        let url = "\(linkUrl)/\(tag!)"
        let webView = WKWebViewController()
        webView.urlString = url
        //隐藏底部
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webView, animated: true)
        //显示底部
        self.hidesBottomBarWhenPushed = false
    }
    
}


