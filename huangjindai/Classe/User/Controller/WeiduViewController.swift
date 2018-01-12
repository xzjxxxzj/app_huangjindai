//
//  WeiduViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/4.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh
fileprivate var isCanEdit = false
fileprivate let contentH : CGFloat = kMobileH - kStatusH - kHeardH - kTitlesH
fileprivate var footView : UIView = UIView()

class WeiduViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    fileprivate lazy var contentView : UIView = {
        let contentView = UIView(frame : CGRect(x: 0, y: 0, width: kMobileW, height: contentH))
        contentView.backgroundColor = UIColor.white
        footView.frame = CGRect(x: 0, y: contentH - 52 , width: kMobileW, height: 52)
        footView.backgroundColor = UIColor(r: 249, g: 249, b: 249)
        let setting = UIButton(frame : CGRect(x: 15, y: 0, width: 20, height: 52))
        setting.setImage(UIImage(named : "settingIco"), for: .normal)
        setting.addTarget(self, action: #selector(settings), for: .touchUpInside)
        footView.addSubview(setting)
        contentView.addSubview(footView)
        return contentView
    }()
    
    fileprivate lazy var allReal : UIButton = {
        let allRealButton = UIButton(frame: CGRect(x: 50, y: 0, width: kMobileW/3, height: 52))
        allRealButton.setTitle("全部已读", for: .normal)
        allRealButton.setTitleColor(UIColor.blue, for: .normal)
        allRealButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        allRealButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        allRealButton.addTarget(self, action: #selector(setAllReal), for: .touchUpInside)
        return allRealButton
    }()
    
    fileprivate lazy var allDelete : UIButton = {
        let allDelete = UIButton(frame: CGRect(x: kMobileW*2/3, y: 0, width: kMobileW/3, height: 52))
        allDelete.setTitle("全部删除", for: .normal)
        allDelete.setTitleColor(UIColor.blue, for: .normal)
        allDelete.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        allDelete.addTarget(self, action: #selector(setAllDel), for: .touchUpInside)
        return allDelete
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView (frame: CGRect(x: 0, y: 0, width: kMobileW, height: contentH - 52 ), style:UITableViewStyle.plain)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(r: 204, g: 204, b: 204)
        tableView.separatorInset = UIEdgeInsetsMake(2, 2, 2, 2)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentView)
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    //内容编写
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: cellId)
        }
        //左边标题
        cell?.textLabel?.text = "标题"
        cell?.textLabel?.textColor = UIColor(r: 143, g: 149, b: 153)
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 12)
        //右边时间
        cell?.detailTextLabel?.text = "2017-11-05"
        cell?.detailTextLabel?.textColor = UIColor(r: 143, g: 149, b: 153)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        cell?.detailTextLabel?.textAlignment = NSTextAlignment.right
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        return cell!
    }
    
    //监听删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            //删除数据源当前的数据
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension WeiduViewController {
    fileprivate func setUpRefresh() {
        
        // MARK: - 下拉
        self.tableView.mj_header = MJRefreshGifHeader(refreshingBlock: { [weak self]() -> Void in
            //self?.loadData()
            self?.tableView.mj_footer.isHidden = false
            self?.tableView.mj_footer.resetNoMoreData()
            self!.tableView.mj_header.endRefreshing()
        })
        // MARK: - 上拉
        self.tableView.mj_footer = MJRefreshAutoGifFooter(refreshingBlock: {[weak self] () -> Void in
            //self?.loadDataPage()
        })
    }
}

extension WeiduViewController {
    @objc fileprivate func settings()
    {
        if !isCanEdit {
            isCanEdit = true
            let transition = CATransition()
            transition.duration = 0.2
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromBottom
            allReal.layer.add(transition, forKey: nil)
            allDelete.layer.add(transition, forKey: nil)
            footView.addSubview(allReal)
            footView.addSubview(allDelete)
        } else {
            isCanEdit = false
            allReal.removeFromSuperview()
            allDelete.removeFromSuperview()
        }
    }
    
    @objc fileprivate func setAllReal()
    {
        
    }
    
    @objc fileprivate func setAllDel()
    {
        
    }
}
