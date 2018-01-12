//
//  UserMsgDetailViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/6.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate var msgData : JSON = []

class UserMsgDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBtn()
        let contentView = UIWebView()
        let contentTxt = msgData["content"].stringValue
        let htmlString = "<html><head><style type=\"text/css\">body {margin:30px 30px 0 30px;font-size: 12;line-height:30px;}p:nth-child(2){text-indent:25px}</style></head><body>\(contentTxt)</body></html>"
        contentView.loadHTMLString(htmlString, baseURL: nil)
        view.addSubview(contentView)
        contentView.frame = CGRect(x: 0, y:0, width: kMobileW, height: kMobileH)
        contentView.scrollView.bounces = false
        view.backgroundColor = UIColor(r: 204, g: 204, b: 204)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setMsgData(data : JSON){
        msgData = data
    }
    
    fileprivate func setBtn()
    {
        self.navigationController?.navigationBar.backgroundColor = UIColor(r: 204, g: 204, b: 204)
        self.title = msgData["title"].stringValue
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController!.popViewController(animated: true)
    }
}
