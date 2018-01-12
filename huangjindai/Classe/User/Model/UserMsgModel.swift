//
//  UserMsgModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/6.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
fileprivate let url : String = kUrl + "app/page/getUserMsg"
fileprivate let deleteUrl : String = kUrl + "app/page/msgDelete"
fileprivate let setReadUrl : String = kUrl + "app/page/setMsgRead"
fileprivate let setAllReadUrl : String = kUrl + "app/page/setMsgReadAll"
fileprivate let setAllDelUrl : String = kUrl + "app/page/msgAllDelete"
class UserMsgModel {
    
    public func requestData(params:[String:Any], success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: url, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    //删除消息
    public func deleteMsg(params:[String:Any], success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: deleteUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    //设置消息为已读
    public func setRead(params:[String:Any], success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: setReadUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    //设置为全部已读
    public func setAllRead(params:[String:Any], success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: setAllReadUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    //设置为全部删除
    public func setAllDelete(params:[String:Any], success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: setAllDelUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
