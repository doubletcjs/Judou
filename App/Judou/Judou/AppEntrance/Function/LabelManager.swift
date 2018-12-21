//
//  LabelManager.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

//表名 label_table

class LabelManager: BaseModel {

}

class LabelModel: BaseModel {
    /**
     *     标签id
     */
    @objc var objectId: String = ""
    /**
     *     标题
     */
    @objc var title: String = ""
    /**
     *     封面url
     */
    @objc var cover: String = ""
    /**
     *     创建人
     */
    @objc var author: UserModel = UserModel()
    /**
     *     审核状态 0 待审核 1 通过 2 禁用 3 系统创建
     */
    @objc var status: Int = 0
    /**
     *     不公开 authorId id用于表关联查询
     */
}
