//
//  LockResetView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyGuesturesView
//密码
private let userPassWord = UserDefaults.standard.string(forKey: "userLock")
//是否输入了正确的密码
private var isTruePassWord = false
//可以尝试的次数
private let tryNum = 5
//第一次密码
private var onePassWord = ""
//错误总次数
private var errorNum = UserDefaults.standard.integer(forKey: "errorNumLock")
// MARK: - 设置手势密码
class LockResetView: UIView ,GHGPViewDelegate {
    
    let gpvW = GH_S_WIDTH - GH_Scale(34) * 2
    // MARK: - gpView
    lazy var gpView : GHGPasswordView = {
        let gpView = GHGPasswordView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width : self.gpvW,
                                                   height: self.gpvW)
        )
        gpView.gpviewDelegate = self
        self.addSubview(gpView)
        return gpView
    }()
    
    // MARK: - gpvView
    lazy var gpvView : GHGuesturesViewerView = {
        let gpvView = GHGuesturesViewerView(frame: CGRect(x: 0,
                                                          y: 0,
                                                          width : GH_Scale(40),
                                                          height: GH_Scale(40))
        )
        self.addSubview(gpvView)
        return gpvView
    }()
    
    // MARK: - bgImgView
    lazy var bgImgView : UIImageView = {
        let bgImgView = UIImageView()
        bgImgView.image = UIImage(named: "guest")
        bgImgView.isUserInteractionEnabled = true
        self.addSubview(bgImgView)
        return bgImgView
    }()
    
    // MARK: - noticeLabel
    lazy var noticeLabel : UILabel = {
        let noticeLabel = UILabel(frame: CGRect(x: 0,
                                                y: 0,
                                                width : GH_S_WIDTH,
                                                height: GH_Scale(20))
        )
        noticeLabel.textAlignment = .center
        noticeLabel.textColor = .green
        noticeLabel.font = GH_FONT(16)
        noticeLabel.text = "请绘制解锁图案"
        self.addSubview(noticeLabel)
        return noticeLabel
    }()
    
    //忘记密码
    lazy var forgetLabel : UILabel = {
        let forgetLabel = UILabel(frame: CGRect(x: GH_S_WIDTH/12,
                                                y: 0,
                                                width : 100,
                                                height: 10)
        )
        forgetLabel.textAlignment = .center
        forgetLabel.textColor = UIColor.darkGray
        forgetLabel.font = GH_FONT(14)
        forgetLabel.text = "忘记手势密码"
        self.addSubview(forgetLabel)
        
        //开启lable交互
        forgetLabel.isUserInteractionEnabled = true
        let labelClick = UITapGestureRecognizer(target: self, action: #selector(self.forgetClick(_:)))
        forgetLabel.addGestureRecognizer(labelClick)
        
        return forgetLabel
    }()
    //账号登陆
    lazy var loginLabel : UILabel = {
        let loginLabel = UILabel(frame: CGRect(x: GH_S_WIDTH - GH_S_WIDTH/12 - 60,
                                               y: 0,
                                               width : 60,
                                               height: 10)
        )
        loginLabel.textAlignment = .center
        loginLabel.textColor = .darkGray
        loginLabel.font = GH_FONT(14)
        loginLabel.text = "切换账户"
        self.addSubview(loginLabel)
        
        //开启lable交互
        loginLabel.isUserInteractionEnabled = true
        let labelClick = UITapGestureRecognizer(target: self, action: #selector(self.loginClick(_:)))
        loginLabel.addGestureRecognizer(labelClick)
        
        return loginLabel
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgImgView.frame = frame
        
        gpView.center = self.center
        
        gpvView.centerX = self.centerX
        noticeLabel.y =  gpView.y - GH_Scale(40)
        gpvView.y = noticeLabel.y - GH_Scale(60)
        
        forgetLabel.y = GH_S_N_HEIGHT - gpvView.y
        loginLabel.y = GH_S_N_HEIGHT - gpvView.y
    }
    
    // MARK: - do anything you want
    func didEndSwipeWithPassword(gpView: GHGPasswordView, password: String) -> NodeState {
        UserDefaults.standard.removeObject(forKey: "errorNumLock")
        gpvView.password = password
        if !isTruePassWord {
            if userPassWord != password {
                errorNum = errorNum + 1
                if(errorNum >= tryNum) {
                    //如果错误次数达到最大
                    noticeLabel.text = "密码错误，请使用找回密码功能"
                    noticeLabel.textColor = .red
                    GH_Util.shakerView(noticeLabel)
                    return .warning
                }else {
                    UserDefaults.standard.set( errorNum, forKey: "errorNumLock")
                    noticeLabel.text = "密码错误！您还可以尝试\(tryNum - errorNum)次"
                    noticeLabel.textColor = .red
                    GH_Util.shakerView(noticeLabel)
                    return .warning
                }
            } else {
                isTruePassWord = true
                UserDefaults.standard.removeObject(forKey: "errorNumLock")
                noticeLabel.textColor = .green
                noticeLabel.text = "请绘制新的解锁密码"
                return .normal
            }
        }else{
            if onePassWord == "" {
                if password.count < 4 {
                    noticeLabel.text = "密码长度不能低于4位"
                    noticeLabel.textColor = .red
                    GH_Util.shakerView(noticeLabel)
                    return .warning
                }
                noticeLabel.text = "再次绘制解锁图案"
                noticeLabel.textColor = .green
                onePassWord = password
                return .normal
            } else if onePassWord != password {
                noticeLabel.textColor = .red
                noticeLabel.text = "与上次手势密码不一致，请重新绘制"
                onePassWord = ""
                GH_Util.shakerView(noticeLabel)
                return .warning
            } else {
                noticeLabel.text = "设置成功"
                onePassWord = ""
                isTruePassWord = false
                self.successNotice("设置成功!", textcolor: UIColor.green)
                UserDefaults.standard.set(password, forKey: "userLock")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.removeFromSuperview()
                })
                return .normal
            }
        }
    }
    
    @objc fileprivate func forgetClick(_ tapGest : UITapGestureRecognizer)
    {
        
    }
    
    @objc fileprivate func loginClick(_ tapGest : UITapGestureRecognizer)
    {
        
    }
}
