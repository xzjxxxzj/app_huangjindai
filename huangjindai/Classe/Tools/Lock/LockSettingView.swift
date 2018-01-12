//
//  LockSettingView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyGuesturesView

private var onePassWord = ""
// MARK: - 设置手势密码

protocol LockSettingViewDelegate : class {
    func successSet()
}
class LockSettingView: UIView ,GHGPViewDelegate {
    
    weak var delegate : LockSettingViewDelegate?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgImgView.frame = frame
        
        gpView.center = self.center
        
        gpvView.centerX = self.centerX
        noticeLabel.y =  gpView.y - GH_Scale(40)
        gpvView.y = noticeLabel.y - GH_Scale(60)
    }
    
    // MARK: - do anything you want
    func didEndSwipeWithPassword(gpView: GHGPasswordView, password: String) -> NodeState {
        
        gpvView.password = password
        if onePassWord == "" {
            if password.count < 4 {
                noticeLabel.text = "密码长度不能低于4位"
                noticeLabel.textColor = .red
                GH_Util.shakerView(noticeLabel)
                return .warning
            }
            noticeLabel.textColor = .green
            noticeLabel.text = "再次绘制解锁图案"
            onePassWord = password
            return .normal
        } else if onePassWord != password {
            noticeLabel.textColor = .red
            noticeLabel.text = "与上次手势密码不一致，请重新绘制"
            onePassWord = ""
            GH_Util.shakerView(noticeLabel)
            return .warning
        } else {
            isShowLock = false
            noticeLabel.text = "设置成功"
            onePassWord = ""
            self.successNotice("设置成功!", textcolor: UIColor.green)
            UserDefaults.standard.set(password, forKey: "userLock")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.removeFromSuperview()
            })
            delegate?.successSet()
            return .normal
        }
    }
    
}
