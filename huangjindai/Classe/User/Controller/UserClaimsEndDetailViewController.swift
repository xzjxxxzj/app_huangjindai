//
//  UserClaimsEndDetailViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/8.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//
import UIKit
fileprivate var claimsId : Int = 0
fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

class UserClaimsEndDetailViewController: UIViewController {
    
    fileprivate lazy var collectionView : UICollectionView = {
        // 1.创建layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        // 2.创建UICollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:kStatusH + kHeardH - kHotH, width:kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH), collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.backgroundColor = UIColor.white
        collectionView.contentSize = CGSize(width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        return collectionView
    }()
    
    fileprivate lazy var claimsView : UserClaimsEndInfoView = { [weak self] in
        let claimsView = UserClaimsEndInfoView.userClaimsEndInfoView()
        claimsView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: 470)
        return claimsView
        }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 10, width: 30, height: 30)
        return Loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        setBtn()
        view.addSubview(collectionView)
        collectionView.addSubview(claimsView)
        loadData()
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
    
    func setClaimsId(_ id:Int)
    {
        claimsId = id
    }
    
    fileprivate func setBtn()
    {
        self.title = "债权转让"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func loadData() {
        let userId = userData["userId"] ?? ""
        model.getClaimsIngInfo(params: ["userId" : userId,"claimsId" : claimsId,"showList" : 1], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                let result = retrunData["data"]["info"]
                self.claimsView.setDealName(result["dealName"].stringValue)
                self.claimsView.month.text = "\(result["dealLimit"].doubleValue)个月"
                self.claimsView.setRate(result["rate"].doubleValue, result["rebate"].doubleValue)
                self.claimsView.jindu.text = result["jindu"].stringValue
                self.claimsView.zrMoney.text = "\(result["saleMoney"].doubleValue)元"
                self.claimsView.zhekou.text = "\(result["rates"].doubleValue/10)"
                self.claimsView.fee.text = "\(result["fee"].doubleValue)元"
                self.claimsView.time.text = result["createTime"].stringValue
                self.claimsView.shishouMoney.text = result["shishou"].stringValue
                self.claimsView.zcMoney.text = result["outMoney"].stringValue
                self.claimsView.setList(retrunData["data"]["list"])
                let H = 470 + retrunData["data"]["list"].count * 40
                self.collectionView.contentSize = CGSize(width: kMobileW, height: CGFloat(H))
            }else if retrunData["code"].intValue == 2 {
                self.notLogin()
            }
        }) { (error) in
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
        }
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
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
