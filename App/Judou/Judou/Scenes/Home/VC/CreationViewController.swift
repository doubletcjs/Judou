//
//  CreationViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/25.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class CreationViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var tableView: UITableView!
    private var textField: UITextField!
    private var textView: UITextView!
    private var coverButton: UIButton!

    private var isPrivate: Bool! = false
    private var coverImageData: Data! = Data()
    private var coverImageUrl: String! = ""
    
    var creationCompletionHandle: CreationCompletionBlock?
    
    //0 收藏夹 1 名人 2 书籍
    var createType: Int = 0
    var collectionModel: CollectionModel!
    var famousModel: FamousModel!
    var bookModel: BookModel!
    private var creationEditting: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "创建收藏夹"
        if createType == 1 {
            self.title = "创建名人"
        } else if createType == 2 {
            self.title = "创建书籍"
        }
        
        if collectionModel != nil {
            self.title = "编辑收藏夹"
            isPrivate = collectionModel.isPrivate
            coverImageUrl = collectionModel.cover
            creationEditting = true
        }
        
        if famousModel != nil {
            self.title = "编辑名人"
            coverImageUrl = famousModel.cover
            creationEditting = true
        }
        
        if bookModel != nil {
            self.title = "编辑书籍"
            coverImageUrl = bookModel.cover
            creationEditting = true
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.collectionCloseAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_done"), style: .plain, target: self, action: #selector(self.createCollectionAction))
        
        tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = kRGBColor(red: 237, green: 238, blue: 238, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        self.view.addSubview(tableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // MARK: - 键盘显示
    @objc private func handleKeyboardWillShow(_ notification: Notification) -> Void {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue
        
        tableView.isScrollEnabled = false
        let height: CGFloat = keyboardRec!.size.height
        
        UITextView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
            var frame = self.tableView.frame
            frame.size.height = self.view.bounds.size.height-height
            self.tableView.frame = frame
        })
    }
    
    @objc private func handleKeyboardDidShow() -> Void {
        tableView.isScrollEnabled = true
    }
    // MARK: - 键盘隐藏
    @objc private func handleKeyboardDidHide(_ noti: Notification) -> Void {
        UITextView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
            var frame = self.tableView.frame
            frame.size.height = self.view.bounds.size.height
            self.tableView.frame = frame
        })
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if createType == 0 {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellIdentifier")
        }
        
        for view: UIView in cell!.subviews {
            if view.tag >= 10 {
                view.removeFromSuperview()
            }
        }
        
        cell?.selectionStyle = .none
        cell?.backgroundColor = tableView.backgroundColor
        
        cell?.textLabel?.font = kBaseFont(17)
        cell?.textLabel?.text = ""
        cell?.imageView?.image = nil
        cell?.selectionStyle = .none
        
        if indexPath.row == 1 {
            cell?.backgroundColor = .white
            
            if textField == nil {
                textField = UITextField.init(frame: CGRect.init(x: tableView.separatorInset.left, y: (70-60)/2, width: tableView.bounds.size.width-tableView.separatorInset.left*2, height: 60)~)
                textField.placeholder = "名称（2-15个字）"
                textField.font = kBaseFont(15)
                textField.tag = 10
            }
            
            if collectionModel != nil {
                textField.text = collectionModel.name
            }
            
            if famousModel != nil {
                textField.text = famousModel.name
            }
            
            if bookModel != nil {
                textField.text = bookModel.name
            }
            
            cell?.addSubview(textField)
        } else if indexPath.row == 0 {
            let coverWH: CGFloat = 120
            
            if coverButton == nil {
                coverButton = UIButton.init(frame: CGRect.init(x: (tableView.bounds.size.width-coverWH)/2, y: (190-coverWH)/2, width: coverWH, height: coverWH)~)
                coverButton.backgroundColor = .white
                coverButton.setImage(UIImage.init(named: "add_collection_img"), for: .normal)
                coverButton.contentMode = .scaleAspectFit
                coverButton.imageView?.contentMode = .scaleAspectFit
                coverButton.tag = 11
                coverButton.handleControlEvent(controlEvent: .touchUpInside) { [weak self] (sender) in
                    self?.textView.resignFirstResponder()
                    self?.textField.resignFirstResponder()
                    
                    let actionSheet: JSActionSheet = JSActionSheet.init(title: nil, cancelTitle: "取消", otherTitles: ["拍摄", "从手机相册选择"])
                    actionSheet.showView()
                    actionSheet.dismiss(forCompletionHandle: { [weak self] (index, isCancel) in
                        if isCancel == false {
                            DispatchQueueMainAsyncAfter(deadline: .now(), target: self, execute: {
                                if index == 0 {
                                    self?.showImageCameraPicker(.camera)
                                } else {
                                    self?.showImageCameraPicker(.photoLibrary)
                                }
                            })
                        }
                    })
                }
                
                let coverTipLabel = UILabel.init()
                coverTipLabel.font = kBaseFont(14)
                coverTipLabel.text = "添加封面"
                coverTipLabel.textColor = kRGBColor(red: 209, green: 210, blue: 211, alpha: 1)
                coverTipLabel.tag = 1010
                coverButton.addSubview(coverTipLabel)
                coverTipLabel.sizeToFit()
                coverTipLabel.frame = CGRect.init(x: (coverButton.frame.size.width-coverTipLabel.frame.size.width)/2, y: coverButton.frame.size.height-coverTipLabel.frame.size.height-14, width: coverTipLabel.frame.size.width, height: coverTipLabel.frame.size.height)~
            }
            
            cell?.addSubview(coverButton)
            
            var cover: String = ""
            if collectionModel != nil {
                cover = collectionModel.cover
            }
            
            if famousModel != nil {
                cover = famousModel.cover
            }
            
            if bookModel != nil {
                cover = bookModel.cover
            }
            
            if cover.count > 0 {
                coverButton.yy_setImage(with: URL.init(string: kBaseURL+cover),
                                        for: .normal,
                                        placeholder: UIImage.init(named: "big_image_placeholder"),
                                        options: kWebImageOptions,
                                        completion:nil)
                
                let coverTipLabel = coverButton.viewWithTag(1010) as! UILabel
                coverTipLabel.text = ""
                coverButton.viewWithTag(100)?.removeFromSuperview()
            }
            
        } else if indexPath.row == 2 {
            cell?.backgroundColor = .white
            
            if textView == nil {
                textView = UITextView.init(frame: CGRect.init(x: tableView.separatorInset.left, y: 10, width: tableView.bounds.size.width-tableView.separatorInset.left*2, height: 120-10*2)~)
                textView.js_placeholder = "简介（最多100字）"
                textView.font = kBaseFont(15)
                textView.tag = 12
            }
            
            cell?.addSubview(textView)
            
            if collectionModel != nil {
                textView.text = collectionModel.introduction
            }
            
            if famousModel != nil {
                textView.text = famousModel.introduction
            }
            
            if bookModel != nil {
                textView.text = bookModel.introduction
            }
        } else if indexPath.row == 3 {
            cell?.backgroundColor = .white
            cell?.textLabel?.text = "设为私密"
            cell?.imageView?.image = UIImage.init(named: "icon_post_private")
            cell?.selectionStyle = .none
            
            let privateSwitch = UISwitch.init()
            privateSwitch.isOn = isPrivate
            privateSwitch.addTarget(self, action: #selector(self.privateSwitch), for: .touchUpInside)
            
            cell?.accessoryView = privateSwitch
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 190
        } else if indexPath.row == 1 {
            return 70
        } else if indexPath.row == 2 {
            return 130
        } else if indexPath.row == 3 {
            return 44
        }  else {
            return 0
        }
    }
    // MARK: - 添加标签
    @objc private func createCollectionAction() -> Void {
        if isStringEmpty(textField.text) == true || textField.text!.count < 2 || textField.text!.count > 15 {
            showTextHUD("名称为2-16个字", inView: nil, hideAfterDelay: 1.8)
            
            return
        }
        
        if textView.text!.count > 100 {
            showTextHUD("简介（最多100字）", inView: nil, hideAfterDelay: 1.8)
            
            return
        }
        
        if coverImageData.count == 0 && coverImageUrl.count == 0 {
            showTextHUD("尚未添加封面", inView: nil, hideAfterDelay: 1.8)
            
            return
        }
        
        func checkForEdit() -> [String: Any]! {
            var name: String = ""
            var introduction: String = ""
            var cover: String = ""
            var objectId: String = ""
            var collectionPrivate: Bool = false
            var editedDict: [String: Any] = [:]
            
            if collectionModel != nil {
                name = collectionModel.name
                introduction = collectionModel.introduction
                cover = collectionModel.cover
                collectionPrivate = collectionModel.isPrivate
                objectId = collectionModel.objectId
            }
            
            if famousModel != nil {
                name = famousModel.name
                introduction = famousModel.introduction
                cover = famousModel.cover
                objectId = famousModel.objectId
            }
            
            if bookModel != nil {
                name = bookModel.name
                introduction = bookModel.introduction
                cover = bookModel.cover
                objectId = bookModel.objectId
            }
            
            editedDict["objectId"] = objectId
            
            if textField.text != name {
                editedDict["name"] = textField.text
            }
            
            if textView.text != introduction {
                editedDict["introduction"] = textView.text
            }
            
            if coverImageUrl != cover {
                editedDict["cover"] = coverImageUrl
            }
            
            if isPrivate != collectionPrivate {
                editedDict["isPrivate"] = isPrivate
            }
            
            return editedDict
        }
        
        if creationEditting == true {
            let dict: [String: Any] = checkForEdit()
            if dict.count <= 1 {
                showTextHUD("至少改点啥", inView: nil, hideAfterDelay: 1.8)
                
                return
            }
        }
        
        var function: String = "collect"
        if createType == 1 {
            function = "famous"
        } else if createType == 2 {
            function = "book"
        }
        
        textView.resignFirstResponder()
        textField.resignFirstResponder()
        
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)!
        hud.mode = .determinate
        
        func editCollectRequest(_ hud: MBProgressHUD, _ coverUrl: String) -> Void {
            let dict: [String: Any] = checkForEdit()
            Networking.creationEditRequest(dict, createType) { [weak self] (isSuccessful, error) in
                hud.hide(false)
                
                if isSuccessful == true {
                    var model: BaseModel? = BaseModel()
                    if self?.createType == 0 {
                        let tempModel = CollectionModel.mj_object(withKeyValues: self?.collectionModel.mj_keyValues())
                        if dict["name"] != nil {
                            tempModel?.name = dict["name"] as! String
                        }
                        
                        if dict["introduction"] != nil {
                            tempModel?.introduction = dict["introduction"] as! String
                        }
                        
                        if dict["cover"] != nil {
                            tempModel?.introduction = dict["cover"] as! String
                        }
                        
                        if dict["isPrivate"] != nil {
                            tempModel?.isPrivate = dict["isPrivate"] as! Bool
                        }
                        
                        model = tempModel
                    } else if self?.createType == 1 {
                        let tempModel = FamousModel.mj_object(withKeyValues: self?.famousModel.mj_keyValues())
                        if dict["name"] != nil {
                            tempModel?.name = dict["name"] as! String
                        }
                        
                        if dict["introduction"] != nil {
                            tempModel?.introduction = dict["introduction"] as! String
                        }
                        
                        if dict["cover"] != nil {
                            tempModel?.introduction = dict["cover"] as! String
                        }
                        
                        model = tempModel
                    } else if self?.createType == 2 {
                        let tempModel = BookModel.mj_object(withKeyValues: self?.bookModel.mj_keyValues())
                        if dict["name"] != nil {
                            tempModel?.name = dict["name"] as! String
                        }
                        
                        if dict["introduction"] != nil {
                            tempModel?.introduction = dict["introduction"] as! String
                        }
                        
                        if dict["cover"] != nil {
                            tempModel?.introduction = dict["cover"] as! String
                        }
                        
                        model = tempModel
                    }
                    
                    if self?.creationCompletionHandle != nil {
                        self?.creationCompletionHandle!(model)
                    }
                    
                    showTextHUD("修改成功", inView: nil, hideAfterDelay: 1.5)
                    self?.collectionCloseAction()
                } else {
                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                }
            }
        }
        
        func createCollectRequest(_ hud: MBProgressHUD, _ coverUrl: String) -> Void {
            if creationEditting == true {
                editCollectRequest(hud, coverUrl)
            } else {
                var dict: [String: Any] = ["authorId": UserModel.fetchUser().userId,
                                           "name": textField.text!,
                                           "isPrivate": isPrivate,
                                           "introduction": textView.text!,
                                           "cover": coverUrl]
                
                if createType > 0 {
                    var status: Int = 0
                    if UserModel.fetchUser().level == 0 {
                        status = 3
                    }
                    
                    dict = ["authorId": UserModel.fetchUser().userId,
                            "name": textField.text!,
                            "status": status,
                            "introduction": textView.text!,
                            "cover": coverUrl]
                }
                
                var function: String = "collect"
                if createType == 1 {
                    function = "famous"
                } else if createType == 2 {
                    function = "book"
                }
                
                Networking.functionCreationRequest(params: dict, function: function) { [weak self] (isSuccessful, error) in
                    hud.hide(false)
                    
                    if isSuccessful == true {
                        if self?.creationCompletionHandle != nil {
                            self?.creationCompletionHandle!(nil)
                        }
                        
                        showTextHUD("创建成功", inView: nil, hideAfterDelay: 1.5)
                        self?.collectionCloseAction()
                    } else {
                        showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                    }
                }
            }
        }
        
        if coverImageData.count > 0 {
            Networking.fileUploadFunction(fileDataList: [coverImageData], function: function, progressHandler: { (progress) in
                hud.progress = Float(progress!)
            }) { [weak self] (fileUrls, error) in
                if error != nil {
                    hud.hide(false)
                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                } else {
                    let fileUrl: String = fileUrls!.first! as String
                    if isStringEmpty(fileUrl) == false {
                        self?.coverImageData = Data()
                        self?.coverImageUrl = fileUrl
                        
                        hud.mode = .indeterminate
                        createCollectRequest(hud, fileUrl)
                    } else {
                        hud.hide(false)
                        showTextHUD("文件地址返回为空～", inView: nil, hideAfterDelay: 1.5)
                    }
                }
            }
        } else if coverImageUrl.count > 0 {
            hud.mode = .indeterminate
            createCollectRequest(hud, coverImageUrl)
        }
    }
    // MARK: - 关闭
    @objc private func collectionCloseAction() -> Void {
        textView.resignFirstResponder()
        textField.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - 是否私密
    @objc private func privateSwitch() -> Void {
        textView.resignFirstResponder()
        textField.resignFirstResponder()
        
        isPrivate = !isPrivate
        tableView.reloadRows(at: [IndexPath.init(row: 3, section: 0)], with: .none)
    }
    // MARK: - 拍摄、拍照
    private func showImageCameraPicker(_ sourceType: UIImagePickerController.SourceType) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
            if sourceType == .camera {
                showTextHUD("无法打开系统相机", inView: nil, hideAfterDelay: 1.8)
            } else {
                showTextHUD("无法打开系统相册", inView: nil, hideAfterDelay: 1.8)
            }
        } else {
            func showImagePicker() -> Void {
                let imagePickerVC = UIImagePickerController.init()
                imagePickerVC.allowsEditing = true
                imagePickerVC.sourceType = sourceType
                imagePickerVC.delegate = self
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            
            if sourceType == .camera {
                if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                    AVCaptureDevice.requestAccess(for: .video) { (result) in
                        DispatchQueueMainAsyncAfter(deadline: .now()+0.4, target: self, execute: {
                            if result == true {
                                showImagePicker()
                            } else {
                                showTextHUD("无法获取系统相机权限", inView: nil, hideAfterDelay: 1.8)
                            }
                        })
                    }
                } else {
                    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        DispatchQueueMainAsyncAfter(deadline: .now()+0.0, target: self, execute: {
                            showImagePicker()
                        })
                    } else {
                        showTextHUD("无法获取系统相机权限", inView: nil, hideAfterDelay: 1.8)
                    }
                }
            } else {
                if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                    PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                        DispatchQueueMainAsyncAfter(deadline: .now()+0.4, target: self, execute: {
                            if status == .authorized {
                                showImagePicker()
                            } else {
                                showTextHUD("无法获取系统相册权限", inView: nil, hideAfterDelay: 1.8)
                            }
                        })
                    }
                } else {
                    if PHPhotoLibrary.authorizationStatus() == .authorized {
                        DispatchQueueMainAsyncAfter(deadline: .now()+0.0, target: self, execute: {
                            showImagePicker()
                        })
                    } else {
                        showTextHUD("无法获取系统相册权限", inView: nil, hideAfterDelay: 1.8)
                    }
                }
            }
        }
    }
    // MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        coverButton.setImage(image, for: .normal)
        
        let coverTipLabel = coverButton.viewWithTag(1010) as! UILabel
        coverTipLabel.text = ""
        
        coverButton.viewWithTag(100)?.removeFromSuperview()
        
        coverImageUrl = ""
        coverImageData = image.jpegData(compressionQuality: 0.8)!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
