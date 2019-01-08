//
//  PostDetailViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/18.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class PostDetailViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!
    var postModel: PostModel!
    var fromHomePage: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "详情"
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(PostBaseCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        self.view.addSubview(tableView)
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PostBaseCell? = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") as? PostBaseCell
        if cell == nil {
            cell = PostBaseCell.init(style: PostBaseCell.CellStyle.default, reuseIdentifier: "cellIdentifier")
        }
        
        for view: UIView in cell!.subviews {
            if view.tag >= 10 {
                view.removeFromSuperview()
            }
        }
        
        cell?.selectionStyle = .none
        if indexPath.section == 0 {
            cell?.isDetail = true
            cell?.createPostBaseCell(postModel)
            
            cell?.postAuthorHandle = { [weak self] () -> Void in
                if self!.fromHomePage == false {
                    let myPageVC = MyPageViewController()
                    myPageVC.hidesBottomBarWhenPushed = true
                    if self!.postModel.author.userId != UserModel.fetchUser().userId {
                        myPageVC.account = self?.postModel.author
                    }
                    
                    self?.navigationController?.pushViewController(myPageVC, animated: true)
                } else {
                    if self!.postModel.author.userId != UserModel.fetchUser().userId {
                        let myPageVC = MyPageViewController()
                        myPageVC.hidesBottomBarWhenPushed = true
                        myPageVC.account = self?.postModel.author
                        self?.navigationController?.pushViewController(myPageVC, animated: true)
                    } else {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            cell?.postPraiseHandle = { [weak self] () -> Void in
                if AccountManager.accountLogin() == true {
                    let hud = indicatorTextHUD("")
                    Networking.publicPraiseRequest(params: ["objectId": self!.postModel.objectId, "praiseType": "0", "authorId": UserModel.fetchUser().userId], completionHandler: { (data, error) in
                        hud.hide(false)
                        
                        if error != nil {
                            showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                        } else {
                            let dict: [String: Bool] = data as! [String : Bool]
                            let isSuccessful: Bool = dict["isSuccessful"]!
                            
                            if self!.postModel.isPraise == true {
                                if isSuccessful == true {
                                    showTextHUD("取消点赞成功", inView: nil, hideAfterDelay: 1.8)
                                    
                                    self?.postModel.isPraise = false
                                    self?.postModel.praiseCount -= 1
                                    if self!.postModel.praiseCount < 0 {
                                        self?.postModel.praiseCount = 0
                                    }
                                    
                                    UserModel.updateUserInfo()
                                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                                } else {
                                    showTextHUD("取消点赞失败", inView: nil, hideAfterDelay: 1.8)
                                }
                            } else {
                                if isSuccessful == true {
                                    showTextHUD("点赞成功", inView: nil, hideAfterDelay: 1.8)
                                    
                                    self?.postModel.isPraise = true
                                    self?.postModel.praiseCount += 1
                                    
                                    UserModel.updateUserInfo()
                                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                                } else {
                                    showTextHUD("点赞失败", inView: nil, hideAfterDelay: 1.8)
                                }
                            }
                        }
                    })
                } else {
                    self?.publicLoginAction()
                }
            }
            
            cell?.postCollectionHandle = { [weak self] () -> Void in
                if AccountManager.accountLogin() == true {
                    let collectSelectionVC = CollectSelectionViewController()
                    collectSelectionVC.postModel = self?.postModel
                    collectSelectionVC.selectionFinishHandle = { [weak self] (isCollect) -> Void in
                        self?.postModel.isCollect = isCollect 
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    let nav = UINavigationController.init(rootViewController: collectSelectionVC)
                    self?.present(nav, animated: true, completion: nil)
                } else {
                    self?.publicLoginAction()
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return PostBaseCell.getPostBaseCellHeight(postModel, true)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
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
