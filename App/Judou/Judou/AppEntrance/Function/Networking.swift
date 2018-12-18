//
//  Networking.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class Networking: NSObject { 
    // MARK: - 获取验证码
    class func getVerificationCode(_ phone: String!, completionHandler: @escaping (_ aError: NSError?) -> Void) -> Void { 
        SMSSDK.getVerificationCode(by: .SMS, phoneNumber: phone, zone: "86", template: "") { (error) in
            DispatchQueue.main.async {
                completionHandler(error as NSError?)
            }
        }
    }
    // MARK: - 修改用户信息
    class func editUserInfo(_ info: Dictionary<String, Any>, completionHandler: @escaping (_ isSuccessful: Bool?, _ aError: NSError?) -> Void) -> Void {
        
    }
    // MARK: - 获取用户信息
    class func requestUserInfo(_ userId: String!, completionHandler: @escaping (_ userModel: UserModel?, _ aError: NSError?) -> Void) -> Void {
        
    }
}
