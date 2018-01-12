//
//  MainViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/18.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

//定义视图
private let barName = ["Home", "Invest", "Find", "User"]
class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加子控制器
        addBar(barName)
    }
    
    private func addBar(_ barName : [String]) {
        for name in barName {
            let getView = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController()!
            addChildViewController(getView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
