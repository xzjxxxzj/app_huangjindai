//
//  HomeModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/20.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let url : String = kUrl + "app/page/home"

class HomeModel {
    
    
    public func requestData(success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: url, params: nil, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
