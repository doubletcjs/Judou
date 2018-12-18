//
//  AccountManager.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

//表名 t_judouaccount

class AccountManager: NSObject {
    class func accountLogin() -> Bool {
        if UserDefaults.standard.object(forKey: kLoginUserID) != nil {
            return true
        } else {
            return false
        }
    }
}

class UserModel: BaseModel {
    /**
     *    用户id
     */
    @objc var userId: String = ""
    /**
     *    用户名(昵称)
     */
    @objc var nickname: String = ""
    /**
     *    头像
     */
    @objc var portrait: String = ""
    /**
     *     性别 0 未设置 1 男 2 女
     */
    @objc var gender: Int = 0
    /**
     *    生日 默认为 创建日期 yyyy-MM-dd
     */
    @objc var birthday: String = ""
    /**
     *    手机号码
     */
    @objc var phone: String = ""
    /**
     *    创建日期 yyyy-MM-dd
     */
    @objc var date: String = ""
    /**
     *     状态 0 正常 1 禁言 2 禁用
     */
    @objc var status: Int = 0
    /**
     *     被举报次数
     */
    @objc var report: Int = 0
    
    // MARK: - 主键
    @objc override class func getPrimaryKey() -> String {
        return "userId"
    }
    // MARK: - 获取当前登录用户
    class func fetchUser(_ completionHandler: @escaping (_ userModel: UserModel) -> Void) -> Void {
        if UserDefaults.standard.object(forKey: kLoginUserID) != nil {
            let userId = UserDefaults.standard.object(forKey: kLoginUserID) as! String
            if kAppdelegate.networkReachable == true {
                Networking.requestUserInfo(userId) { (aUserModel, aError) in
                    if aUserModel == nil {
                        let helper = UserModel.getUsingLKDBHelper()
                        let userModel: UserModel = helper.searchSingle(UserModel.self, where: ["userId": userId], orderBy: nil) as! UserModel
                        
                        DispatchQueue.main.async {
                            completionHandler(userModel)
                        }
                    } else {
                        UserModel.recordUserInfo(aUserModel!)
                        
                        DispatchQueue.main.async {
                            completionHandler(aUserModel!)
                        }
                    }
                }
            } else {
                let helper = UserModel.getUsingLKDBHelper()
                let userModel: UserModel? = helper.searchSingle(UserModel.self, where: ["userId": userId], orderBy: nil) as? UserModel
                
                DispatchQueue.main.async {
                    if userModel == nil {
                        completionHandler(UserModel())
                    } else {
                        completionHandler(userModel!)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completionHandler(UserModel())
            }
        }
    }
    // MARK: - 缓存用户信息
    class func recordUserInfo(_ newUserModel: UserModel) -> Void {
        let helper = UserModel.getUsingLKDBHelper()
        let userModel: UserModel? = helper.searchSingle(UserModel.self, where: ["userId": UserDefaults.standard.object(forKey: kLoginUserID)], orderBy: nil) as? UserModel
        
        if userModel == nil {
            
        } else {
            helper.insert(toDB: newUserModel) { (isSuccessful) in
                if isSuccessful == true {
                    Log("缓存用户信息成功")
                } else {
                    Log("缓存用户信息失败")
                }
            }
        }
    }
}
