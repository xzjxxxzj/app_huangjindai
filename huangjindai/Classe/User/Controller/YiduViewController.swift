//
//  YiduViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/4.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import MJRefresh

class YiduViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    fileprivate var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame:CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height), style:UITableViewStyle.plain)
        
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        
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
        return 10
    }
    
    //tableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellId)
        }
        
        cell?.textLabel?.text = "标题"
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            //删除数据源当前的数据
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
}

extension YiduViewController {
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

