//
//  UserDjqViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/23.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
//列表高度
fileprivate let djqH: CGFloat = 110
fileprivate let djqHearH : CGFloat = 40
fileprivate let willTextLable = UILabel()
//数据总高度
fileprivate var scollH : CGFloat = 0
//当前页数
fileprivate var page : Int = 1

fileprivate var collectH : CGFloat = kMobileH - kStatusH - kHeardH - kTitlesH + kHotH

fileprivate var djqList : [UIView] = [UIView]()
fileprivate let model = UserAccountModel()

fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

class UserDjqViewController: UIViewController {

    fileprivate lazy var collectionView : UIScrollView = {
        let Y = djqHearH + 20
        let collectionView = UIScrollView(frame: CGRect(x: 0, y: Y, width: kMobileW, height: collectH - Y))
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    fileprivate lazy var heardView : DjqHearView = {
        let heardView = DjqHearView.djqHearView()
        heardView.frame = CGRect(x: 0, y: 1, width: kMobileW, height: djqHearH)
        return heardView
    }()
    
    fileprivate lazy var willView : UIView = {
        let willView = UIView(frame: CGRect(x: 0, y: djqHearH, width: kMobileW, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 20, y: 5, width: 12, height: 12))
        imageView.image = UIImage(named: "tipsIco")
        willView.addSubview(imageView)
        willTextLable.frame = CGRect(x: 40, y: 5, width: kMobileW - 12, height: 12)
        willTextLable.font = UIFont.systemFont(ofSize: 12)
        willView.addSubview(willTextLable)
        willView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return willView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        view.addSubview(heardView)
        view.addSubview(willView)
        view.addSubview(collectionView)
        setUpRefresh()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UserDjqViewController {
    
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
        model.getDjqList(params: ["userId" : userId,"cardType" : 2,"page" : 1], success: { (retrunData) in
            self.collectionView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                self.djqRequest(retrunData["data"])
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
        model.getDjqList(params: ["userId" : userId,"cardType" : 2,"page" : page], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                self.djqRequestPage(retrunData["data"])
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
    
    fileprivate func djqRequest(_ returnData : JSON)
    {
        scollH = 0
        page = 1
        for chilren in djqList {
            chilren.removeFromSuperview()
        }
        djqList = [UIView]()
        
        self.collectionView.contentSize = CGSize(width : kMobileW, height: self.collectionView.frame.height)
        //有数据
        setData(returnData)
    }
    
    fileprivate func djqRequestPage(_ returnData : JSON)
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
        let keyong = "可用：\(returnData["info"]["canUse"].stringValue)元"
        heardView.canUse.attributedText = PublicLib.setStringColer(string: keyong, setString: returnData["info"]["canUse"].stringValue, color: UIColor.orange, size: heardView.canUse.font)
        let useTex = "已用：\(returnData["info"]["use"].stringValue)元"
        heardView.use.attributedText = PublicLib.setStringColer(string: useTex, setString: returnData["info"]["use"].stringValue, color: UIColor.orange, size: heardView.use.font)
        if returnData["info"]["willExper"].intValue > 0 {
            willTextLable.textColor = UIColor(r: 102, g: 102, b: 102)
            let willTxt = "您有\(returnData["info"]["willExper"].stringValue)元代金券即将在\(returnData["info"]["time"])天内到期，请尽快使用！"
            let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:willTxt)
            let str = NSString(string: willTxt)
            let theRange = str.range(of: returnData["info"]["willExper"].stringValue)
            attrstring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: theRange)
            let theRange2 = str.range(of: returnData["info"]["time"].stringValue)
            attrstring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: theRange2)
            willTextLable.attributedText = attrstring
            view.addSubview(willView)
            collectionView.frame = CGRect(x: 0, y: djqHearH + 20, width: kMobileW, height: collectH - djqHearH - 20)
        }else {
            willView.removeFromSuperview()
            collectionView.frame = CGRect(x: 0, y: djqHearH + 1, width: kMobileW, height: collectH - djqHearH - 1)
        }
        page += 1
        for (index, djqData) : (String, JSON) in returnData["list"] {
            let view = DjqListView.djqListView()
            var Y : CGFloat = 20
            if index != "0" || scollH != 0{
                Y =  scollH + djqH + 20
            }
            scollH = Y
            view.frame = CGRect(x: 10, y: Y, width: kMobileW - 20, height: djqH)
            view.backgroundColor = UIColor.clear
            view.conetentView.layer.cornerRadius = 25
            view.djqbutton.layer.cornerRadius = 25
            view.allMoney.text = "总额：\(djqData["money"].stringValue)元"
            view.canUseMoney.text = "\(djqData["money"].intValue - djqData["useMoney"].intValue)"
            view.useMoney.text = "已用：\(djqData["useMoney"].stringValue)元"
            view.laiyuan.text = "获取来源：\(djqData["source"].stringValue)"
            view.endTime.text = "过期时间：\(djqData["endTime"].stringValue)"
            if djqData["status"].intValue != 1 {
                view.conetentView.backgroundColor = UIColor(r: 204, g: 204, b: 204)
                view.djqbutton.backgroundColor = UIColor(r: 204, g: 204, b: 204)
                view.canUseMoney.text = "\(djqData["money"].intValue)"
                if djqData["status"].intValue == 2 {
                    view.djqbutton.setTitle("已使用", for: .normal)
                }else {
                    view.djqbutton.setTitle("已过期", for: .normal)
                }
            }else{
                view.djqbutton.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
            }
            
            djqList.append(view)
            collectionView.addSubview(view)
        }
        self.collectionView.contentSize = CGSize(width : kMobileW, height: scollH + djqH + kHotH)
    }
    
    @objc fileprivate func clickBtn()
    {
        let vc = MainViewController()
        tabIndex = 1
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}
