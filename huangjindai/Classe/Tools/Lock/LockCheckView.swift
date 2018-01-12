//
//  LockCheckView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyGuesturesView
//密码
private let userPassWord = UserDefaults.standard.string(forKey: "userLock")
//可以尝试的次数
private let tryNum = 5
//错误总次数
private var errorNum = UserDefaults.standard.integer(forKey: "errorNumLock")
// MARK: - 设置手势密码

//解锁代理
protocol LockCheckViewDelegate : class {
    func lockCheck()
    func resetLock()
}

class LockCheckView: UIView ,GHGPViewDelegate {
    
    weak var delegate : LockCheckViewDelegate?
    
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
        let forgetLabel = UILabel(frame: CGRect(x: GH_S_WIDTH/2 - 50,
                                                y: 0,
                                                width : 100,
                                                height: 40)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgImgView.frame = frame
        
        gpView.center = self.center
        
        gpvView.centerX = self.centerX
        noticeLabel.y =  gpView.y - GH_Scale(40)
        gpvView.y = noticeLabel.y - GH_Scale(60)
        
        forgetLabel.y = GH_S_N_HEIGHT - gpvView.y - 30
    }
    
    // MARK: - do anything you want
    func didEndSwipeWithPassword(gpView: GHGPasswordView, password: String) -> NodeState {
        
        gpvView.password = password
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
        }else{
            UserDefaults.standard.removeObject(forKey: "errorNumLock")
            self.removeFromSuperview()
            delegate?.lockCheck()
            return .normal
        }
    }
    
    @objc fileprivate func forgetClick(_ tapGest : UITapGestureRecognizer)
    {
        delegate?.resetLock()
    }
}
