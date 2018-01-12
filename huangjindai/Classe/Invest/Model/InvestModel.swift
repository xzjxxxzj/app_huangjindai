//
//  InvestModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/2.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let investUrl : String = kUrl + "app/page/investList"

private let claimsUrl : String = kUrl + "app/page/claimsList"

class InvestModel {
    
    public func dinqiRequestData(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: investUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func zhaiquanRequestData(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: claimsUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
