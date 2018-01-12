//
//  LoginModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/26.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let loginUrl : String = kUrl + "app/page/login"

class LoginModel {
    
    public func requestData(_ params : [String:String],success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: loginUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
