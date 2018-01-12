//
//  Config.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/18.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//
import UIKit

//屏幕宽度
let kMobileW = UIScreen.main.bounds.width

//屏幕高度
let kMobileH = UIScreen.main.bounds.height

//状态栏高度
var kStatusH : CGFloat = 20

//热点高度
var kHotH : CGFloat = 0
//头部高度
let kHeardH : CGFloat = 44

//底部高度
var kTabbarH : CGFloat = 44

//banner高度
let kBannerH : CGFloat = kMobileW*360/750

//后台运行返回时是否回到首页
var isToHome : Bool = false
//是否重新解锁
var isShowLock : Bool = true
//请求数据地址
let kUrl : String = "http://m.guozhong.com/"

var tabIndex : Int = 0

let kTitlesH : CGFloat = kMobileH/13

class Config {
    func setTabbar(_ statusH : CGFloat) {
        kStatusH = statusH
        if kStatusH == 44 {
            kTabbarH = 80
        }
    }
    
    func setHotH(_ statusH : CGFloat) {
        kStatusH = statusH
        if kStatusH == 40 || kStatusH == 64 {
            kHotH = 20
        }else {
            kHotH = 0
        }
    }
}
