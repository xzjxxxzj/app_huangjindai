//
//  UserInvestInfoViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/1.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class UserInvestInfoViewController: UIViewController {

    //添加子页面
    fileprivate lazy var pageTitleView : PageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y: kHeardH + kStatusH - kHotH, width: kMobileW , height: kTitlesH)
        let view = PageTitleView(frame: titleFrame, titles: ["回款中","融资中","已结束"], isScroll: false)
        view.delegate = self
        return view
        }()
    
    //添加子内容控制器
    fileprivate lazy var childView : PageContentView = {[weak self] in
        let contentFrame = CGRect(x: 0, y: kStatusH + kHeardH + kTitlesH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH - kTitlesH + kHotH)
        var childVcs = [UIViewController]()
        childVcs.append(UserBackingInvestViewController())
        childVcs.append(UserLoadingInvestViewController())
        childVcs.append(UserEndInvestViewController())
        let childView = PageContentView(frame : contentFrame, childVcs : childVcs, parentVc : self)
        childView.delegate = self
        return childView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setBtn()
        view.addSubview(pageTitleView)
        view.addSubview(childView)
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
        self.title = "投资记录"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UserInvestInfoViewController : PageTitleViewDelegate
{
    func pageTitleView(_ titleView: PageTitleView, selectedIndex index : Int)
    {
        childView.setCurrentIndex(index)
    }
}

extension UserInvestInfoViewController : PageContentViewDelegate
{
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int)
    {
        pageTitleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}
