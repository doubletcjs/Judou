//
//  CollectionManager.swift
//  Judou
//
//  Created by 4work on 2018/12/25.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class CollectionManager: NSObject {

}

class CollectionModel: BaseModel {
    /**
     *     收藏夹id
     */
    @objc var objectId: String = ""
    /**
     *    封面
     */
    @objc var cover: String = ""
    /**
     *    收藏夹名称
     */
    @objc var name: String = ""
    /**
     *    收藏夹简介
     */
    @objc var introduction: String = ""
    /**
     *     是否私密
     */
    @objc var isPrivate: Bool = false
}
