//
//  UserCheckPassWord.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/14.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let url : String = kUrl + "app/page/checkPassWord"

class UserCheckPassWord {
    
    public func requestData(_ params:[String:String] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: url, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
