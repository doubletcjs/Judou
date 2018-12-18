//
//  BaseModel.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit
import MJExtension.NSObject_MJKeyValue

class BaseModel: NSObject {
    // MARK: - init
    static private var BaseDBHelper: LKDBHelper?
    @objc class private func getDBHelper() -> LKDBHelper {
        if BaseDBHelper == nil {
            let paths: [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let caches: String = paths[0]
            let path: String = "\(caches)/JudouCache.db"
            Log("path:\(path)")
            BaseDBHelper = LKDBHelper.init(dbPath: path)
        }
        
        return BaseDBHelper!
    }
    
    override init() {
        super.init()
    }
    
    @objc override class func getUsingLKDBHelper() -> LKDBHelper {
        return BaseModel.getDBHelper()
    }
    // MARK: - 继承父类属性
    @objc override class func isContainParent() -> Bool {
        return true
    }
    // MARK: - 返回字段描述
    @objc override class func description() -> String {
        return "\(String(describing: self.mj_keyValues()))"
    }
    // MARK: - 将要插入数据库
    @objc override class func dbWillInsert(_ entity: NSObject) -> Bool {
        Log("will insert : \(self.classForCoder())")
        return true
    }
    
    @objc override class func dbWillUpdate(_ entity: NSObject) -> Bool {
        Log("will update : \(self.classForCoder())")
        return true
    }
    
    @objc override class func dbWillDelete(_ entity: NSObject) -> Bool {
        Log("will delete : \(self.classForCoder())")
        return true
    }
    // MARK: - 已经插入数据库
    @objc override class func dbDidInserted(_ entity: NSObject, result: Bool) -> Void {
        Log("did insert : \(self.classForCoder())")
    }
    
    @objc override class func dbDidUpdated(_ entity: NSObject, result: Bool) -> Void {
        Log("did update : \(self.classForCoder())")
    }
    
    @objc override class func dbDidDeleted(_ entity: NSObject, result: Bool) -> Void {
        Log("did delete : \(self.classForCoder())")
    }
    // MARK: - 表名
    @objc override class func getTableName() -> String {
        var name: String = "\(self.classForCoder())"
        if name.contains("Model") {
            name = name.replacingOccurrences(of: "Model", with: "")
        }
        
        return "\(name)Table"
    }
    // MARK: - 替换掉nil值
    @objc override class func mj_newValue(fromOldValue oldValue: Any!, property: MJProperty!) -> Any! {
        var oldValue = oldValue
        if property?.type.typeClass == [Any].self || property?.type.typeClass == [AnyHashable].self {
            if oldValue == nil || (oldValue is NSNull) {
                if property?.type.typeClass == [Any].self {
                    oldValue = []
                } else if property?.type.typeClass == [AnyHashable].self {
                    oldValue = []
                }
            }
        } else {
            if oldValue == nil || (oldValue is NSNull) {
                oldValue = ""
            }
        }
        
        return oldValue
    }
}
