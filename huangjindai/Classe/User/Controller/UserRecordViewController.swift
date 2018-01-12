//
//  UserRecordViewController.swift
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
fileprivate var page : Int = 0
fileprivate var scollH : CGFloat = heardH
fileprivate var recordListView = [UIView]()
fileprivate var listAll : Int = 0
fileprivate let heardH : CGFloat = 30

class UserRecordViewController: UIViewController {

    fileprivate lazy var contenView : UIScrollView = {
        let collectionView = UIScrollView(frame: CGRect(x: 0, y: kStatusH + kHeardH - kHotH , width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH))
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    fileprivate lazy var heardView : UIView = {
        let heardView = UIView(frame: CGRect(x: 0, y: 0, width: kMobileW, height: heardH))
        heardView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        var x: CGFloat = 0
        for tital in ["类型／时间","金额","余额"] {
            let label = UILabel(frame : CGRect(x: x, y: 0, width: kMobileW/3, height: heardH))
            x = x + kMobileW/3
            label.text = tital
            label.textAlignment = NSTextAlignment.center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(r: 204, g: 204, b: 204)
            heardView.addSubview(label)
        }
        return heardView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(contenView)
        contenView.addSubview(heardView)
        view.backgroundColor = UIColor.white
        loadData()
        setUpRefresh()
        setBtn()
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
    
    fileprivate func setBtn()
    {
        self.title = "交易记录"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension UserRecordViewController {
    
    fileprivate func setUpRefresh() {
        // MARK: - 下拉
        self.contenView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            self?.loadData()
            self?.contenView.mj_footer.isHidden = false
            self?.contenView.mj_footer.resetNoMoreData()
        })
        // MARK: - 上拉
        self.contenView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadDataPage()
        })
    }
    
    fileprivate func loadData() {
        let userId = userData["userId"] ?? ""
        model.recordList(params: ["userId" : userId,"page" : 1], success: { (retrunData) in
            self.contenView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                self.recordRequest(retrunData["data"])
            }else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            self.contenView.mj_header.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    fileprivate func loadDataPage() {
        let userId = userData["userId"] ?? ""
        model.recordList(params: ["userId" : userId,"page" : page], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                self.recordRequestPage(retrunData["data"])
            }else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            self.contenView.mj_footer.endRefreshing()
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
    
    fileprivate func recordRequest(_ returnData : JSON)
    {
        scollH = heardH
        page = 1
        listAll = 0
        for chilren in recordListView {
            chilren.removeFromSuperview()
        }
        recordListView = [UIView]()
        
        self.contenView.contentSize = CGSize(width : kMobileW, height: self.contenView.frame.height)
        //有数据
        setData(returnData)
    }
    
    fileprivate func recordRequestPage(_ returnData : JSON)
    {
        if returnData["list"].isEmpty {
            self.contenView.mj_footer.endRefreshingWithNoMoreData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.contenView.mj_footer.isHidden = true
            })
        }else {
            //有数据
            self.contenView.mj_footer.endRefreshing()
            setData(returnData)
        }
    }
    
    fileprivate func setData(_ returnData : JSON) {
        page += 1
        let listH : CGFloat = 55
        for (index, listData) : (String, JSON) in returnData["list"] {
            listAll = listAll + 1
            let view = RecordView.recordView()
            var Y : CGFloat = heardH
            if index != "0" || scollH != heardH{
                Y =  scollH + listH
            }
            if listAll % 2 != 0 {
                view.backgroundColor = UIColor.white
            }else {
                view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
            }
            scollH = Y
            view.frame = CGRect(x: 0, y: Y, width: kMobileW, height: listH)
            view.typeName.text = listData["type"].stringValue
            view.time.text = listData["time"].stringValue
            view.money.text = "\(listData["money"].stringValue)"
            view.leftMoney.text = "\(listData["balance"].doubleValue)"
            recordListView.append(view)
            contenView.addSubview(view)
        }
        self.contenView.contentSize = CGSize(width : kMobileW, height: scollH + listH + kHotH)
    }
}
