//
//  HomeViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class HomeViewController: BaseHideBarViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!
    private var personalHeader: HomeMyHeaderView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        UserModel.updateUserInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height-kTabBarHeight())~, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = kRGBColor(red: 237, green: 238, blue: 238, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1) 
        
        self.view.addSubview(tableView)
        
        if currentSafeAreaInsets().top > 0 {
            let statusBarView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: UIApplication.shared.statusBarFrame.size.height)~);
            statusBarView.backgroundColor = .white
            self.view.addSubview(statusBarView)
        }
        
        personalHeader = HomeMyHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)~)
        tableView.tableHeaderView = personalHeader
        personalHeader.homePageTapHandle = { [weak self] () -> Void in
            if AccountManager.accountLogin() == true {
                let myPageVC = MyPageViewController()
                myPageVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(myPageVC, animated: true)
            } else {
                self?.publicLoginAction()
            }
        }
        personalHeader.itemTapHandle = { [weak self] (index) -> Void in
            if AccountManager.accountLogin() == true {
                if index == 0 {
                    let mySubscribe = MySubscribeViewController()
                    mySubscribe.hidesBottomBarWhenPushed = true
                    mySubscribe.title = "我的订阅"
                    self?.navigationController?.pushViewController(mySubscribe, animated: true)
                } else if index == 1 {
                    let postVC = MyPostViewController() 
                    postVC.hidesBottomBarWhenPushed = true
                    postVC.title = "我的句子"
                    self?.navigationController?.pushViewController(postVC, animated: true)
                } else if index == 2 {
                    let favoriteVC = MyFavoriteViewController()
                    favoriteVC.hidesBottomBarWhenPushed = true
                    favoriteVC.title = "喜欢过的"
                    self?.navigationController?.pushViewController(favoriteVC, animated: true)
                }
            } else {
                self?.publicLoginAction()
            }
        }
        
        let tempView = UIView.init(frame: CGRect.init(x: 0, y: -kScreenHeight(), width: tableView.bounds.size.width, height: kScreenHeight())~)
        tempView.backgroundColor = .white
        tableView.insertSubview(tempView, at: 0) 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        personalHeader.refreshUserInfo()
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
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
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_message")
                cell?.textLabel?.text = "我的消息"
                break
            case 1:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_collect")
                cell?.textLabel?.text = "我的收藏夹"
                break
            case 2:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_comment")
                cell?.textLabel?.text = "我的评论"
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_guide")
                cell?.textLabel?.text = "常见问题"
                break
            case 1:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_feedback")
                cell?.textLabel?.text = "我要反馈"
                break
            case 2:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_recommend")
                cell?.textLabel?.text = "推荐句读"
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                cell?.imageView?.image = UIImage.init(named: "icon_mine_setting")
                cell?.textLabel?.text = "设置"
                break
            default:
                break
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        if indexPath.section == 0 {
            if AccountManager.accountLogin() == false {
                self.publicLoginAction()
            } else {
                switch indexPath.row {
                case 0:
                    let messageVC = MyMessageViewController()
                    messageVC.hidesBottomBarWhenPushed = true
                    messageVC.title = text
                    self.navigationController?.pushViewController(messageVC, animated: true)
                    
                    break
                case 1:
                    let collectionVC = MyCollectionViewController()
                    collectionVC.hidesBottomBarWhenPushed = true
                    collectionVC.title = text
                    self.navigationController?.pushViewController(collectionVC, animated: true)
                    
                    break
                case 2:
                    let commentVC = MyCommentViewController()
                    commentVC.hidesBottomBarWhenPushed = true
                    commentVC.title = text
                    self.navigationController?.pushViewController(commentVC, animated: true)
                    
                    break
                default:
                    break
                }
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                
                break
            case 1:
                
                break
            case 2:
                
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let settingVC = SettingViewController()
                settingVC.hidesBottomBarWhenPushed = true
                settingVC.title = text
                self.navigationController?.pushViewController(settingVC, animated: true)
                
                break
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - 注册测试用户
    func registerUser1() -> Void {
        // Admin
        Networking.adminRegisterRequest(mobile: "15217224985", password: "870704") { (userModel, error) in
            
        }
    }
    
    func registerUser2() -> Void {
        // Kaye
        Networking.adminRegisterRequest(mobile: "15217224986", password: "880312") { (userModel, error) in
            
        }
    }
    
    func registerUser3() -> Void {
        // 管理员
        Networking.adminRegisterRequest(mobile: "15217224987", password: "870704") { (userModel, error) in
            
        }
    }
    
    func registerUser4() -> Void {
        // 一地鸡毛
        Networking.mobileRegisterRequest(mobile: "15217224988", password: "870704") { (userModel, error) in
            
        }
    }
    
    func registerUser5() -> Void {
        // 迷路的孩子
        Networking.mobileRegisterRequest(mobile: "15217224989", password: "870704") { (userModel, error) in
            
        }
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
