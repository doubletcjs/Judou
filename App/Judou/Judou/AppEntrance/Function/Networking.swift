//
//  Networking.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

// MARK: - 基础信息
private let kBaseURL: String = "http://0.0.0.0:8181"
private let formatError: NSError = NSError.init(domain: "未知错误", code: -999, userInfo: [NSLocalizedDescriptionKey: "返回数据格式错误"])

private let kRequestSuccessCode: String = "1000"
private let kRequestFailureCode: String = "1001"

// MARK: - block
typealias UserInfoResponseBlock = (_ userModel: UserModel?, _ aError: NSError?) -> Void
typealias ResponseResultBlock = (_ obj: Any?, _ aError: NSError?) -> Void
typealias SuccessFailureBlock = (_ isSuccessful: Bool?, _ aError: NSError?) -> Void
typealias ErrorBlock = (_ aError: NSError?) -> Void

// MARK: - Networking
class Networking: NSObject {
    // MARK: - 处理接口返回数据
    private class func handleResponseData(_ response: DataResponse<Any>, finish: ResponseResultBlock!) -> Void {
        if response.result.isSuccess == true {
            let dict: [String: Any]? = response.result.value as? [String: Any]
            if dict != nil && dict!.keys.count > 0 {
                if dict!["code"] as! String == kRequestSuccessCode {
                    let data = dict!["data"]
                    
                    DispatchQueue.main.async(execute: {
                        finish(data, nil)
                    })
                } else {
                    let msg = dict!["msg"] as! String
                    let code = dict!["code"] as! String
                    let error: NSError = NSError.init(domain: msg, code: Int(code)!, userInfo: [NSLocalizedDescriptionKey: msg])
                    
                    DispatchQueue.main.async(execute: {
                        finish(nil, error)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    finish(nil, formatError)
                })
            }
        } else {
            Log("url:\(response.request!.url!)\n"+"error:\(response.result.error!)")
            
            DispatchQueue.main.async(execute: {
                finish(nil, response.result.error! as NSError)
            })
        }
    }
    // MARK: - 获取验证码
    class func getVerificationCode(_ phone: String!, completionHandler: @escaping (_ aError: NSError?) -> Void) -> Void { 
        SMSSDK.getVerificationCode(by: .SMS, phoneNumber: phone, zone: "86", template: "") { (error) in
            DispatchQueue.main.async {
                completionHandler(error as NSError?)
            }
        }
    }
    // MARK: - 修改用户信息
    class func editUserInfo(_ info: Dictionary<String, String>, completionHandler: SuccessFailureBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/updateAccount", method: .post, parameters: info).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        UserModel.recordUserInfo(userModel!)
                    }
                     
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 获取用户信息
    class func requestUserInfo(_ userId: String, completionHandler: UserInfoResponseBlock?) -> Void {
        let parameters: [String : Any] = [
            "userId": userId
        ]
        
        Alamofire.request("\(kBaseURL)/accountInfo", method: .get, parameters: parameters).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MAKR: - 登录
    class func loginRequest(mobile: String, password: String, completionHandler: UserInfoResponseBlock?) -> Void {
        let parameters: [String : Any] = [
            "mobile": mobile,
            "password": password
        ]
        
        Alamofire.request("\(kBaseURL)/login", method: .post, parameters: parameters).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 注册
    class func registerRequest(mobile: String, password: String, completionHandler: UserInfoResponseBlock?) -> Void {
        let parameters: [String : Any] = [
            "mobile": mobile,
            "password": password
        ]
        
        Alamofire.request("\(kBaseURL)/register", method: .post, parameters: parameters).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
}
