//
//  SetLockViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/14.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class SetLockViewController: UIViewController {

    
    fileprivate lazy var lockView : UIView = {
        
        let checkLock = LockSettingView()
        checkLock.backgroundColor = UIColor.white
        checkLock.frame = CGRect(x: 0, y: 0, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        checkLock.delegate = self
        return checkLock
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        let contenView = UIView()
        contenView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        contenView.backgroundColor = UIColor.white
        contenView.addSubview(lockView)
        view.addSubview(contenView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    fileprivate func setBtn()
    {
        self.title = "重置手势密码"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SetLockViewController : LockSettingViewDelegate {
    func successSet() {
        isShowLock = false
        UserDefaults.standard.removeObject(forKey: "errorNumLock")
        let Vc = UserViewController()
        self.navigationController?.pushViewController(Vc, animated: true)
    }
}
