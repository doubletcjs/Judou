//
//  Utils.swift
//  Judou
//
//  Created by 4work on 2018/12/19.
//

import Foundation
import PerfectCrypto
import PerfectLogger
import PerfectLib

let accounttable = "account_table"

let posttable = "post_table"
let commenttable = "comment_table"

let praisecommenttable = "praise_comment"
let praiseposttable = "praise_post"
let collectposttable = "collect_post"
let reportusertable = "report_user"
let attentionfantable = "attention_fan"

let labelposttable = "label_post"
let famousposttable = "famous_post"
let bookposttable = "book_post"

let labeltable = "label_table"
let collecttable = "collect_table"
let famoustable = "famous_table"
let booktable = "book_table"

private let RequestSuccessCode: String = "1000"
private let RequestFailureCode: String = "1001"
private let ResultDataKey = "data"
private let ResultCodeKey = "code"
private let ResultMessageKey = "msg"
private var BaseResponseJson: [String : Any] = [ResultDataKey: [], ResultCodeKey: RequestSuccessCode, ResultMessageKey: ""]

let kServerPort: UInt16 = 8088
let kServerName = "localhost"
let kServerDocumentRoot = "/Users/4work/Documents/Judou/Server/JudouServer/WebRoot"

class Utils {
    // MAKR: - 日期格式转换
    class func dateToString(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = format
        
        let locale = Locale.init(identifier: "zh_CN")
        dateFormatter.locale = locale
        
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    // MARK: - JSON转字典
    class func jsonToDictionary(_ json: String) -> [String: Any] {
        let data = json.data(using: .utf8)! as Data
        
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) else {
            return [:]
        }
        
        return dict as! [String : Any]
    }
    // MARK: - 转JSON
    class func objectToJson(_ obj: Any) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return ""
        }
        
        let json: String = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
        
        return json 
    }
    // MARK: - 格式化接口数据
    class func failureResponseJson(_ msg: String) -> String {
        BaseResponseJson[ResultCodeKey] = RequestFailureCode
        BaseResponseJson[ResultDataKey] = [String: String]()
        BaseResponseJson[ResultMessageKey] = msg
        
        guard let json = try? BaseResponseJson.jsonEncodedString() else {
            return ""
        }
        
        return json
    }
    
    class func successResponseJson(_ jsonObject: Any) -> String {
        BaseResponseJson[ResultCodeKey] = RequestSuccessCode
        BaseResponseJson[ResultDataKey] = jsonObject
        BaseResponseJson[ResultMessageKey] = ""
        
        guard let json = try? BaseResponseJson.jsonEncodedString() else {
            return ""
        }
        
        return json
    }
    // MARK: - 记录错误日记
    class func logError(_ functionName: String, _ msg: Any) -> Void {
        let dict: [String: Any] = ["日期": Utils.dateToString(date: Date(), format: "yyyy.MM.dd HH:mm:ss:SSS"), "方法名": "\(functionName)", "信息内容": "\(msg)"]
        
        LogFile.info("\(Utils.objectToJson(dict))")
    }
    // MARK: - 删除服务器本地文件
    class func deleteLocalFile(_ absolutePath: String) -> Void {
        LogFile.info("删除文件:\(absolutePath)")
        let file = File.init(absolutePath)
        file.delete()
    }
}
