//
//  Networking.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

// MARK: - 基础信息
let kBaseURL: String = "http://0.0.0.0:8088"
private let formatError: NSError = NSError.init(domain: "未知错误", code: -999, userInfo: [NSLocalizedDescriptionKey: "返回数据格式错误"])

private let kRequestSuccessCode: String = "1000"
private let kRequestFailureCode: String = "1001"

// MARK: - block
typealias UserInfoResponseBlock = (_ userModel: UserModel?, _ aError: NSError?) -> Void
typealias ResponseResultBlock = (_ obj: Any?, _ aError: NSError?) -> Void
typealias FileUploadFinishBlock = (_ fileUrls: [String]?, _ aError: NSError?) -> Void
typealias FileUploadProgressBlock = (_ progress: Double?) -> Void
typealias SuccessFailureBlock = (_ isSuccessful: Bool?, _ aError: NSError?) -> Void
typealias ErrorBlock = (_ aError: NSError?) -> Void

typealias CreationCompletionBlock = (_ model: Any?) -> Void

// MARK: - Networking
class Networking: NSObject {
    // MARK: - 处理接口返回数据
    private class func handleResponseData(_ response: DataResponse<Any>, finish: ResponseResultBlock!) -> Void {
        if response.result.isSuccess == true {
            var dict: [String: Any]? = response.result.value as? [String: Any]
            if response.result.value is String {
                func jsonToDictionary(_ json: String) -> [String: Any] {
                    let data = json.data(using: .utf8)! as Data
                    
                    guard let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) else {
                        return [:]
                    }
                    
                    return dict as! [String: Any]
                }
                
                dict = jsonToDictionary(response.result.value as! String)
            }
            
            if dict != nil && dict!.keys.count > 0 {
                if dict!["code"] as! String == kRequestSuccessCode {
                    let data = dict!["data"]
                    
                    DispatchQueue.main.async(execute: {
                        finish(data, nil)
                    })
                } else {
                    let msg = dict!["msg"] as! String
                    let code = dict!["code"] as! String
                    let error: NSError = NSError.init(domain: msg, code: Int(code)!, userInfo: [NSLocalizedDescriptionKey: msg])
                    
                    DispatchQueue.main.async(execute: {
                        finish(nil, error)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    finish(nil, formatError)
                })
            }
        } else {
            Log("url:\(response.request!.url!)\n"+"error:\(response.result.error!)")
            
            DispatchQueue.main.async(execute: {
                finish(nil, response.result.error! as NSError)
            })
        }
    }
    // MARK: - 获取验证码
    class func getVerificationCode(_ phone: String!, completionHandler: @escaping (_ aError: NSError?) -> Void) -> Void { 
        SMSSDK.getVerificationCode(by: .SMS, phoneNumber: phone, zone: "86", template: "") { (error) in
            DispatchQueue.main.async {
                completionHandler(error as NSError?)
            }
        }
    }
    // MARK: - 修改用户信息
    class func editUserInfo(_ info: Dictionary<String, Any>, completionHandler: SuccessFailureBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/updateAccount", method: .post, parameters: info).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        UserModel.recordUserInfo(userModel!)
                    }
                     
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 获取我的账号信息
    class func requestMyInfo(userId: String, completionHandler: UserInfoResponseBlock?) -> Void {
        let params: [String: Any] = [
            "userId": userId
        ]
        
