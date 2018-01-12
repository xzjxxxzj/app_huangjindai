//
//  UserMsgControllerView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/4.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON

fileprivate var isCanEdit = false
fileprivate let footH : CGFloat = 52

fileprivate let model = UserMsgModel()
//记录页数
fileprivate var page : Int = 1
//记录未读行数
fileprivate var noRead : [String: Int] = [:]
//记录最后一行行数
fileprivate var lastPath : Int = 0
fileprivate let userInfo : [String:Any] = UserDefaults.standard.dictionary(forKey: "user")!
//记录所有的消息ID
fileprivate var msgIds : String = ""

class UserMsgControllerView : UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    //数据
    var dataSource:NSMutableArray = []
    
    fileprivate lazy var contentView : UIView = {
        let contentView = UIView(frame : CGRect(x: 0, y: 0, width: kMobileW, height: kMobileH))
        contentView.backgroundColor = UIColor.white
        return contentView
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView (frame: CGRect(x: 0, y: 0, width: kMobileW, height: kMobileH ), style:UITableViewStyle.plain)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(r: 204, g: 204, b: 204)
        tableView.separatorInset = UIEdgeInsetsMake(2, 2, 2, 2)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        page = 1
        setBtn()
        self.view.addSubview(contentView)
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpRefresh()
        loadData(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    fileprivate func setBtn()
    {
        self.title = "消息中心"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
        let rightBarButton = UIBarButtonItem.init(image: UIImage.init(named: "settingIco"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(settings))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    //内容编写
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: cellId)
        
        //左边标题
        //消息颜色
        var textColor = UIColor(r: 143, g: 149, b: 153)
        let tableData: JSON = self.dataSource[indexPath.row] as! JSON
        if tableData["isRead"].intValue == 0 {
            textColor = UIColor.blue
        }
        cell?.textLabel?.text = "\(tableData["title"].stringValue)"
        cell?.textLabel?.textColor = textColor
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 12)
        //右边时间
        cell?.detailTextLabel?.text = "\(tableData["createTime"].stringValue)"
        cell?.detailTextLabel?.textColor = textColor
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        cell?.detailTextLabel?.textAlignment = NSTextAlignment.right
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        return cell!
    }
    
    //监听删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let tableData: JSON = self.dataSource[indexPath.row] as! JSON
            
            model.deleteMsg(params: ["userId":userInfo["userId"] ?? "", "msgId" : tableData["msgId"].stringValue], success: { (result) in
                if (noRead["\(indexPath.row)"] != nil) {
                    noRead.removeValue(forKey: "\(indexPath.row)")
                }
                //删除数据源当前的数据
                self.dataSource.removeObject(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }, failture: { (error) in
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        var data: JSON = self.dataSource[indexPath.row] as! JSON
        self.hidesBottomBarWhenPushed = true
        let detailView = UserMsgDetailViewController()
        detailView.setMsgData(data: data)
        self.navigationController!.pushViewController(detailView, animated: true)
        
        if data["isRead"].intValue == 0 {
            model.setRead(params: ["msgId" : data["msgId"].intValue], success: { (result) in
                if result["code"].intValue == 1 {
                    data["isRead"] = 1
                    noRead.removeValue(forKey: "\(indexPath.row)")
                    self.dataSource.removeObject(at: indexPath.row)
                    self.dataSource.insert(data, at: indexPath.row)
                    tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor(r: 143, g: 149, b: 153)
                    tableView.cellForRow(at: indexPath)?.detailTextLabel?.textColor = UIColor(r: 143, g: 149, b: 153)
                }
            }, failture: { (error) in
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension UserMsgControllerView {
    fileprivate func setUpRefresh() {
        
        // MARK: - 下拉
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self]() -> Void in
            page = 1
            self?.loadData(true)
            self?.tableView.mj_footer.isHidden = false
            self?.tableView.mj_footer.resetNoMoreData()
        })
        // MARK: - 上拉
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData()
        })
    }
    
    fileprivate func loadData(_ isDown : Bool = false) {
        model.requestData(params: ["userId" : userInfo["userId"] ?? "","page" : page], success: { (retrunData) in
            self.tableView.mj_header.endRefreshing()
            if retrunData["code"].intValue == 1 {
                page += 1
                //如果是下拉则清空之前数据
                if isDown {
                    noRead = [:]
                    lastPath = 0
                    self.dataSource = []
                    msgIds = ""
                }
                if retrunData["data"].isEmpty {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        self.tableView.mj_footer.isHidden = true
                    })
                }else {
                    //有数据
                    self.tableView.mj_footer.endRefreshing()
                    for (_, data) : (String,JSON) in retrunData["data"] {
                        if data["isRead"].intValue == 0 {
                            noRead["\(lastPath)"] = lastPath
                        }
                        msgIds = "\(msgIds),\(data["msgId"].stringValue)"
                        lastPath += 1
                        self.dataSource.insert(data, at: self.dataSource.count)
                    }
                }
                self.tableView.reloadData()
            } else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
}

extension UserMsgControllerView {
    @objc fileprivate func settings()
    {
        if !isCanEdit {
            tableView.isEditing = true
            isCanEdit = true
            self.navigationController?.setToolbarHidden(false, animated: true)
            let btnyidu = UIBarButtonItem(title: "全部已读", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setAllReal))
            let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let btndelete = UIBarButtonItem(title: "全部删除", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setAllDel))
            self.setToolbarItems([btnyidu,flexible,btndelete], animated: true)
            self.navigationController?.toolbar.frame = CGRect(x: 0, y: 0, width: kMobileW, height: kTabbarH)
        } else {
            tableView.isEditing = false
            isCanEdit = false
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    @objc fileprivate func setAllReal()
    {
        if !noRead.isEmpty {
            let alertController = UIAlertController(title: "系统提示", message: "您确定设置所有未读消息为已读吗？该操作无法撤回", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title : "取消",style: .cancel, handler:nil)
            let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
                self.allReadOk()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func allReadOk()
    {
        model.setAllRead(params: ["userId" : userInfo["userId"] ?? ""], success: { (result) in
            if result["code"].intValue == 1 {
                for (_,path) in noRead {
                    var data: JSON = self.dataSource[path] as! JSON
                    data["isRead"] = 1
                    self.dataSource.removeObject(at: path)
                    self.dataSource.insert(data, at: path)
                    let indexPath = IndexPath(row: path, section: 0)
                    self.tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor(r: 143, g: 149, b: 153)
                    self.tableView.cellForRow(at: indexPath)?.detailTextLabel?.textColor = UIColor(r: 143, g: 149, b: 153)
                }
                noRead = [:]
                lastPath = 0
                self.navigationController?.setToolbarHidden(true, animated: false)
                isCanEdit = false
                self.tableView.isEditing = false
            } else {
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:result["msg"].stringValue)
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    @objc fileprivate func setAllDel()
    {
        if msgIds != "" {
            let alertController = UIAlertController(title: "系统提示", message: "您确定删除当前显示的所有消息吗？该操作无法撤回", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title : "取消",style: .cancel, handler:nil)
            let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
                self.allDelOk()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func allDelOk()
    {
        let ids = msgIds.trimmingCharacters(in: CharacterSet(charactersIn : ","))
        model.setAllDelete(params: ["userId" : userInfo["userId"] ?? "","msgIds" : ids], success: { (result) in
            if result["code"].intValue == 1 {
                page = 1
                self.loadData(true)
                self.navigationController?.setToolbarHidden(true, animated: false)
                isCanEdit = false
                self.tableView.isEditing = false
            } else {
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:result["msg"].stringValue)
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
    }
    
    @objc fileprivate func back()
    {
        //防止进入内容页面以后退出底部被隐藏，先显示底部
        self.navigationController?.setToolbarHidden(true, animated: false)
        isCanEdit = false
        self.navigationController!.popViewController(animated: true)
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
