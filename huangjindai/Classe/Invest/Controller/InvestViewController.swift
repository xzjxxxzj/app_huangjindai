//
//  InvestViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/23.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class InvestViewController: UIViewController {

    //添加头部
    fileprivate lazy var addHeard : HeardViewController = HeardViewController()
    
    //添加头部标题栏
    fileprivate lazy var pageTitleView : PageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW , height: kTitlesH)
        let view = PageTitleView(frame: titleFrame, titles: ["定期理财","债权转让"], isScroll: false)
        view.delegate = self
        return view
    }()
    
    //添加子内容控制器
    fileprivate lazy var childView : PageContentView = {[weak self] in
        let contentFrame = CGRect(x: 0, y: kStatusH + kHeardH + kTitlesH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH - kTitlesH - kTabbarH + kHotH)
        var childVcs = [UIViewController]()
        childVcs.append(DinqiViewController())
        childVcs.append(ZhaiquanViewController())
        let childView = PageContentView(frame : contentFrame, childVcs : childVcs, parentVc : self)
        childView.delegate = self
        return childView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setInvestUi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension InvestViewController {
    fileprivate func setInvestUi()
    {
        //设置导航栏
        addHeard.heardBnt(UIcontroller: self)
        addHeard.delegate = self
        view.addSubview(pageTitleView)
        view.addSubview(childView)
    }
}

extension InvestViewController : PageTitleViewDelegate
{
    func pageTitleView(_ titleView: PageTitleView, selectedIndex index : Int)
    {
        childView.setCurrentIndex(index)
    }
}

extension InvestViewController : PageContentViewDelegate
{
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int)
    {
        pageTitleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}

extension InvestViewController : msgClickDelete {
    func msgClick() {
        //判断用户是否登陆
        if(UserDefaults.standard.dictionary(forKey: "user") != nil) {
            self.hidesBottomBarWhenPushed = true
            let msgViewController = UserMsgControllerView()
            self.navigationController?.pushViewController(msgViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        } else {
            self.hidesBottomBarWhenPushed = true
            let loginViewController = LoginViewController()
            loginViewController.setLastView(toView: InvestViewController())
            self.navigationController?.pushViewController(loginViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }
}
