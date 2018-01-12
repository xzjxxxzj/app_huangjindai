//
//  UserAccountModel.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/11.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
//请求地址
private let url : String = kUrl + "app/page/userAccountDate"
private let withUrl : String = kUrl + "app/page/withDrawInfo"
private let djqUrl : String = kUrl + "app/page/getUserDjq"
private let userRepayUrl : String = kUrl + "app/page/userRepayList"
private let userRepayDetailUrl : String = kUrl + "app/page/userRepayDetail"
private let userInvestListUrl : String = kUrl + "app/page/userInvestList"
private let getCanClaimsListUrl : String = kUrl + "app/page/userDebtList"
private let getClaimsIngListUrl : String = kUrl + "app/page/userDebtedList"
private let getClaimsBuyListUrl : String = kUrl + "app/page/userDebtBuyList"
private let getClaimsInfoUrl : String = kUrl + "app/page/userDebtInfo"
private let doClaimsUrl : String = kUrl + "app/page/doDebt"
private let getClaimsIngInfoUrl : String = kUrl + "app/page/inDebtInfo"
private let closeClaimsUrl : String = kUrl + "app/page/closeClaims"
private let recordUrl : String = kUrl + "app/page/record"
private let huoqiUrl : String = kUrl + "app/page/huoqiInfo"
private let huoqiRecordUrl : String = kUrl + "app/page/huoqiRecord"
private let huoqiOutUrl :String = kUrl + "app/page/huoqiOutInfo"
private let doHuoqiOutUrl : String = kUrl + "app/page/doHuoqiOut"
private let huoqiInUrl :String = kUrl + "app/page/huoqiInInfo"
private let doHuoqiInUrl : String = kUrl + "app/page/doHuoqiIn"
private let inviteInfoUrl : String = kUrl + "app/page/inviteInfo"
private let doSetInviteCodeUrl : String = kUrl + "app/page/doSetInviteCode"
private let inviteDetailUrl : String = kUrl + "app/page/inviteDetail"
private let inviteInfoListUrl : String = kUrl + "app/page/inviteInfoMore"
class UserAccountModel {
    
    public func requestData(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: url, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getWithInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: withUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getDjqList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: djqUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getUserRepayInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: userRepayUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getUserRepayDetail(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: userRepayDetailUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getInvestList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: userInvestListUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getCanClaimsList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: getCanClaimsListUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getClaimsIngList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: getClaimsIngListUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getClaimsBuyList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: getClaimsBuyListUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getClaimsInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: getClaimsInfoUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func doClaims(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: doClaimsUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func getClaimsIngInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: getClaimsIngInfoUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func closeClaims(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: closeClaimsUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func recordList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: recordUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func huoqiInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: huoqiUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func huoqiRecord(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: huoqiRecordUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func huoqiOutInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: huoqiOutUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func doHuoqiOut(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: doHuoqiOutUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func huoqiInInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: huoqiInUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func doHuoqiIn(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: doHuoqiInUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func inviteInfo(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: inviteInfoUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func doSetInviteCode(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: doSetInviteCodeUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func inviteDetail(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: inviteDetailUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
    
    public func inviteInfoList(params:[String:Any] ,success : @escaping (_ responseObject : JSON)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.GETJSON(url: inviteInfoListUrl, params: params, success: { (result) in
            //初始化数据
            let json = JSON(result)
            success(json)
        }) { (error) in
            failture(error)
        }
    }
}
