//
//  UserInviteDetailViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/13.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!
fileprivate var selectIndex : Int = 1
fileprivate let titleH : CGFloat = 40

fileprivate var listNum : Int = 0
fileprivate var listViewList : [UIView] = [UIView]()
fileprivate var ScorlH : CGFloat = 0

fileprivate var page : Int = 1
fileprivate var guizeH : CGFloat = 0
fileprivate var isAdd : Bool = true

class UserInviteDetailViewController: UIViewController {

    fileprivate lazy var contentionView : UIScrollView = {
        let contentionView = UIScrollView(frame: CGRect(x: 0, y:kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH))
        contentionView.showsVerticalScrollIndicator = false
        contentionView.isScrollEnabled = true
        contentionView.backgroundColor = UIColor.white
        contentionView.alwaysBounceVertical = true
        contentionView.contentSize = CGSize(width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH )
        return contentionView
    }()
    
    fileprivate lazy var detailView : InviteDetailView = {
        let detailView = InviteDetailView.inviteDetailView()
        return detailView
    }()
    
    //添加子页面
    fileprivate lazy var pageTitleView : PageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y: detailView.frame.height, width: kMobileW , height: kTitlesH)
        let view = PageTitleView(frame: titleFrame, titles: ["注册用户","投资用户"], isScroll: false)
        view.delegate = self
        return view
    }()
    
    fileprivate lazy var regiestView : UIView = {
        let registView = UIView(frame: CGRect(x: 0, y: pageTitleView.frame.origin.y + kTitlesH , width: kMobileW, height: titleH))
        let titleView = InviteRegView.inviteRegView()
        titleView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        titleView.oneName.text = "手机号"
        titleView.towName.text = "姓名"
        titleView.threeName.text = "注册时间"
        titleView.endName.text = "是否投资"
        titleView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: titleH)
        registView.addSubview(titleView)
        return registView
    }()
    
    fileprivate lazy var investView : UIView = {
        let investView = UIView(frame: CGRect(x: 0, y: pageTitleView.frame.origin.y + kTitlesH, width: kMobileW, height: titleH))
        let titleView = InviteInvestView.inviteInvestView()
        titleView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        titleView.oneName.text = "手机号"
        titleView.towName.text = "项目"
        titleView.threeName.text = "奖励"
        titleView.fourName.text = "债权转出"
        titleView.endName.text = "状态"
        titleView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: titleH)
        investView.addSubview(titleView)
        return investView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        setBtn()
        setUpRefresh()
        loadData()
        guizeH = 0
        view.addSubview(contentionView)
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
        self.title = "我的邀请"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UserInviteDetailViewController {
    
    fileprivate func setUpRefresh() {
        // MARK: - 下拉
        self.contentionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            self?.loadData()
            self?.contentionView.mj_footer.isHidden = false
            self?.contentionView.mj_footer.resetNoMoreData()
        })
        // MARK: - 上拉
        self.contentionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadDataPage()
        })
    }
    
    fileprivate func loadDataPage() {
        let userId = userData["userId"] ?? ""
        model.inviteInfoList(params: ["userId" : userId,"type" : selectIndex,"page" : page], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                if retrunData["data"]["list"].isEmpty {
                    self.contentionView.mj_footer.endRefreshingWithNoMoreData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        self.contentionView.mj_footer.isHidden = true
                    })
                }else {
                    //有数据
                    self.contentionView.mj_footer.endRefreshing()
                    if selectIndex == 1 {
                        self.setRegisterView(retrunData["data"]["list"])
                    }else {
                        self.setInvestView(retrunData["data"]["list"])
                    }
                }
            }else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            self.contentionView.mj_footer.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    fileprivate func loadData()
    {
        model.inviteDetail(params: ["userId" : userData["userId"] ?? "","type" : "\(selectIndex)"], success: { (result) in
            self.contentionView.mj_header.endRefreshing()
            if result["code"].intValue == 1 {
                ScorlH = 0
                page = 1
                listNum = 0
                isAdd = true
                self.removeListView()
                let detailInfo = result["data"]["info"]
                self.detailView.isGetMoney.text = "\(detailInfo["allReward"].doubleValue - detailInfo["notPayReward"].doubleValue)"
                self.detailView.isInvitePeople.text = "\(detailInfo["allReg"].doubleValue)"
                self.detailView.setGuizhe(result["data"]["guizhe"])
                
                self.detailView.monthRegiestNum.text = "\(detailInfo["newReg"].doubleValue)"
                self.detailView.monthInvestNum.text = "\(detailInfo["newInvest"].doubleValue)"
                self.detailView.monthInvestMoney.text = "\(detailInfo["newMoney"].doubleValue)"
                self.detailView.monthWillGetMoney.text = "\(detailInfo["newReward"].doubleValue)"
                
                self.detailView.allRegiestNum.text = "\(detailInfo["allReg"].doubleValue)"
                self.detailView.allInvestNum.text = "\(detailInfo["allInvest"].doubleValue)"
                self.detailView.allInviteMoney.text = "\(detailInfo["allReward"].doubleValue)"
                self.detailView.allNotPayMoney.text = "\(detailInfo["notPayReward"].doubleValue)"
                
                var detailY = self.detailView.lastView.frame.origin.y + self.detailView.lastView.frame.height
                let guizheNewH : CGFloat = self.detailView.guizhe.height
                if guizheNewH != guizeH {
                    detailY = detailY + guizheNewH - guizeH
                    guizeH = guizheNewH
                }
                self.detailView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: detailY)
                ScorlH = self.detailView.frame.height + kTitlesH
                if isAdd {
                    self.contentionView.addSubview(self.detailView)
                    self.contentionView.addSubview(self.pageTitleView)
                    isAdd = false
                }
                if selectIndex == 1 {
                    self.setRegisterView(result["data"]["list"])
                }else {
                    self.setInvestView(result["data"]["list"])
                }
            } else {
                if result["code"].intValue == 2 {
                    self.notLogin()
                }else {
                    AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:result["msg"].stringValue)
                }
            }
        }) { (error) in
            self.contentionView.mj_header.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    fileprivate func setRegisterView(_ listData : JSON)
    {
        page = page + 1
        self.contentionView.addSubview(self.regiestView)
        listViewList.append(self.regiestView)
        ScorlH = ScorlH + titleH
        for (_, register) : (String, JSON) in listData {
            let Y = ScorlH
            let titleView = InviteRegView.inviteRegView()
            if listNum % 2 != 0 {
                titleView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
            }
            ScorlH = ScorlH + titleH
            titleView.oneName.text = PublicLib.subString(string: register["mobile"].stringValue, start: 2, lenth: -3, replay: "**")
            titleView.towName.text = register["realName"].stringValue == "" ? "未实名" : PublicLib.subString(string: register["realName"].stringValue, start: 0, lenth: -1, replay: "*")
            titleView.threeName.text = register["regTime"].stringValue
            titleView.endName.text = register["is_invest"].intValue == 1 ? "已投资":"未投资"
            titleView.frame = CGRect(x: 0, y: Y, width: kMobileW, height: titleH)
            listNum = listNum + 1
            listViewList.append(titleView)
            self.contentionView.addSubview(titleView)
        }
        self.contentionView.contentSize = CGSize(width: kMobileW, height: ScorlH)
        ScorlH = ScorlH - titleH
    }
    
    fileprivate func setInvestView(_ listData : JSON)
    {
        page = page + 1
        self.contentionView.addSubview(self.investView)
        listViewList.append(self.investView)
        ScorlH = ScorlH + titleH
        for (_, register) : (String, JSON) in listData {
            let Y = ScorlH
            let titleView = InviteInvestView.inviteInvestView()
            if listNum % 2 != 0 {
                titleView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
            }
            ScorlH = ScorlH + titleH
            titleView.oneName.text = PublicLib.subString(string: register["mobile"].stringValue, start: 2, lenth: -3, replay: "**")
            titleView.towName.text = register["dealId"].stringValue
            titleView.threeName.text = "\(register["rewardMoney"].doubleValue)"
            titleView.fourName.text = "\(register["rewardMoneyOut"].intValue)"
            titleView.endName.text =  register["status"].intValue == 1 ? "已还":"未还"
            titleView.frame = CGRect(x: 0, y: Y, width: kMobileW, height: titleH)
            listNum = listNum + 1
            listViewList.append(titleView)
            self.contentionView.addSubview(titleView)
        }
        self.contentionView.contentSize = CGSize(width: kMobileW, height: ScorlH)
        ScorlH = ScorlH - titleH
    }
    
    fileprivate func removeListView()
    {
        for chilren in listViewList {
            chilren.removeFromSuperview()
        }
        listViewList = [UIView]()
        self.contentionView.contentSize = CGSize(width : kMobileW, height: self.contentionView.frame.height)
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

extension UserInviteDetailViewController : PageTitleViewDelegate
{
    func pageTitleView(_ titleView: PageTitleView, selectedIndex index : Int)
    {
        self.contentionView.mj_footer.isHidden = false
        self.contentionView.mj_footer.resetNoMoreData()
        selectIndex = index == 0 ? 1 : 2
        ScorlH = self.detailView.frame.height + kTitlesH
        page = 1
        listNum = 0
        removeListView()
        loadDataPage()
    }
}
