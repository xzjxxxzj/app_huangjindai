//
//  UserSettingModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/16.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let url : String = kUrl + "app/page/getUserInfo"
private let setNameUrl : String = kUrl + "app/page/setName"
private let setPassUrl : String = kUrl + "app/page/setPass"
private let oldMobileUrl : String = kUrl + "app/page/oldMobileCheck"
private let setNewMobielUrl :String = kUrl + "app/page/setNewMobile"
class UserSettingModel {
    
    public func requestData(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: url, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    //实名认证
    public func setNameData(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: setNameUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    //密码修改
    public func resetPass(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: setPassUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    //原手机验证
    public func oldMobileCheck(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: oldMobileUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func setNewMobile(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: setNewMobielUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
