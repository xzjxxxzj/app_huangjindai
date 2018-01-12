//
//  LockViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/14.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import LocalAuthentication

class LockViewController: UIViewController {
    
    fileprivate lazy var lockView : UIView = {
        
        let checkLock = LockCheckView()
        checkLock.backgroundColor = UIColor.white
        checkLock.frame = CGRect(x: 0, y: 0, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        checkLock.delegate = self
        return checkLock
    }()
    
    fileprivate lazy var zhiwenView : UIView = {
        let zhiwenView = UIView()
        zhiwenView.backgroundColor = UIColor.clear
        zhiwenView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        let tupianView = UIView(frame: CGRect(x: kMobileW/2 - 90, y: (kMobileH - kStatusH - kHeardH + kHotH)/2 - 150, width: 180, height: 180))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 150))
        imageView.image = UIImage(named: "zhiwen")
        tupianView.addSubview(imageView)
        let textlabel = UILabel(frame: CGRect(x: 0, y: 160, width: 180, height: 20))
        textlabel.text = "点击进行指纹解锁"
        textlabel.font = UIFont.systemFont(ofSize: 13)
        textlabel.textAlignment = NSTextAlignment.center
        textlabel.textColor = UIColor(r: 136, g: 210, b: 247)
        tupianView.addSubview(textlabel)
        tupianView.isUserInteractionEnabled = true
        let tupTag = UITapGestureRecognizer()
        tupTag.addTarget(self, action: #selector(zhiwenCheck))
        tupianView.addGestureRecognizer(tupTag)
        zhiwenView.addSubview(tupianView)
        return zhiwenView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtn()
        view.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        let contenView = UIView()
        contenView.frame = CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH)
        contenView.backgroundColor = UIColor.white
        let isTouch = UserDefaults.standard.bool(forKey: "userTouch")
        let isLock =  UserDefaults.standard.string(forKey: "userLock")
        if isTouch && isLock == nil{
             contenView.addSubview(zhiwenView)
        }
        if isLock != nil {
            contenView.addSubview(lockView)
        }
        view.addSubview(contenView)
        if isTouch {
            zhiwenCheck()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    fileprivate func setBtn()
    {
        self.title = "解锁"
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    fileprivate func successBack()
    {
        isShowLock = false
        let userVc = UserViewController()
        self.navigationController?.pushViewController(userVc, animated: true)
    }
    
    @objc fileprivate func zhiwenCheck()
    {
        let context = LAContext()
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请验证指纹", reply: { (isSuccess, err) in
            OperationQueue.main.addOperation({
                guard isSuccess == true,err == nil else {
                    let laerror = err as! LAError
                    if #available(iOS 9.0, *) {
                        switch laerror.code {
                        case LAError.touchIDLockout :
                            let alertController = UIAlertController(title: "Touch ID被锁定", message: "Touch ID被锁定,重新锁屏再开启即可", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title : "取消",style: .cancel, handler:nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        default:
                            break
                        }
                    } else {
                        return
                    }
                    return
                }
                //成功
                self.successBack()
            })
        })
    }
}

extension LockViewController {
    @objc fileprivate func back()
    {
        let mainVc = MainViewController()
        self.navigationController?.present(mainVc, animated: true, completion: nil)
    }
}

extension LockViewController : LockCheckViewDelegate {
    func resetLock() {
        let resetView = ResetLockViewController()
        resetView.setNextView(nextViewC: SetLockViewController())
        self.navigationController?.pushViewController(resetView, animated: true)
    }
    
    func lockCheck() {
        successBack()
    }
}
