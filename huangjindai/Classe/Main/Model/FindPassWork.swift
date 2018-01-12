//
//  FindePassWork.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/28.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let getUrl : String = kUrl + "app/page/findPassWork"

class FindPassWork {
    
    public func requestData(_ params : [String:String],success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: getUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
