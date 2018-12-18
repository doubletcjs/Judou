//
//  PostManager.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

//表名 t_judoupost

class PostManager: BaseModel {
    
}

class PostModel: BaseModel {
    /**
     *     帖子id
     */
    @objc var objectId: String = ""
    /**
     *     内容
     */
    @objc var content: String = ""
    /**
     *     图片url
     */
    @objc var image: String = ""
    /**
     *    创建日期 yyyy-MM-dd HH:mm:ss
     */
    @objc var postDate: String = ""
    /**
     *     被举报次数
     */
    @objc var report: Int = 0
    /**
     *     点赞次数
     */
    @objc var praise: Int = 0
    /**
     *     评论数
     */
    @objc var comment: Int = 0
    /**
     *     被收藏次数
     */
    @objc var collect: Int = 0
    /**
     *     是否点赞
     */
    @objc var isPraise: Bool = false
    /**
     *     是否收藏
     */
    @objc var isCollect: Bool = false
    /**
     *     作者
     */
    @objc var author: UserModel = UserModel()
    /**
     *     不公开 labelId authorId id用于表关联查询
    */
}
