//
//  FamousManager.swift
//  Judou
//
//  Created by 4work on 2018/12/22.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class FamousManager: NSObject {

}

class FamousModel: BaseModel {
    /**
     *     名人id
     */
    @objc var objectId: String = ""
    /**
     *    封面
     */
    @objc var cover: String = ""
    /**
     *    名人姓名
     */
    @objc var name: String = ""
    /**
     *    简介
     */
    @objc var introduction: String = ""
    /**
     *     是否订阅
     */
    @objc var isSubscribe: Bool = false
    /**
     *     订阅数
     */
    @objc var subscribeCount: Int = 0
    /**
     *     创建人
     */
    @objc var author: UserModel = UserModel()
}
