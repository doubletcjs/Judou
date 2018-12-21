//
//  NSDate+Unitl.swift
//  Judou
//
//  Created by 4work on 2018/12/21.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

extension NSDate {
    // MARK: - 获取到时间戳里的毫秒单位
    class func dateToTimeStamp(_ date: Date!) -> TimeInterval {
        return date.timeIntervalSince1970*1000.0
    }
    // MARK: - 时间戳转日期
    class func timeStampToDate(_ timeStamp: TimeInterval) -> Date? {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp / 1000.0))
        
        return date
    }
    // MARK: - 格式化日期字符串
    class func formatDateString(dateString: String?, format: String?) -> String? {
        let date = self.stringToDate(dateString: dateString, format: format)
        
        return self.dateToString(date: date, format: format)
    }
    // MARK: - 格式化日期
    class func formatDate(date: Date?, format: String?) -> Date? {
        let dateString = self.dateToString(date: date, format: format)
        
        return self.stringToDate(dateString: dateString, format: format)
    }
    // MARK: - 日期格式转字符串
    class func dateToString(date: Date?, format: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
        
        formatter.locale = Locale.init(identifier: "zh_CN")
        var strDate: String? = ""
        
        if date != nil  {
            strDate = formatter.string(from: date!)
        } else {
            strDate = formatter.string(from: Date())
        }
        
        return strDate ?? ""
    }
    // MARK: - 字符串转日期格式
    class func stringToDate(dateString: String?, format: String?) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
        
        formatter.locale = Locale.init(identifier: "zh_CN")
        return formatter.date(from: dateString ?? "")
    } 
}
