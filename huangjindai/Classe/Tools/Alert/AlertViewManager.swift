//
//  AlertViewManager.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

typealias SelectedAlertView = ()->Void


class AlertViewManager: NSObject
{
    var hideAlertView:SelectedAlertView?
    var dismissTime:Int?
    var alertView:AlertView?
    var dismissTimer:Timer?
    
    var dismissTimeEnd:Int = 0
    
    //MARK:单例模式,在方法内定义静态变量
    static var shareManager:AlertViewManager
    {
        struct Static
        {
            static let shareManagerToken:AlertViewManager = AlertViewManager()
        }
        return Static.shareManagerToken;
    }
    private override init()
    {
        self.alertView = AlertView.init(frame: ViewRect)
        self.alertView?.isUserInteractionEnabled = true
    }
    
    
    
    func showWith(type:AlertViewType ,title:String, time: Int = 2 ) -> Void
    {
        self.releaseTimer()
        self.dismissAlertWith(time: time)
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self.alertView!)
            self.alertView?.topAlertViewTypewWith(type: type, title: title)
            self.alertView?.show()
            
            let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(AlertViewManager.tapAlertView))
            tap.cancelsTouchesInView = false
            self.alertView?.addGestureRecognizer(tap)
        }
    }
    
    //MARK:销毁定时器
    func releaseTimer()
    {
        self.dismissTime = 0
        self.dismissTimeEnd = 0
        self.dismissTimer?.invalidate()
        self.dismissTimer = nil
    }
    
    //MARK:立即通过tap手势移除弹窗
    @objc func tapAlertView()
    {
        self.alertView?.dismiss()
        self.releaseTimer()
    }
    
    //MARK:延时移除弹窗
    func dismissAlertWith(time:Int)
    {
        self.dismissTime = time
        if self.dismissTimer != nil
        {
            return
        }
        self.dismissTimer = Timer.scheduledTimer(timeInterval: 1,
                                                 target: self,
                                                 selector: #selector(AlertViewManager.dismisAlertWith(timer:)),
                                                 userInfo: nil,
                                                 repeats: true)
    }
    @objc func dismisAlertWith(timer:Timer)
    {
        if self.dismissTimeEnd > self.dismissTime!
        {
            self.releaseTimer()
            self.alertView?.dismiss()
        }
        self.dismissTimeEnd += 1
        
    }
    
    //MARK:立即移除弹窗，同时销毁定时器
    func dismissAlertImmediately()
    {
        self.releaseTimer()
        self.alertView?.dismiss()
    }
    
    //MARK:block监听，传递信息
    func didSelectedToHideAlertView(hideAlertView:@escaping SelectedAlertView) -> Void
    {
        self.hideAlertView = hideAlertView
    }
    
    
}
