//
//  MyInfoViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class MyInfoViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var tableView: UITableView!
    private var userInfoModel: UserModel! = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "修改资料"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .plain, target: self, action: #selector(self.saveInfoAction))
        
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = tableView.separatorColor?.withAlphaComponent(0.4)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        tableView.isHidden = true
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        UserModel.fetchUser { [weak self] (userModel) in
            self?.tableView.isHidden = false
            self?.userInfoModel = userModel
            self?.tableView.reloadData()
            
            hud.hide(true)
        }
        
        self.view.addSubview(tableView)
    }
    // MARK: - 保存
    @objc private func saveInfoAction() -> Void {
        
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
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
        return 4
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
        
        let cellHeight: CGFloat = 50
        let cellSpace: CGFloat = 34
        let cellTextColor = kRGBColor(red: 211, green: 212, blue: 212, alpha: 1)
        let cellTextFont = kBaseFont(15)
        var cellTag = 10
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "头像"
            let imageWH = cellHeight-8*2
            
            let imageView = UIImageView.init(frame: CGRect.init(x: tableView.bounds.size.width-imageWH-cellSpace, y: 8, width: imageWH, height: imageWH)~)
            imageView.layer.cornerRadius = imageView.frame.size.height/2
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            imageView.tag = cellTag
            cellTag += 1
            cell?.addSubview(imageView)
            imageView.sd_setImage(with: URL.init(string: userInfoModel.portrait),
                                  placeholderImage: UIImage.init(named: "topic_default_avatar"),
                                  options: SDWebImageOptions.init(rawValue: SDWebImageOptions.allowInvalidSSLCertificates.rawValue),
                                  completed: nil)
            
            break
        case 1:
            cell?.textLabel?.text = "昵称"
            
            let maxW = tableView.bounds.size.width/2+40
            let nickNameLabel = UILabel.init(frame: CGRect.init(x: tableView.bounds.size.width-maxW-cellSpace, y: 0, width: maxW, height: cellHeight)~)
            nickNameLabel.font = cellTextFont
            nickNameLabel.textColor = cellTextColor
            nickNameLabel.textAlignment = .right
            nickNameLabel.text = userInfoModel.nickname
            nickNameLabel.tag = cellTag
            cellTag += 1
            cell?.addSubview(nickNameLabel)
            
            break
        case 2:
            cell?.textLabel?.text = "性别"
            
            let genderLabel = UILabel.init()
            genderLabel.font = cellTextFont
            genderLabel.textColor = cellTextColor
            genderLabel.textAlignment = .right
            genderLabel.text = "未知"
            if userInfoModel.gender == 1 {
                genderLabel.text = "男"
            } else if userInfoModel.gender == 2 {
                genderLabel.text = "女"
            }
            
            genderLabel.tag = cellTag
            cellTag += 1
            cell?.addSubview(genderLabel)
            genderLabel.sizeToFit()
            genderLabel.frame = CGRect.init(x: tableView.bounds.size.width-genderLabel.frame.size.width-cellSpace, y: 0, width: genderLabel.frame.size.width, height: cellHeight)~
            
            break
        case 3:
            cell?.textLabel?.text = "生日"
            
            let birthdayLabel = UILabel.init()
            birthdayLabel.font = cellTextFont
            birthdayLabel.textColor = cellTextColor
            birthdayLabel.textAlignment = .right
            birthdayLabel.text = "未知"
            if isStringEmpty(userInfoModel.birthday) == false {
                birthdayLabel.text = userInfoModel.birthday
            }
            
            birthdayLabel.tag = cellTag
            cellTag += 1
            cell?.addSubview(birthdayLabel)
            birthdayLabel.sizeToFit()
            birthdayLabel.frame = CGRect.init(x: tableView.bounds.size.width-birthdayLabel.frame.size.width-cellSpace, y: 0, width: birthdayLabel.frame.size.width, height: cellHeight)~
            break
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50~
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
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
            
            break
        case 1:
            break
        case 2:
            let actionSheet: JSActionSheet = JSActionSheet.init(title: nil, cancelTitle: "取消", otherTitles: ["男", "女"])
            if userInfoModel.gender > 0 {
                actionSheet.destructiveButtonIndex = userInfoModel.gender-1
                actionSheet.destructiveColor = kRGBColor(red: 200, green: 114, blue: 99, alpha: 1)
            }
            actionSheet.showView()
            actionSheet.dismiss(forCompletionHandle: { [weak self] (index, isCancel) in
                if isCancel == false && self?.userInfoModel!.gender != index+1 {
                    DispatchQueueMainAsyncAfter(deadline: .now(), target: self, execute: {
                        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
                        
                        Networking.editUserInfo(["gender": index+1], completionHandler: { [weak self] (isSuccessful, aError) in
                            if self != nil {
                                if isSuccessful == true {
                                    hud.hide(true)
                                    self?.userInfoModel?.gender = index+1
                                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                                } else {
                                    hud.hide(false)
                                    showTextHUD(aError!.localizedDescription, inView: nil, hideAfterDelay: 1.8)
                                }
                            }
                        })
                    })
                }
            })
            break
        case 3: 
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
