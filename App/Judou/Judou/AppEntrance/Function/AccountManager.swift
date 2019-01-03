//
//  AccountManager.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

//表名 account_table

class AccountManager: NSObject {
    class func accountLogin() -> Bool {
        if UserDefaults.standard.object(forKey: kLoginUserID) != nil {
            return true
        } else {
            return false
        }
    }
    
    class func login(_ userModel: UserModel) -> Void {
        UserDefaults.standard.set(userModel.userId, forKey: kLoginUserID)
        UserDefaults.standard.synchronize()
        
        UserModel.recordUserInfo(userModel)
    }
    
    class func logout() -> Void {
        UserDefaults.standard.set(nil, forKey: kLoginUserID)
        UserDefaults.standard.synchronize()
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
    @objc var mobile: String = ""
    /**
     *    创建日期 yyyy-MM-dd
     */
    @objc var date: String = ""
    /**
     *     用户等级 0 管理员 1 普通用户
     */
    @objc var level: Int = 0
    /**
     *     状态 0 正常 1 禁言 2 禁用
     */
    @objc var status: Int = 0
    /**
     *     是否关注
     */
    @objc var isAttention: Bool = false
    /**
     *     被举报次数
     */
    @objc var reportCount: Int = 0
    /**
     *     订阅数
     */
    @objc var subscribeCount: Int = 0
    /**
     *     发帖数
     */
    @objc var postCount: Int = 0
    /**
     *     喜欢数
     */
    @objc var praiseCount: Int = 0
    /**
     *     收藏夹数
     */
    @objc var collectionCount: Int = 0
    /**
     *     关注
     */
    @objc var attentionCount: Int = 0
    /**
     *     粉丝
     */
    @objc var fanCount: Int = 0
    
    // MARK: - 主键
    @objc override class func getPrimaryKey() -> String {
        return "userId"
    }
    // MARK: - 获取当前登录用户
    class func fetchUser() -> UserModel {
        if AccountManager.accountLogin() == true {
            let userId = UserDefaults.standard.object(forKey: kLoginUserID) as! String
            
            let helper = UserModel.getUsingLKDBHelper()
            let userModel: UserModel? = helper.searchSingle(UserModel.self, where: ["userId": userId], orderBy: nil) as? UserModel
            
            if userModel == nil {
                return UserModel()
            } else {
                return userModel!
            }
        } else {
            return UserModel()
        }
    }
    
    class func fetchNewestUser(_ completionHandler: @escaping () -> Void) -> Void {
        let userId = UserDefaults.standard.object(forKey: kLoginUserID) as! String
        Networking.requestMyInfo(userId: userId) { (aUserModel, aError) in
            if aUserModel == nil {
                DispatchQueue.main.async {
                    completionHandler()
                }
            } else {
                UserModel.recordUserInfo(aUserModel!)
                
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    //发帖、创建收藏夹、点赞、收藏
    class func updateUserInfo() -> Void {
        self.fetchNewestUser {
            
        }
    }
    // MARK: - 缓存用户信息
    class func recordUserInfo(_ newUserModel: UserModel) -> Void {
        let helper = UserModel.getUsingLKDBHelper()
        let userModel: UserModel? = helper.searchSingle(UserModel.self, where: ["userId": newUserModel.userId], orderBy: nil) as? UserModel
        
        if userModel == nil {
            helper.insert(toDB: newUserModel) { (isSuccessful) in
                if isSuccessful == true {
                    Log("缓存用户信息成功")
                } else {
                    Log("缓存用户信息失败")
                }
            }
        } else {
            helper.update(toDB: newUserModel, where: ["userId": newUserModel.userId])
            Log("更新缓存用户信息成功")
        }
    }
}
