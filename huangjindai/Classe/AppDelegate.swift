//
//  AppDelegate.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/18.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//  启动广告页加载

import UIKit
import UserNotifications
import SwiftyJSON

private var startImages : [String] = ["start1","start2","start3"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StartVcDelegat,UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //开启消息通知
        registerAppNotificationSettings(launchOptions: launchOptions)
        
        UserDefaults.standard.set(true, forKey: "lockShow")
        //获取用户当前版本
        let infoDic = Bundle.main.infoDictionary
        let appNewVersion = infoDic?["CFBundleShortVersionString"] as? String
        updateVison(appNewVersion)
        //获取用户之前版本
        let appOldVersion = UserDefaults.standard.string(forKey: "appVersion")
        //判断用户是否是第一次进入应用或者有更新版本来加载启动页广告
        if appOldVersion == nil || appNewVersion != appOldVersion {
            UserDefaults.standard.set(appNewVersion, forKey: "appVersion")
            let model = AppModel()
            model.requestData(success: { (startImage) in
                if startImages.count > 1 {
                    startImages = startImage
                    self.setGuideVC(true)
                }
            }) { (error) in
                self.setGuideVC(false)
            }
        }
        return true
    }
    
    func setGuideVC(_ isNetWork : Bool){
        
        let guideVC:StartVC = StartVC()
        
        guideVC.delegate = self
        guideVC.setGuideImages(images: startImages, isNetWork: isNetWork)
        
        //重置主控制器
        self.window?.rootViewController = guideVC
        self.window?.makeKeyAndVisible()
    }
    
    func jumpMainVC() {
        //重置主控制器
        self.window?.rootViewController = MainViewController()
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    //程序进入后台时执行
    func applicationDidEnterBackground(_ application: UIApplication) {
        isShowLock = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let isLock =  UserDefaults.standard.string(forKey: "userLock")
        let isTouch = UserDefaults.standard.bool(forKey: "userTouch")
        if isToHome && (isLock != nil || isTouch == true){
            self.window?.rootViewController = MainViewController()
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    //状态栏发生改变时调用
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        let config = Config()
        config.setTabbar(newStatusBarFrame.height)
        config.setHotH(newStatusBarFrame.height)
    }
    
    fileprivate func registerAppNotificationSettings(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *) {
            let notifiCenter = UNUserNotificationCenter.current()
            notifiCenter.delegate = self
            let types = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
            notifiCenter.requestAuthorization(options: types) { (flag, error) in
                
            }
        } else { //iOS8,iOS9注册通知
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //设置最新的deviceToken
        UserDefaults.standard.set(deviceToken.hexString, forKey: "deviceToken")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.title)
        print(response.notification.request.content.body)
        //获取通知附加数据
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        //完成了工作
        completionHandler()
    }
    
    //版本更新提醒
    fileprivate func updateVison(_ oldVision : String?)
    {
        let vison:String = oldVision ?? ""
        //请求服务器获取新版本
        let model = AppModel()
        model.requestVision(success: { (success) in
            let newVison = success["data"]["vision"].stringValue
            if vison != newVison {
                var message : String = "您有新的版本可以跟新：\n"
                for (_,list) : (String, JSON) in success["data"]["list"] {
                    
                    message = message + "\n" + list.stringValue
                }
                let alertController = UIAlertController(title: "温馨提示", message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { (action) in
                    if success["data"]["isOut"].boolValue {
                        exit(0)
                    }
                })
                let okAction = UIAlertAction(title: "更新", style: .default) { (action) in
                    UIApplication.shared.openURL(URL(string:"https://itunes.apple.com/cn/app/ji-mu-he-zi/id790276804?ls=1&mt=8")!)
                    if success["data"]["isOut"].boolValue {
                        exit(0)
                    }
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }) { (error) in
            
        }
    }
}

extension Data {
    //将Data转换为String
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}

