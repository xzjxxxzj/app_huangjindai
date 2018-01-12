//
//  AppModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/19.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//  启动广告页网络请求数据

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let url : String = kUrl + "app/page/startImage"
private let VisonUrl : String = kUrl + "app/page/vision"

public var startImage: [String] = []


class AppModel {
    
    public func requestData(success : @escaping (_ responseObject : [String])->(), failture : @escaping (_ error : NSError)->()) {
        
        NetWorkTools.GETJSONSTR(url: url, params: nil, success: { (result) in
            let json = JSON(result)
            for (_, subJson) : (String, JSON) in json {
                if subJson.string != nil {
                    startImage.append(subJson.string!)
                }
            }
            success(startImage)
        }) { (error) in
            failture(error)
        }
    }
    
    public func requestVision(success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        
        NetWorkTools.GETJSON(url: VisonUrl, params: nil, success: { (result) in
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
