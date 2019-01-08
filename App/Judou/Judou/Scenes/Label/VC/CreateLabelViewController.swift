//
//  CreateLabelViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/16.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class CreateLabelViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var tableView: UITableView!
    private var textField: UITextField!
    private var coverButton: UIButton!
    private var coverImageData: Data! = Data()
    private var coverImageUrl: String! = ""
    
    var creationCompletionHandle: CreationCompletionBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "创建标签"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.labelCloseAction)) 
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_done"), style: .plain, target: self, action: #selector(self.createLabelAction))
        
        tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
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
        
        if indexPath.row == 1 {
            cell?.backgroundColor = .white
            
            if textField == nil {
                textField = UITextField.init(frame: CGRect.init(x: tableView.separatorInset.left, y: (70-60)/2, width: tableView.bounds.size.width-tableView.separatorInset.left*2, height: 60)~)
                textField.placeholder = "名称（2-6个字）"
                textField.font = kBaseFont(15)
                textField.tag = 10
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
                coverTipLabel.tag = 100
                coverButton.addSubview(coverTipLabel)
                coverTipLabel.sizeToFit()
                coverTipLabel.frame = CGRect.init(x: (coverButton.frame.size.width-coverTipLabel.frame.size.width)/2, y: coverButton.frame.size.height-coverTipLabel.frame.size.height-14, width: coverTipLabel.frame.size.width, height: coverTipLabel.frame.size.height)~
            }
            
            cell?.addSubview(coverButton)
        } else if indexPath.row == 2 {
            let tipButton = UIButton.init(frame: CGRect.init(x: tableView.separatorInset.left, y: 0, width: tableView.bounds.size.width-tableView.separatorInset.left*2, height: 60)~)
            tipButton.contentHorizontalAlignment = .left
            tipButton.setImage(UIImage.init(named: "icon_post_tip"), for: .normal)
            tipButton.titleLabel?.font = kBaseFont(12)
            tipButton.setTitleColor(kRGBColor(red: 213, green: 214, blue: 215, alpha: 1), for: .normal)
            tipButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: tableView.separatorInset.left, bottom: 0, right: 0)~
            tipButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: tableView.separatorInset.left+6, bottom: 0, right: 0)~
            tipButton.isUserInteractionEnabled = false
            tipButton.setTitle("创建后需要管理员审核通过后方可显示", for: .normal)
            tipButton.tag = 12
            cell?.addSubview(tipButton)
        }
     
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 190
        } else if indexPath.row == 1 {
            return 70
        } else if indexPath.row == 2 {
            return 60
        } else {
            return 0
        }
    }
    // MARK: - 添加标签
    @objc private func createLabelAction() -> Void {
        if isStringEmpty(textField.text) == true || textField.text!.count < 2 || textField.text!.count > 4 {
            showTextHUD("名称为2-4个字", inView: nil, hideAfterDelay: 1.8)
            
            return
        }
        
        if coverImageData.count == 0 && coverImageUrl.count == 0 {
            showTextHUD("尚未添加封面", inView: nil, hideAfterDelay: 1.8)
            
            return
        }
        
        textField.resignFirstResponder()
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)!
        hud.mode = .determinate
        
        func createLabelRequest(_ hud: MBProgressHUD, _ coverUrl: String) -> Void {
            var status: Int = 0
            if UserModel.fetchUser().level == 0 {
                status = 3
            }
            
            Networking.functionCreationRequest(params: ["authorId": UserModel.fetchUser().userId,
                                                        "title": textField.text!,
                                                        "cover": coverUrl,
                                                        "status": status],
                                               function: "label") { [weak self] (isSuccessful, error) in
                                                hud.hide(false)
                                                
                                                if isSuccessful == true {
                                                    if self?.creationCompletionHandle != nil {
                                                        self?.creationCompletionHandle!(nil)
                                                    }
                                                    
                                                    if status == 0 {
                                                        showTextHUD("创建成功,待管理员审核通过后方可显示", inView: nil, hideAfterDelay: 1.5)
                                                    }
                                                    self?.labelCloseAction()
                                                } else {
                                                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                                                }
            }
        }
        
        if coverImageData.count > 0 {
            Networking.fileUploadFunction(fileDataList: [coverImageData], function: "label", progressHandler: { (progress) in
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
                        createLabelRequest(hud, fileUrl)
                    } else {
                        hud.hide(false)
                        showTextHUD("文件地址返回为空～", inView: nil, hideAfterDelay: 1.5)
                    }
                }
            }
        } else if coverImageUrl.count > 0 {
            hud.mode = .indeterminate
            createLabelRequest(hud, coverImageUrl)
        }
    }
    // MARK: - 关闭
    @objc private func labelCloseAction() -> Void {
        textField.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
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
        coverButton.viewWithTag(100)?.removeFromSuperview()
        
        coverImageUrl = ""
        coverImageData = image.jpegData(compressionQuality: 0.8)!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    // MARK: -
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
