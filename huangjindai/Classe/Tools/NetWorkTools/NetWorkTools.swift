//
//  NetWorkTools.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/19.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift

enum MethodType {
    case get
    case post
}

fileprivate let key : String = ""

class NetWorkTools {
    //请求获得JSON格式数据
    // url : 请求的地址
    // type : 请求的类型，.get or .post
    // params : 请求的参数
    // success : 成功时候回调
    // failture : 失败时候回调
    class func requestToJson(url : String, _ type :MethodType = .get, params : [String : Any]?, success : @escaping (_ responseObject : [String:Any])->(), failture : @escaping (_ error : NSError)->()) {
        //获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        //请求数据
        Alamofire.request(url, method: method, parameters: params).responseJSON { (response) in
            switch response.result {
            case.success:
                if let value = response.result.value as? [String : AnyObject] {
                    success(value)
                }
            case .failure(let error):
                failture(error as NSError)
            }
        }
    }
    
    //请求获得string格式数据
    // url : 请求的地址
    // type : 请求的类型，.get or .post
    // params : 请求的参数
    // success : 成功时候回调
    class func requestToStr(url : String, _ type :MethodType = .get, params : [String : Any]?, success : @escaping (_ responseObject : String)->(), failture : @escaping (_ error : NSError)->()) {
        //获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        //请求数据
        Alamofire.request(url, method: method, parameters: params).responseString { (response) in
            switch response.result {
            case.success:
                if let value = response.result.value{
                    success(value)
                }
            case .failure(let error):
                failture(error as NSError)
            }
        }
    }
    
    //获取没有下标的JSON数据
    class func requestToJsonString(url : String, _ type :MethodType = .get, params : [String : Any]?, success : @escaping (_ responseObject : [String])->(), failture : @escaping (_ error : NSError)->()) {
        //获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        //请求数据
        Alamofire.request(url, method: method, parameters: params).responseJSON { (response) in
            switch response.result {
            case.success:
                if let value = response.result.value as? [String] {
                    success(value)
                }
            case .failure(let error):
                failture(error as NSError)
            }
        }
    }
}

//封装给外部使用的方法，方便使用
extension NetWorkTools {
    
    class func GETJSON(url : String, params : [String : Any]?, success : @escaping (_ responseObject : [String:Any])->(), failture : @escaping (_ error : NSError)->()) {
        var requestData = params
        if params != nil {
            let jsonParams = NetWorkTools.ToJson(params!)
            let iv = AES.randomIV(16)
            let aes = try! AES(key: key.bytes, blockMode: .CBC(iv: iv), padding: .pkcs7)
            let enCode = try! aes.encrypt(jsonParams.bytes)
            let lastCode = enCode.toBase64()
            let enData: [String:Any] = ["iv" : iv.toBase64() as Any,"value" : lastCode as Any]
            let enDataBase = NetWorkTools.ToJson(enData).bytes.toBase64()
            let sign:String = NetWorkTools.sign(params!)
            requestData = ["data" : enDataBase ?? "","sign" : sign]
        }
        NetWorkTools.requestToJson(url: url, .get, params: requestData, success: success, failture: failture)
    }
    
    class func GETJSONSTR(url : String, params : [String : Any]?, success : @escaping (_ responseObject : [String])->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.requestToJsonString(url: url, .get, params: params, success: success, failture: failture)
    }
    
    class func GET(url : String, params : [String : Any]?, success : @escaping (_ responseObject : String)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.requestToStr(url: url, .get, params: params, success: success, failture: failture)
    }
    
    class func POSTJSON(url : String, params : [String : Any]?, success : @escaping (_ responseObject :[String:Any])->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.requestToJson(url: url, .post, params: params,success: success, failture: failture)
    }
    
    class func POST(url : String, params : [String : Any]?, success : @escaping (_ responseObject : String)->(), failture : @escaping (_ error : NSError)->()) {
        NetWorkTools.requestToStr(url: url, .post, params: params, success: success, failture: failture)
    }
    
    class func GETURL(url : String, params : [String : Any]?) -> String {
        var reUrl = url
        if params != nil {
            let jsonParams = NetWorkTools.ToJson(params!)
            let iv = AES.randomIV(16)
            let aes = try! AES(key: key.bytes, blockMode: .CBC(iv: iv), padding: .pkcs7)
            let enCode = try! aes.encrypt(jsonParams.bytes)
            let lastCode = enCode.toBase64()
            let enData: [String:Any] = ["iv" : iv.toBase64() as Any,"value" : lastCode as Any]
            let enDataBase = NetWorkTools.ToJson(enData).bytes.toBase64()
            let sign:String = NetWorkTools.sign(params!)
            reUrl = "\(reUrl)?data=\(enDataBase ?? "")&sign=\(sign)"
        }
        return reUrl
    }
    
    //转为JOSN
    fileprivate class func ToJson(_ strData : [String : Any]) -> String
    {
        let data = try? JSONSerialization.data(withJSONObject: strData, options: []) as NSData!
        let strJson = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
        return strJson! as String
    }
    
    fileprivate class func sign(_ params : [String:Any]) -> String {
        let sortParams = params.sorted {$0.0 < $1.0}
        var signed : String = ""
        for (key,value) in sortParams {
            signed = signed + "\(key)=\(value)"
        }
        if params["userId"] != nil {
            let userInfo = UserDefaults.standard.dictionary(forKey: "user")
            let key2 = userInfo!["key2"] as! String
            signed = signed + key2
        }
        signed = key + signed
        let md5Sign = signed.md5()
        return md5Sign
    }
}
