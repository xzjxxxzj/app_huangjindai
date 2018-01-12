//
//  FindModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/9.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let url : String = kUrl + "app/page/getNewsList"

class FindModel {
    
    public func requestData(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: url, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
