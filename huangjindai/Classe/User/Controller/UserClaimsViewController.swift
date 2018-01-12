//
//  UserClaimsViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/5.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate var orderId : Int = 0
fileprivate var maxDay : Int = 7
fileprivate var selectDay : Int = 7
fileprivate var selectZhekou : Double = 0

//债权信息
fileprivate var money : Double = 0
fileprivate var payInterst : Double = 0
fileprivate var isFee : Bool = false
fileprivate var feeRate : Double = 0

fileprivate let model = UserAccountModel()
fileprivate let userData = UserDefaults.standard.dictionary(forKey: "user")!

class UserClaimsViewController: UIViewController,UITextFieldDelegate {

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
        collectionView.contentSize = CGSize(width: kMobileW, height: 600)
        collectionView.isUserInteractionEnabled = true
        //添加手势
        let collTag = UITapGestureRecognizer(target: self, action: #selector(clickView))
        collectionView.addGestureRecognizer(collTag)
        return collectionView
    }()
    
    fileprivate lazy var claimsView : ClaimsView = { [weak self] in
        let claimsView = ClaimsView.claimsView()
        claimsView.frame = CGRect(x: 0, y: 0, width: kMobileW, height: 600)
        claimsView.day.isUserInteractionEnabled = true
        let dayTag = UITapGestureRecognizer(target: self, action: #selector(dayClick))
        claimsView.day.addGestureRecognizer(dayTag)
        claimsView.zhekou.isUserInteractionEnabled = true
        let zhekouTag = UITapGestureRecognizer(target: self, action: #selector(zhekouClick))
        claimsView.zhekou.addGestureRecognizer(zhekouTag)
        claimsView.zrmoney.delegate = self
        claimsView.claimsBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        return claimsView
    }()
    
    //请求等待转盘
    fileprivate lazy var loadingView : UIActivityIndicatorView = {
        let Loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        Loading.frame = CGRect(x: 25, y: 10, width: 30, height: 30)
        return Loading
    }()
    
    fileprivate lazy var timeView : YearPickterView = { [weak self] in
        let frame = CGRect(x: 0, y: kMobileH - 200, width: kMobileW, height: 200)
        let selectDay: Int = maxDay
        let timeview = YearPickterView.init(frame: frame,min: 1,max: maxDay,select: selectDay)
        timeview.delegate = self
        return timeview
    }()
    
    fileprivate lazy var zhekouView : ZekouSelectView = {
        let frame = CGRect(x: 0, y: kMobileH - 200, width: kMobileW, height: 200)
        let zhekou = ZekouSelectView.init(frame: frame,selectZhekou)
        zhekou.delegate = self as ZekouSelectViewDelegate?
        return zhekou
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(collectionView)
        collectionView.addSubview(claimsView)
        setBtn()
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
    
    //结束编辑时收起键盘，点击空白处
    @objc fileprivate func clickView() {
        self.view.endEditing(true)
    }
    
    func setOrder(_ ordId:Int)
    {
        orderId = ordId
    }
    
    fileprivate func setBtn()
    {
        self.title = "债权转让"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc fileprivate func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var jine = claimsView.zrmoney.text ?? "0"
        let ran = jine.components(separatedBy: ".")
        if ran.count > 1 && string == "."{
            return false
        }
        if ran.count == 2 && string != "" {
            if ran[1].count >= 2 {
                return false
            }
        }
        if range.location == 0 && string == "." {
            return false
        }
        if range.location == 1 && jine == "0" && string != "." {
            return false
        }
        switch string {
        case "0","1","2","3","4","5","6","7","8","9","",".":
            jine = jine + string
            if Double(jine)! > money {
                claimsView.zrmoney.text = "\(money)"
                countMoney("\(money)")
                return false
            }
            countMoney(jine)
            return true
        default:
            return false
        }
    }
    
    fileprivate func countMoney(_ strMoney : String)
    {
        
        let ran = strMoney.components(separatedBy: ".")
        var zrMoney = strMoney
        if ran.count == 2 && ran[1].count == 0{
            zrMoney = ran[0]
        }
        let zrMoneyDoubel = Double(zrMoney) ?? 0
        if zrMoneyDoubel > 0 {
            let zhekou = claimsView.zhekou.text ?? "100"
            let zhekouDoubel = Double(zhekou)
            let lixi = floor(payInterst/money*zrMoneyDoubel * 100) / 100.00
            let jiazhi = lixi + zrMoneyDoubel
            claimsView.jiazhi.text = "\(jiazhi)元"
            
            var endMoney = floor(zrMoneyDoubel*zhekouDoubel!)/100.00 + lixi
            var fee : Double = 0
            if isFee {
                fee = floor(zrMoneyDoubel*feeRate*100) / 100.00
            }
            endMoney = endMoney - fee
            claimsView.shishou.text = "\(endMoney)元"
            claimsView.feeMoney.text = "\(fee)元"
        }
    }
    
    fileprivate func loadData() {
        let userId = userData["userId"] ?? ""
        model.getClaimsInfo(params: ["userId" : userId,"orderId" : orderId], success: { (retrunData) in
            if retrunData["code"].intValue == 1 {
                let result = retrunData["data"]["info"]
                self.claimsView.setDealName(result["dealName"].stringValue)
                self.claimsView.month.text = "\(result["dealLimit"].doubleValue)个月"
                self.claimsView.setRate(result["rate"].doubleValue, result["rebate"].doubleValue)
                self.claimsView.jindu.text = "\(result["jindu"].stringValue)"
                self.claimsView.money.text = "\(result["money"].doubleValue)元"
                maxDay = result["term"].intValue
                selectDay = result["term"].intValue
                payInterst = result["payInterst"].doubleValue
                money = result["money"].doubleValue
                
                let fee = retrunData["data"]["fee"]
                isFee = fee["isFee"].boolValue
                feeRate = fee["rate"].doubleValue
                self.claimsView.setTishi(retrunData["data"]["tishi"])
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
    
}


extension UserClaimsViewController {
    @objc fileprivate func dayClick()
    {
        view.addSubview(timeView)
        self.view.endEditing(true)
        zhekouView.close()
    }
    
    @objc fileprivate func zhekouClick()
    {
        view.addSubview(zhekouView)
        self.view.endEditing(true)
        timeView.close()
    }
    
    @objc fileprivate func clickBtn()
    {
        let money = claimsView.zrmoney.text ?? "0"
        if money.count == 0 || Double(money)! <= 0 {
            AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"请输入正确的转让金额！")
        }else {
            claimsView.claimsBtn.backgroundColor = UIColor(r: 204, g: 204, b: 204)
            claimsView.claimsBtn.removeTarget(self, action: #selector(clickBtn), for: .touchUpInside)
            claimsView.claimsBtn.setTitle("提交中...", for: .normal)
            //添加加载旋转图
            claimsView.claimsBtn.addSubview(loadingView)
            loadingView.startAnimating()
            //请求数据
            let discount = claimsView.zhekou.text ?? "100"
            let day = claimsView.day.text ?? "1天"
            //截取数字部分
            let lenth = day.count - 1
            let start = day.index(day.startIndex, offsetBy: 0)
            let end = day.index(start, offsetBy: lenth)
            let dayNum = day[start..<end]
            let dealOrderId = orderId
            let userId = userData["userId"] ?? ""
            let params = ["money" : money, "discount" : discount, "day" : dayNum, "dealOrderId" : dealOrderId, "userId" : userId]
            model.doClaims(params: params, success: { (success) in
                if success["code"].intValue == 1 {
                    let VC = UserClaimsListViewController()
                    self.navigationController?.pushViewController(VC, animated: true)
                }else {
                    if success["code"].intValue == 2 {
                        self.notLogin()
                    }else {
                        self.loadingView.removeFromSuperview()
                        self.claimsView.claimsBtn.backgroundColor = UIColor(r: 2, g: 158, b: 2)
                        self.claimsView.claimsBtn.setTitle("确定转让", for: .normal)
                        self.claimsView.claimsBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
                        AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:success["msg"].stringValue)
                    }
                }
            }) { (error) in
                self.loadingView.removeFromSuperview()
                self.claimsView.claimsBtn.backgroundColor = UIColor(r: 2, g: 158, b: 2)
                self.claimsView.claimsBtn.setTitle("确定转让", for: .normal)
                self.claimsView.claimsBtn.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
                AlertViewManager.shareManager.showWith(type: AlertViewType(rawValue: 1)!, title:"网络请求失败！")
            }
        }
    }
}

extension UserClaimsViewController : YearPickterViewDelegate {
    func selectClick(_ value: String) {
        let select = Int(value)
        if select != selectDay {
            selectDay = select!
        }
        claimsView.day.text = "\(selectDay)天"
    }
}

extension UserClaimsViewController : ZekouSelectViewDelegate {
    func numSelectClick(_ value: String) {
        claimsView.zhekou.text = value
        countMoney(claimsView.zrmoney.text ?? "0")
    }
}
