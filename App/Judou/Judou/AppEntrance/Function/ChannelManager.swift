//
//  ChannelManager.swift
//  Judou
//
//  Created by 4work on 2018/12/16.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class ChannelManager: NSObject {

}

class ChannelModel: BaseModel {
    /**
     *     名称
     */
    @objc var name: String = ""
    // MARK: - 主键
    @objc override class func getPrimaryKey() -> String {
        return "rowid"
    }
    // MARK: - 保存分类列表
    class func recordChannel(_ list: Array<ChannelModel>) -> Void {
        let helper = BaseModel.getUsingLKDBHelper()
        if helper.isExistsClass(ChannelModel.self, where: nil) {
            helper.delete(with: ChannelModel.self, where: nil) { (deleteResult: Bool) in
                DispatchQueue.main.async {
                    for model: ChannelModel in list {
                        helper.insert(toDB: model)
                    }
                }
            }
        } else {
            for model: ChannelModel in list {
                helper.insert(toDB: model)
            }
        }
    }
    // MARK: - 默认分类列表
    class func defaultChannels() -> Array<ChannelModel> {
        var array: [ChannelModel] = []
        let channels: [String] = ["广场", "原创", "随笔", "话题", "情感", "励志", "毒汤", "英文"]
        channels.forEach { (channel) in
            let model = ChannelModel()
            model.name = channel
            array.append(model)
        }
        
        return array
    }
    // MARK: - 读取分类列表
    class func readAllChannel() -> Array<ChannelModel> {
        let helper = BaseModel.getUsingLKDBHelper()
        var array = helper.search(withSQL: "select * from \(self.getTableName())", to: ChannelModel.self) as! Array<ChannelModel>
        if array.count == 0 {
            array = self.defaultChannels()
            self.recordChannel(array)
        }
        
        return array
    }
}
