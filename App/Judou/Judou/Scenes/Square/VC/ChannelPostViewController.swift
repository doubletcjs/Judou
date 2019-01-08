//
//  ChannelPostViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class ChannelPostViewController: BaseHideBarViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var tableView: UITableView!
    private var dataSources: [Any] = []
    private var currentPage: Int = 0
    private var pageSize: Int! = 20
    var channelName: String!
    var superFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.frame = superFrame
        
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        if channelName == "话题" {
            tableView.register(TopicCell.self, forCellReuseIdentifier: "TopicCellIdentifier")
        } else if channelName == "随笔" {
            tableView.register(EssayCell.self, forCellReuseIdentifier: "EssayCellIdentifier")
        } else {
            tableView.register(PostBaseCell.self, forCellReuseIdentifier: "PostCellIdentifier")
        }
        
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.view.addSubview(tableView)
        
        tableView.setupRefresh(self, #selector(self.refreshData), #selector(self.loadMoreData))
        tableView.mj_header.isHidden = false
        tableView.mj_footer.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRefreshStatus), name: kChangeLoginAccountNotification, object: nil)
        
        //推荐、订阅(名人收录)、广场(最新，包含收录或者原创)、原创(最新原创)、情感(标签爱情、亲情、友情)、励志(标签治愈、励志)、毒汤(标签毒汤)、英文(标签英文志) PostBaseCell
        
        //话题 TopicCell
        //随笔 cell3 未知
    }
    // MARK: - 加载数据
    @objc private func handleRefreshStatus() -> Void {
        if tableView.mj_header != nil && tableView.mj_header.isRefreshing == false {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    func pageRefreshData() -> Void {
        if dataSources.count == 0 {
            if tableView.mj_header != nil && tableView.mj_header.isRefreshing == false {
                tableView.mj_header.beginRefreshing()
            }
        }
    }
    
    @objc private func refreshData() -> Void {
        currentPage = 0
        
        if channelName == "话题" {
            self.requestTopicData()
        } else if channelName == "随笔" {
            self.requestEssayData()
        } else {
            self.requestPostData()
        }
    }
    
    @objc private func loadMoreData() -> Void {
        currentPage += 1
        
        if channelName == "话题" {
            self.requestTopicData()
        } else if channelName == "随笔" {
            self.requestEssayData()
        } else {
            self.requestPostData()
        }
    }
    
    @objc private func requestPostData() -> Void {
        if channelName == "广场" {
            Networking.squarePostListRequest(params: ["loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
                if error != nil {
                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                    
                    if self!.currentPage > 0 {
                        self?.currentPage -= 1
                        self?.tableView.mj_footer.endRefreshing()
                    }
                } else {
                    let array: [PostModel] = list as! [PostModel]
                    if self!.currentPage == 0 {
                        self?.dataSources = array
                    } else {
                        self?.dataSources = self!.dataSources+array
                    }
                    
                    self?.tableView.reloadData()
                    
                    if array.count < self!.pageSize {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self?.tableView.mj_footer.endRefreshing()
                    } 
                }
                
                self?.tableView.mj_header.endRefreshing()
            }
        } else {
            tableView.mj_header.endRefreshing()
        }
    }
    
    @objc private func requestTopicData() -> Void {
        tableView.mj_header.endRefreshing()
    }
    
    @objc private func requestEssayData() -> Void {
        tableView.mj_header.endRefreshing()
    }
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if channelName == "话题" {
            return UIImage.init(named: "icon_placeholder_default")
        } else if channelName == "随笔" {
            return UIImage.init(named: "icon_placeholder_default")
        } else {
            if channelName == "订阅" {
                return UIImage.init(named: "icon_placeholder_subscribe")
            }
            
            return UIImage.init(named: "icon_placeholder_sentence")
        }
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(tableView.bounds.size.height/6)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections-1 {
            return 0.01
        }
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if channelName == "话题" {
            var cell: TopicCell? = tableView.dequeueReusableCell(withIdentifier: "TopicCellIdentifier") as? TopicCell
            if cell == nil {
                cell = TopicCell.init(style: TopicCell.CellStyle.default, reuseIdentifier: "TopicCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
            cell?.selectionStyle = .none
            
            return cell!
        } else if channelName == "随笔" {
            var cell: EssayCell? = tableView.dequeueReusableCell(withIdentifier: "EssayCellIdentifier") as? EssayCell
            if cell == nil {
                cell = EssayCell.init(style: EssayCell.CellStyle.default, reuseIdentifier: "EssayCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
            cell?.selectionStyle = .none
            
            return cell!
        } else {
            var cell: PostBaseCell? = tableView.dequeueReusableCell(withIdentifier: "PostCellIdentifier") as? PostBaseCell
            if cell == nil {
                cell = PostBaseCell.init(style: PostBaseCell.CellStyle.default, reuseIdentifier: "PostCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
            cell?.selectionStyle = .none
            
            let model = dataSources[indexPath.section] as! PostModel
            cell?.createPostBaseCell(model)
             
            cell?.postAuthorHandle = { [weak self] () -> Void in
                let myPageVC = MyPageViewController()
                myPageVC.hidesBottomBarWhenPushed = true
                if model.author.userId != UserModel.fetchUser().userId {
                    myPageVC.account = model.author
                }
                
                self?.navigationController?.pushViewController(myPageVC, animated: true)
            }
            
            cell?.postFamousHandle = { [weak self] () -> Void in
                Log("famous")
            }
            
            cell?.postPraiseHandle = { [weak self] () -> Void in
                if AccountManager.accountLogin() == true {
                    let hud = indicatorTextHUD("")
                    Networking.publicPraiseRequest(params: ["objectId": model.objectId, "praiseType": "0", "authorId": UserModel.fetchUser().userId], completionHandler: { (data, error) in
                        hud.hide(false)
                        
                        if error != nil {
                            showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                        } else {
                            let dict: [String: Bool] = data as! [String : Bool]
                            let isSuccessful: Bool = dict["isSuccessful"]!
                            
                            if model.isPraise == true {
                                if isSuccessful == true {
                                    showTextHUD("取消点赞成功", inView: nil, hideAfterDelay: 1.8)
                                    
                                    model.isPraise = false
                                    model.praiseCount -= 1
                                    if model.praiseCount < 0 {
                                        model.praiseCount = 0
                                    }
                                    
                                    UserModel.updateUserInfo()
                                    self?.dataSources[indexPath.section] = model
                                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                                } else {
                                    showTextHUD("取消点赞失败", inView: nil, hideAfterDelay: 1.8)
                                }
                            } else {
                                if isSuccessful == true {
                                    showTextHUD("点赞成功", inView: nil, hideAfterDelay: 1.8)
                                    
                                    model.isPraise = true
                                    model.praiseCount += 1
                                    
                                    UserModel.updateUserInfo()
                                    self?.dataSources[indexPath.section] = model
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
            
            cell?.postCommentHandle = { [weak self] () -> Void in
                let postDetailVC = PostDetailViewController()
                postDetailVC.postModel = model
                postDetailVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(postDetailVC, animated: true)
            }
            
            cell?.postCollectionHandle = { [weak self] () -> Void in
                if AccountManager.accountLogin() == true {
                    let collectSelectionVC = CollectSelectionViewController()
                    collectSelectionVC.postModel = model
                    collectSelectionVC.selectionFinishHandle = { [weak self] (isCollect) -> Void in
                        model.isCollect = isCollect
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    let nav = UINavigationController.init(rootViewController: collectSelectionVC)
                    self?.present(nav, animated: true, completion: nil)
                } else {
                    self?.publicLoginAction()
                }
            }
            
            cell?.postShareHandle = { [weak self] () -> Void in
                Log("share")
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if channelName == "话题" {
            return 0
        } else if channelName == "随笔" {
            return 0
        } else {
            let model = dataSources[indexPath.section] as! PostModel
            
            return PostBaseCell.getPostBaseCellHeight(model, false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channelName == "话题" {
            
        } else if channelName == "随笔" {
            
        } else {
            let model = dataSources[indexPath.section] as! PostModel
            
            let postDetailVC = PostDetailViewController()
            postDetailVC.postModel = model
            postDetailVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(postDetailVC, animated: true)
        }
        
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