        Alamofire.request("\(kBaseURL)/accountInfo", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 登录
    class func loginRequest(mobile: String, password: String, completionHandler: UserInfoResponseBlock?) -> Void {
        let params: [String: Any] = [
            "mobile": mobile,
            "password": password
        ]
        
        Alamofire.request("\(kBaseURL)/login", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 注册
    class func adminRegisterRequest(mobile: String, password: String, completionHandler: UserInfoResponseBlock?) -> Void {
        let params: [String: Any] = [
            "mobile": mobile,
            "password": password
        ]
        
        Alamofire.request("\(kBaseURL)/registerAdmin", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    
    class func mobileRegisterRequest(mobile: String, password: String, completionHandler: UserInfoResponseBlock?) -> Void { 
        let params: [String: Any] = [
            "mobile": mobile,
            "password": password
        ]
        
        Alamofire.request("\(kBaseURL)/register", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if userModel != nil {
                        if completionHandler != nil {
                            completionHandler!(userModel, nil)
                        }
                    } else {
                        if completionHandler != nil {
                            completionHandler!(nil, formatError)
                        }
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 开放注册管理员
    class func adminAvailable(completionHandler: SuccessFailureBlock?) {
        let params: [String: Any] = [:]
        
        Alamofire.request("\(kBaseURL)/adminAvailable", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    var isAdminAvailable: Bool = false
                    let dict: [String: Any] = data as! [String : Any]
                    if dict["status"] as! String == "1" {
                        isAdminAvailable = true
                    }
                    
                    if completionHandler != nil {
                        completionHandler!(isAdminAvailable, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 修改密码
    class func mobileResetPasswdRequest(mobile: String, password: String, completionHandler: SuccessFailureBlock?) -> Void {
        let params: [String: Any] = [
            "mobile": mobile,
            "password": password
        ]
        
        Alamofire.request("\(kBaseURL)/resetPasswd", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 创建标签、收藏夹、名人、书籍 function: label、collect、famous、book
    /**
     * 参数内容 authorId、title、cover、status|authorId、name、isPrivate、introduction、cover|authorId、name、status、introduction、cove|
    */
    class func functionCreationRequest(params: [String: Any], function: String, completionHandler: SuccessFailureBlock?) -> Void {
        var tempParams: [String: Any] = params
        tempParams["function"] = function
        
        Alamofire.request("\(kBaseURL)/functionCreation", method: .post, parameters: tempParams).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 创建帖子
    /**
     * 参数内容 postDate、authorId、content、labelId、image、isPrivate|postDate、authorId、content、labelId、image、isPrivate、famousId、bookId
    */
    class func postCreationRequest(params: [String: Any], completionHandler: SuccessFailureBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/postCreation", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 标签列表
    /**
     * 参数内容 isAdmin
     */
    class func labelListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/labelList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [LabelModel] = LabelModel.mj_objectArray(withKeyValuesArray: data) as! [LabelModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 收藏夹列表
    /**
     * 参数内容 userId（不能为空）、currentPage、pageSize、loginId (loginId==userId，自己查看自己的收藏夹)
     */
    class func collectionListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/collectionList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [CollectionModel] = CollectionModel.mj_objectArray(withKeyValuesArray: data) as! [CollectionModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 收藏夹帖子列表
    /**
     * 参数内容 collectionId（不能为空）、currentPage、pageSize、loginId、userId
     */
    class func collectionPostListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/collectionPostList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [PostModel] = PostModel.mj_objectArray(withKeyValuesArray: data) as! [PostModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 删除收藏夹、名人、书籍
    /**
     * 参数内容 objectId（不能为空）createType 0 收藏夹 1 名人 2 书籍 cover（封面url，删除服务器文件）
     */
    class func creationDeleteRequest(params: [String: Any], completionHandler: SuccessFailureBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/creationDelete", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 修改收藏夹、名人、书籍
    /**
     *  createType 0 收藏夹 1 名人 2 书籍
    */
    class func creationEditRequest(_ info: Dictionary<String, Any>, _ createType: Int, completionHandler: SuccessFailureBlock?) -> Void {
        var dict: [String: Any] = info
        dict["createType"] = "\(createType)"
        
        Alamofire.request("\(kBaseURL)/creationEdit", method: .post, parameters: dict).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(true, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(false, error)
                    }
                }
            })
        }
    }
    // MARK: - 我发布的帖子列表
    /**
     * 参数内容 userId（不能为空）、currentPage、pageSize、loginId (loginId==userId，自己查看自己的帖子)
     */
    class func myPostListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/postList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [PostModel] = PostModel.mj_objectArray(withKeyValuesArray: data) as! [PostModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 广场
    /**
     * 参数内容 currentPage、pageSize、loginId
     */
    class func squarePostListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/squarePostList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [PostModel] = PostModel.mj_objectArray(withKeyValuesArray: data) as! [PostModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 帖子模糊搜索
    /**
     * 参数内容 currentPage、pageSize、loginId、searchKey
     */
    class func postSearchListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/postSearchList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [PostModel] = PostModel.mj_objectArray(withKeyValuesArray: data) as! [PostModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 用户模糊搜索
    /**
     * 参数内容 currentPage、pageSize、loginId、searchKey
     */
    class func accountSearchListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/accountSearchList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [UserModel] = UserModel.mj_objectArray(withKeyValuesArray: data) as! [UserModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 我喜欢的帖子列表
    /**
     * 参数内容 userId（不能为空）、currentPage、pageSize
     */
    class func postPraiseListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/postPraiseList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [PostModel] = PostModel.mj_objectArray(withKeyValuesArray: data) as! [PostModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 粉丝列表
    /**
     * 参数内容 userId（不能为空）、currentPage、pageSize、loginId
     */
    class func fanListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/userFanList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [UserModel] = UserModel.mj_objectArray(withKeyValuesArray: data) as! [UserModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 关注列表
    /**
     * 参数内容 userId（不能为空）、currentPage、pageSize、loginId
     */
    class func attentionListRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/userAttentionList", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let array: [UserModel] = UserModel.mj_objectArray(withKeyValuesArray: data) as! [UserModel]
                    
                    if completionHandler != nil {
                        completionHandler!(array, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 帖子、评论点赞
    /**
     * 参数内容 objectId 帖子、评论id authorId: 点赞人 praiseType: 点赞类型 0 帖子 1 评论
     */
    class func publicPraiseRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/publicPraise", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(data, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 关注用户
    /**
     * 参数内容 userId 被关注人 loginId: 关注人
     */
    class func accountAttentionRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/accountAttention", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(data, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 收藏帖子
    /**
     * 参数内容 postId 帖子id authorId: 收藏人 collectId: 收藏夹id
     */
    class func postCollectRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/postCollect", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    if completionHandler != nil {
                        completionHandler!(data, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 我的主页
    /**
     * 参数内容 userId（不能为空）、loginId (loginId==userId，自己查看自己的主页)
     */
    class func myHomePageRequest(params: [String: Any], completionHandler: ResponseResultBlock?) -> Void {
        Alamofire.request("\(kBaseURL)/myHomePage", method: .post, parameters: params).responseJSON { response in
            self.handleResponseData(response, finish: { (data, error) in
                if error == nil {
                    let userModel = UserModel.mj_object(withKeyValues: data!) as UserModel?
                    
                    if completionHandler != nil {
                        completionHandler!(userModel, nil)
                    }
                } else {
                    if completionHandler != nil {
                        completionHandler!(nil, error)
                    }
                }
            })
        }
    }
    // MARK: - 文件上传
    ///
    /// - Parameters:
    ///   - function: 功能类 portrait collect label famous book post
    ///   - fileData: 文件data
    ///   - progressHandler: 上传进度
    ///   - completionHandler: 返回JSON数据,文件url列表
    /// - Returns: Void
    class func fileUploadFunction(fileDataList: [Data], function: String, progressHandler: FileUploadProgressBlock?, completionHandler: FileUploadFinishBlock?) -> Void {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            let dateStr: String = "\(NSDate.dateToTimeStamp(Date()))"
            for idx in 0...fileDataList.count-1 {
                var encodeUserID: String = ""
                if function != "portrait" {
                    encodeUserID = base64Encoding(text: UserModel.fetchUser().userId).uppercased()+"_"
                }
                
                let fileName = "\(function)_"+"\(encodeUserID)"+dateStr+"_\(idx).jpg"
                multipartFormData.append(fileDataList[idx], withName: function, fileName: fileName, mimeType: "image/jpeg")
            }
            
            //额外参数
            let userId: String = UserModel.fetchUser().userId
            multipartFormData.append(userId.data(using: String.Encoding.utf8)!, withName: "userId")
            
            multipartFormData.append(function.data(using: String.Encoding.utf8)!, withName: "function")
        }, to: "\(kBaseURL)/fileUpload") { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                //连接服务器成功后，对json的处理
                upload.responseJSON { response in
                    self.handleResponseData(response, finish: { (data, error) in
                        if error == nil {
                            if completionHandler != nil {
                                let files: [String] = data as! [String]
                                completionHandler!(files, nil)
                            }
                        } else {
                            if completionHandler != nil {
                                completionHandler!(nil, error)
                            }
                        }
                    })
                }
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("上传进度: \(progress.fractionCompleted)")
                    
                    DispatchQueue.main.async(execute: {
                        if progressHandler != nil {
                            progressHandler!(progress.fractionCompleted)
                        }
                    })
                }
            case .failure(let encodingError):
                //打印连接失败原因
                print("上传失败:\(encodingError)")
                
                DispatchQueue.main.async(execute: {
                    if completionHandler != nil {
                        completionHandler!(nil, encodingError as NSError)
                    }
                })
            }
        }
    }
}
