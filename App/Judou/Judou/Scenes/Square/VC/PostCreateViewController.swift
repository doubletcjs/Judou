//
//  PostCreateViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class PostCreateViewController: BaseShowBarViewController, SGPageTitleViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var pageTitleView: SGPageTitleView!
    private var tableView: UITableView!
    private var currentPage: Int! = 0
    private var textView: UITextView!
    private var labelButton: UIButton!
    private var imageButton: UIButton!
    private var textViewHeight: CGFloat!
    private var baseBottomHeight: CGFloat!
    
    private var labelModel: LabelModel!
    private var isPrivate: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.postCloseAction))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_send"), style: .plain, target: self, action: #selector(self.postSendAction))
        
        let titleViewConfigure: SGPageTitleViewConfigure = SGPageTitleViewConfigure()
        titleViewConfigure.showBottomSeparator = false
        titleViewConfigure.indicatorStyle = SGIndicatorStyleDefault
        
        titleViewConfigure.indicatorColor = kRGBColor(red: 170, green: 152, blue: 107, alpha: 1)
        titleViewConfigure.indicatorHeight = 1.5
        
        titleViewConfigure.titleFont = kBaseFont(17)
        titleViewConfigure.titleSelectedFont = kBaseFont(17)
        titleViewConfigure.titleSelectedColor = kRGBColor(red: 183, green: 167, blue: 119, alpha: 1)
        titleViewConfigure.titleColor = .black
        
        pageTitleView = SGPageTitleView.init(frame: CGRect.init(x: 0, y: 0, width: 44*2+30, height: self.navigationController!.navigationBar.frame.size.height)~, delegate: self, titleNames: ["收录", "原创"], configure: titleViewConfigure)
        self.navigationItem.titleView = pageTitleView
        
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = tableView.separatorColor?.withAlphaComponent(0.4)
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
    // MARK: - SGPageTitleViewDelegate
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        currentPage = selectedIndex
        tableView.reloadData()
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.size.width, height: 40)~)
            headerView.backgroundColor = tableView.backgroundColor
            headerView.contentHorizontalAlignment = .left
            headerView.setImage(UIImage.init(named: "icon_post_tip"), for: .normal)
            headerView.titleLabel?.font = kBaseFont(12)
            headerView.setTitleColor(kRGBColor(red: 217, green: 219, blue: 220, alpha: 1), for: .normal)
            headerView.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: tableView.separatorInset.left, bottom: 0, right: 0)~
            headerView.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: tableView.separatorInset.left+6, bottom: 0, right: 0)~
            headerView.isUserInteractionEnabled = false
            
            if currentPage == 0 {
                headerView.setTitle("收录功能可以用来分享你看到的好句子", for: .normal)
            } else {
                headerView.setTitle("原创功能可以用来分享你原创的好句子", for: .normal)
            }
            
            return headerView
        }
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if currentPage == 0 {
                return 2
            } else {
                return 1
            }
        } else {
            return 0
        }
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
        
        cell?.textLabel?.font = kBaseFont(17)
        cell?.accessoryView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
        cell?.imageView?.image = nil
        
        if indexPath.section == 0 {
            cell?.selectionStyle = .none
            cell?.accessoryView = nil
            
            if textView == nil {
                let miniTextHeight: CGFloat = 120
                textView = UITextView.init(frame: CGRect.init(x: tableView.separatorInset.left, y: 20, width: tableView.bounds.size.width-tableView.separatorInset.left*2, height: miniTextHeight)~)
                textView.font = kBaseFont(15)
                textView.js_placeholder = "写下你要收录的句子..."
                textView.js_placeholderColor = kRGBColor(red: 221, green: 222, blue: 223, alpha: 1)
                textView.tag = 10
                textView.js_autoHeight(withMaxHeight: CGFloat(MAXFLOAT)) { [weak self] (currentTextViewHeight) in
                    func changeItemFrame(_ changedHeight: CGFloat) -> Void {
                        var frame = self!.textView.frame
                        frame.size.height = changedHeight
                        self?.textView.frame = frame
                        self?.textViewHeight = self?.textView.frame.maxY
                        
                        frame = self!.labelButton.frame
                        frame.origin.y = self!.textViewHeight+20
                        self?.labelButton.frame = frame
                        
                        frame = self!.imageButton.frame
                        frame.origin.y = self!.labelButton.frame.maxY+12
                        self?.imageButton.frame = frame
                        
                        self?.tableView.beginUpdates()
                        self?.tableView.endUpdates()
                    }
                    
                    if currentTextViewHeight > miniTextHeight {
                        changeItemFrame(currentTextViewHeight)
                    } else {
                        if currentTextViewHeight != miniTextHeight {
                            changeItemFrame(miniTextHeight)
                        }
                    }
                }
                
                textViewHeight = textView.frame.maxY
                baseBottomHeight = 20+26+12+80+20
            }
            
            if currentPage == 0 {
                textView.js_placeholder = "写下你要收录的句子..."
            } else {
                textView.js_placeholder = "写下属于你的句子..."
            }
            cell?.addSubview(textView)
            
            //话题
            if labelButton == nil {
                labelButton = UIButton.init(type: .custom)
                labelButton.tag = 11
                labelButton.addTarget(self, action: #selector(self.selectLabelAction), for: .touchUpInside)
            }
            
            if labelModel == nil {
                labelButton.setTitle("添加标签", for: .normal)
            } else {
                labelButton.setTitle(labelModel.title, for: .normal)
            }
            
            let arrowImage: UIImage = UIImage.init(named: "icon_golden_arrow")!
            labelButton.titleLabel?.font = kBaseFont(14)
            labelButton.setTitleColor(kRGBColor(red: 183, green: 167, blue: 119, alpha: 1), for: .normal)
            labelButton.setImage(arrowImage, for: .normal)
            cell?.addSubview(labelButton)
            labelButton.sizeToFit()
            
            let labelSpace: CGFloat = 10
            let arrowSpace: CGFloat = 8
            let labelButtonWidth: CGFloat = labelButton.frame.size.width+arrowImage.size.width+labelSpace*2
            let edgeInsetsSpace: CGFloat = labelButtonWidth-(arrowImage.size.width+arrowSpace)
            
            labelButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -arrowImage.size.width-labelSpace, bottom: 0, right: 0)~
            labelButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: edgeInsetsSpace, bottom: 0, right: 0)~
            
            labelButton.frame = CGRect.init(x: tableView.separatorInset.left, y: textViewHeight+20, width: labelButtonWidth, height: 26)~
            labelButton.layer.cornerRadius = labelButton.frame.size.height/2
            labelButton.layer.borderWidth = 0.8
            labelButton.layer.borderColor = kRGBColor(red: 183, green: 167, blue: 119, alpha: 1).cgColor
            
            //图片
            if imageButton == nil {
                imageButton = UIButton.init(type: .custom)
                imageButton.tag = 12
                imageButton.imageView?.contentMode = .scaleAspectFill
                imageButton.contentMode = .scaleAspectFill
                imageButton.clipsToBounds = true
                imageButton.setImage(UIImage.init(named: "icon_pic_add"), for: .normal)
                imageButton.imageView?.contentMode = .scaleAspectFit
                
                imageButton.handleControlEvent(controlEvent: .touchUpInside) { [weak self] (sender) in
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
            }
            
            imageButton.frame = CGRect.init(x: tableView.separatorInset.left, y: labelButton.frame.maxY+12, width: 80, height: 80)~
            cell?.addSubview(imageButton)
            
        } else if indexPath.section == 1 {
            cell?.selectionStyle = .default
            
            switch indexPath.row {
            case 0:
                if currentPage == 0 {
                    cell?.textLabel?.text = "添加作者"
                    cell?.imageView?.image = UIImage.init(named: "icon_post_author")
                } else {
                    cell?.textLabel?.text = "设为私密"
                    cell?.imageView?.image = UIImage.init(named: "icon_post_private")
                    cell?.selectionStyle = .none
                    
                    let privateSwitch = UISwitch.init()
                    privateSwitch.isOn = isPrivate
                    privateSwitch.addTarget(self, action: #selector(self.privateSwitch), for: .touchUpInside)
                    
                    cell?.accessoryView = privateSwitch
                }
                break
            case 1:
                if currentPage == 0 {
                    cell?.textLabel?.text = "添加出处"
                    cell?.imageView?.image = UIImage.init(named: "icon_post_reference")
                }
                break
            default:
                break
            }
        }
     
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return textViewHeight+baseBottomHeight
        } else {
            return 50~
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textView.resignFirstResponder()
        
        if currentPage == 0 && indexPath.section == 1 {
            let addFunctionVC = AddFunctionViewController()
            addFunctionVC.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
            if indexPath.row == 0 {
                addFunctionVC.selectAuthor = true
            }
            
            let nav = UINavigationController.init(rootViewController: addFunctionVC)
            
            self.present(nav, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - 选择标签
    @objc private func selectLabelAction() -> Void {
        let labelCenterVC = LabelCenterViewController()
        let nav = UINavigationController.init(rootViewController: labelCenterVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - 是否私密
    @objc private func privateSwitch() -> Void {
        isPrivate = !isPrivate
        tableView.reloadRows(at: [IndexPath.init(row: 0, section: 1)], with: .none)
    }
    // MARK: - 发布帖子
    @objc private func postSendAction() -> Void {
        if isStringEmpty(textView.text) == true && textView.text.count < 6 {
            showTextHUD("至少6个字符～", inView: nil, hideAfterDelay: 1.5)
            return
        } 
        
        textView.resignFirstResponder()
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
        
        let image = info[UIImagePickerController.InfoKey.editedImage]
        imageButton.setImage(image as? UIImage, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    // MARK: - 关闭
    @objc private func postCloseAction() -> Void {
        textView.resignFirstResponder()
        
        DispatchQueueMainAsyncAfter(deadline: .now()+0.3, target: self, execute: {
            self.dismiss(animated: true, completion: nil)
        })
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
