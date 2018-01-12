//
//  HeardViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/19.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
fileprivate var controller : UIViewController?
//消息点击代理
protocol msgClickDelete : class {
    func msgClick()
}

class HeardViewController : UIViewController {
    
    weak var delegate : msgClickDelete?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HeardViewController {
    
    func heardBnt(UIcontroller : UIViewController) {
        controller = UIcontroller
        //设置头部左侧LOGO
        UIcontroller.navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "logo", target: self, action: #selector(leftClick))
        //设置头部右侧
        let sizi = CGSize(width: 40, height: 44)
        let userMsgBar = UIBarButtonItem(imageName: "emailIco", target: self, action: #selector(userMsg), highImageName: "emailIco", size: sizi)
        
        UIcontroller.navigationItem.rightBarButtonItems = [userMsgBar]
    }
}

extension HeardViewController {
    
    @objc fileprivate func leftClick()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        controller?.navigationController?.present(vc , animated: true)
    }
    
    @objc fileprivate func userMsg()
    {
        delegate?.msgClick()
    }
}
