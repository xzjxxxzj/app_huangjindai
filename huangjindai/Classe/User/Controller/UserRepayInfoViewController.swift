//
//  UserRepayInfoViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/27.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

fileprivate var payTitles : [(String, JSON)] = []
fileprivate var payLists : [(String, JSON)] = []
//记录是否展开
fileprivate var flagArray : [Bool] = []
//标题View
fileprivate var titleViews : [RepayTitleView] = []
//标题高度
fileprivate let titleH : CGFloat = 40
fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!
fileprivate var Year : String = ""
fileprivate var maxYear : Int = 0

class UserRepayInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    fileprivate lazy var titleView : UIView = {
        let titleView = UIView(frame: CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: titleH))
        let title = ["日期", "已收本息", "待收本息", "状态"]
        var index: CGFloat = 0
        for name in title {
            let X = kMobileW/4 * index
            index += 1
            let label = UILabel(frame: CGRect(x: X, y: 0, width: kMobileW/4, height: titleH))
            label.text = name
            label.textColor = UIColor(r: 164, g: 164, b: 164)
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = NSTextAlignment.center
            titleView.addSubview(label)
        }
        titleView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        return titleView
    }()
    
    fileprivate lazy var timeView : YearPickterView = {
        let frame = CGRect(x: 0, y: kMobileH - 200, width: kMobileW, height: 200)
        let yearSelect: Int = Int(Year) ?? 0
        let timeview = YearPickterView.init(frame: frame,min: 2014,max: maxYear ,select: yearSelect)
        timeview.delegate = self
        return timeview
    }()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(titleView)
        setUpRefresh()
        loadData()
        setBtn()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init()
        tableView.rowHeight = 50
        tableView.frame = CGRect(x: 0, y: kStatusH + kHeardH + titleH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH - titleH + kHotH)
        view.addSubview(tableView)
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
        self.title = "回款查询"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
        let Time = Date()
        let dateForMatter = DateFormatter()
        dateForMatter.dateFormat = "YYYY"
        dateForMatter.locale = Locale.current
        let year = dateForMatter.string(from: Time)
        Year = year
        maxYear = Int(year)! + 3
        let rightBarButton = UIBarButtonItem.init(title: year, style: UIBarButtonItemStyle.plain, target: self, action: #selector(selectTime))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
        timeView.close()
    }
    
    @objc fileprivate func selectTime()
    {
        view.addSubview(timeView)
    }
    
    fileprivate func setUpRefresh() {
        // MARK: - 下拉刷新
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            self?.loadData()
        })
    }
    
    fileprivate func loadData()
    {
        let userId = userData["userId"] ?? ""
        model.getUserRepayInfo(params: ["userId" : userId,"year" : Year], success: { (result) in
            self.tableView.mj_header.endRefreshing()
            if result["code"].intValue == 1 {
                payLists = []
                payTitles = []
                flagArray = []
                for (index, titles) : (String, JSON) in result["data"]["repaySum"] {
                    payTitles.append((index,titles))
                    flagArray.append(false)
                }
                for (index, list) : (String, JSON) in result["data"]["repayDetail"] {
                    payLists.append((index,list))
                }
                self.clearAllNotice()
                self.tableView.reloadData()
            }else if result["code"].intValue == 2 {
                self.notLogin()
            }
        }, failture: { (error) in
            self.tableView.mj_header.endRefreshing()
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

extension UserRepayInfoViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagArray[section] {
            return payLists[section].1.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RepayListView = RepayListView.repayListView()
        let listData = payLists[indexPath.section].1[indexPath.row]
        cell.time.text = listData["payTime"].stringValue
        cell.money.text = "\(listData["money"].doubleValue)"
        cell.setName(listData["type"].intValue)
        cell.setStatus(listData["status"].intValue)
        //开启交互
        cell.isUserInteractionEnabled = true
        cell.tag = listData["dealOrderId"].intValue
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(clickRepay(_:)))
        cell.addGestureRecognizer(btnTap)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let listHearView = RepayTitleView.repayTitleView()
        listHearView.time.text = payTitles[section].0
        listHearView.nopay.text = "\(payTitles[section].1["noMoney"].doubleValue)"
        listHearView.repay.text = "\(payTitles[section].1["getMoney"].doubleValue)"
        listHearView.selectBtn.isSelected = flagArray[section]
        listHearView.selectBtn.tag = 2000 + section
        listHearView.selectBtn.addTarget(self, action:  #selector(clickBtn(_:)), for: .touchUpInside)
        //开启交互
        listHearView.isUserInteractionEnabled = true
        listHearView.tag = section
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(selectTitle(_:)))
        listHearView.addGestureRecognizer(btnTap)
        titleViews.append(listHearView)
        return listHearView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return payTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    @objc fileprivate func selectTitle(_ sender: UITapGestureRecognizer)
    {
        let currView = sender.view
        let tag = currView?.tag
        if flagArray[tag!] {
            titleViews[tag!].selectBtn.isSelected = false
            flagArray[tag!] = false
        }else {
            titleViews[tag!].selectBtn.isSelected = true
            flagArray[tag!] = true
        }
        let indexSet:NSIndexSet=NSIndexSet.init(index: tag!)
        tableView.reloadSections(indexSet as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    @objc fileprivate func clickBtn(_ selectBtn : UIButton)
    {
        let tag = selectBtn.tag - 2000
        if flagArray[tag] {
            titleViews[tag].selectBtn.isSelected = false
            flagArray[tag] = false
        }else {
            titleViews[tag].selectBtn.isSelected = true
            flagArray[tag] = true
        }
        let indexSet:NSIndexSet=NSIndexSet.init(index: tag)
        tableView.reloadSections(indexSet as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    @objc fileprivate func clickRepay(_ sender: UITapGestureRecognizer)
    {
        let currView = sender.view
        let tag = currView?.tag
        let detailVC = UserRepayDetailViewController()
        detailVC.setOrder(tag!)
        self.navigationController?.pushViewController(detailVC, animated: true)
        timeView.close()
    }
}

extension UserRepayInfoViewController : YearPickterViewDelegate {
    func selectClick(_ value: String) {
        if value != Year {
            Year = value
            let rightBarButton = UIBarButtonItem.init(title: Year, style: UIBarButtonItemStyle.plain, target: self, action: #selector(selectTime))
            self.navigationItem.rightBarButtonItem = rightBarButton
            self.pleaseWait()
            loadData()
        }
    }
}
