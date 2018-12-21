//
//  Utils.swift
//  Judou
//
//  Created by 4work on 2018/12/19.
//

import Foundation
import PerfectCrypto

private let RequestSuccessCode: String = "1000"
private let RequestFailureCode: String = "1001"
private let ResultDataKey = "data"
private let ResultCodeKey = "code"
private let ResultMessageKey = "msg"
private var BaseResponseJson: [String : Any] = [ResultDataKey: [], ResultCodeKey: RequestSuccessCode, ResultMessageKey: ""]

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
}
