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
     *     是否私密
     */
    @objc var isPrivate: Bool = false
    /**
     *     标签名称
     */
    @objc var labelName: String = ""
    /**
     *     标签id
     */
    @objc var labelId: String = ""
    /**
     *     类型 0 收录 (名人、书籍) 1 原创
     */
    @objc var postType: Int = 0
    /**
     *     作者
     */
    @objc var author: UserModel = UserModel()
    /**
     *     收录于名人
     */
    @objc var famous: FamousModel = FamousModel()
    /**
     *     出自书籍
     */
    @objc var book: BookModel = BookModel()
}
