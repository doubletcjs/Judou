//
//  SearchListViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/24.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class SearchListViewController: BaseHideBarViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    var searchType: String!
    var superFrame: CGRect!
    private var tableView: UITableView!
    private var dataSources: [Any] = []
    
    private var currentPage: Int! = 0
    private var pageSize: Int! = 20
    private var searchKey: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.frame = superFrame
        
        if searchType == "句子" {
            tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.register(PostBaseCell.self, forCellReuseIdentifier: "cellIdentifier")
            tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
        } else {
            tableView = UITableView.init(frame: self.view.bounds, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorColor = kRGBColor(red: 237, green: 238, blue: 238, alpha: 1)
            tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
        }
        
        if searchType == "作者" {
            tableView.register(FamousCell.self, forCellReuseIdentifier: "FamousCellIdentifier")
        } else if searchType == "出处" {
            tableView.register(BookCell.self, forCellReuseIdentifier: "BookCellIdentifier")
        } else if searchType == "句子" {
            tableView.register(PostBaseCell.self, forCellReuseIdentifier: "PostCellIdentifier")
        } else {
            tableView.register(AccountListCell.self, forCellReuseIdentifier: "AccountCellIdentifier")
        }
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.view.addSubview(tableView)
        tableView.fixAreaInsets()
        
        tableView.setupRefresh(self, #selector(self.refreshSearchData), #selector(self.loadMoreSearchData))
        tableView.mj_header.isHidden = false
        tableView.mj_footer.isHidden = false 
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRefreshStatus), name: kChangeLoginAccountNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    // MARK: - 加载数据
    @objc private func handleRefreshStatus() -> Void {
        if tableView.mj_header != nil && tableView.mj_header.isRefreshing == false && searchKey.count > 0 {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    func pageRefreshData(_ key: String) -> Void {
        searchKey = key
        if dataSources.count == 0 && searchKey.count > 0 {
            if tableView.mj_header != nil && tableView.mj_header.isRefreshing == false {
                tableView.mj_header.beginRefreshing()
            }
        }
    }
    
    @objc private func refreshSearchData() -> Void {
        currentPage = 0
        self.requestSearchData()
    }
    
    @objc private func loadMoreSearchData() -> Void {
        currentPage += 1
        self.requestSearchData()
    }
    
    @objc private func requestSearchData() -> Void {
        if searchType == "作者" {
            tableView.mj_header.endRefreshing()
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else if searchType == "出处" {
            tableView.mj_header.endRefreshing()
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else if searchType == "句子" {
            Networking.postSearchListRequest(params: ["searchKey": searchKey!, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
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
            Networking.accountSearchListRequest(params: ["searchKey": searchKey!, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
                if error != nil {
                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                    
                    if self!.currentPage > 0 {
                        self?.currentPage -= 1
                        self?.tableView.mj_footer.endRefreshing()
                    }
                } else {
                    let array: [UserModel] = list as! [UserModel]
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
        }
    }
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "icon_placeholder_default")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(tableView.bounds.size.height/5)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributedString = NSMutableAttributedString.init(string: "这里什么都没有哦")
        let range = NSRange.init(location: 0, length: attributedString.string.count)
        attributedString.addAttributes([.font : kBaseFont(14)], range: range)
        attributedString.addAttributes([.foregroundColor : kRGBColor(red: 187, green: 188, blue: 189, alpha: 1)], range: range)
        
        return attributedString
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if searchType == "句子" {
            if section == tableView.numberOfSections-1 {
                return 0.01
            }
            
            return 10
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchType == "句子" {
            return dataSources.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchType == "句子" {
            return 1
        }
        
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchType == "作者" {
            var cell: FamousCell? = tableView.dequeueReusableCell(withIdentifier: "FamousCellIdentifier") as? FamousCell
            if cell == nil {
                cell = FamousCell.init(style: FamousCell.CellStyle.default, reuseIdentifier: "FamousCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
            cell?.selectionStyle = .none
            cell?.createFamousCell(dataSources[indexPath.row] as! FamousModel)
            
            return cell!
        } else if searchType == "出处" {
            var cell: BookCell? = tableView.dequeueReusableCell(withIdentifier: "BookCellIdentifier") as? BookCell
            if cell == nil {
                cell = BookCell.init(style: BookCell.CellStyle.default, reuseIdentifier: "BookCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
            cell?.selectionStyle = .none
            cell?.createBookCell(dataSources[indexPath.row] as! BookModel)
            
            return cell!
        } else if searchType == "句子" {
            var cell: PostBaseCell? = tableView.dequeueReusableCell(withIdentifier: "PostCellIdentifier") as? PostBaseCell
            if cell == nil {
                cell = PostBaseCell.init(style: PostBaseCell.CellStyle.default, reuseIdentifier: "PostCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
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
                                    NotificationCenter.default.post(name: kSquarePostUpdateNotification, object: model)
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
                                    NotificationCenter.default.post(name: kSquarePostUpdateNotification, object: model)
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
                self?.navigationController?.pushViewController(postDetailVC, animated: true)
            }
            
            cell?.postCollectionHandle = { [weak self] () -> Void in
                if AccountManager.accountLogin() == true {
                    let collectSelectionVC = CollectSelectionViewController()
                    collectSelectionVC.postModel = model
                    collectSelectionVC.selectionFinishHandle = { [weak self] (isCollect) -> Void in
                        model.isCollect = isCollect
                        self?.dataSources[indexPath.section] = model
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                        NotificationCenter.default.post(name: kSquarePostUpdateNotification, object: model)
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
        } else {
            var cell: AccountListCell? = tableView.dequeueReusableCell(withIdentifier: "AccountCellIdentifier") as? AccountListCell
            if cell == nil {
                cell = AccountListCell.init(style: AccountListCell.CellStyle.default, reuseIdentifier: "AccountCellIdentifier")
            }
            
            for view: UIView in cell!.subviews {
                if view.tag >= 10 {
                    view.removeFromSuperview()
                }
            }
            
            cell?.selectionStyle = .none
            let accountModel = dataSources[indexPath.row] as! UserModel
            
            cell?.createAccountCell(accountModel)
            
            cell?.attentionHandle = { [weak self] () -> Void in
                if AccountManager.accountLogin() == true {
                    let hud = indicatorTextHUD("")
                    Networking.accountAttentionRequest(params: ["loginId": UserModel.fetchUser().userId, "userId": accountModel.userId]) { [weak self] (data, error) in
                        if error != nil {
                            hud.hide(false)
                            showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                        } else {
                            let dict: [String: Any] = data as! [String : Any]
                            let isSuccessful: Bool = dict["isSuccessful"]! as! Bool
                            var status: Int = 0 //0 查询失败 不改变状态 1 已关注 2 未关注
                            if dict["status"] != nil {
                                status = dict["status"]! as! Int
                            }
                            
                            if isSuccessful == true {
                                hud.hide(true)
                                
                                if status > 0 {
                                    var isAttention: Bool = accountModel.isAttention
                                    if status == 1 {
                                        isAttention = true
                                        accountModel.attentionCount += 1
                                    } else if status == 2 {
                                        isAttention = false
                                        accountModel.attentionCount -= 1
                                        if accountModel.attentionCount < 0 {
                                            accountModel.attentionCount = 0
                                        }
                                    }
                                    
                                    accountModel.isAttention = isAttention
                                    self?.dataSources[indexPath.row] = accountModel
                                    self?.tableView.reloadRows(at: [indexPath], with: .none) 
                                }
                            } else {
                                hud.hide(false)
                                showTextHUD("操作失败", inView: nil, hideAfterDelay: 1.5)
                            }
                        }
                    }
                } else {
                    self?.publicLoginAction()
                }
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchType == "作者" {
            return 88
        } else if searchType == "出处" {
            return 88
        }  else if searchType == "句子" {
            let model = dataSources[indexPath.section] as! PostModel
            
            return PostBaseCell.getPostBaseCellHeight(model, false)
        } else {
            let space: CGFloat = 16
            let imageWH: CGFloat = 50
            let cellHeight: CGFloat = imageWH+space*2
            
            return cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchType == "作者" {
            
        } else if searchType == "出处" {
            
        } else {
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - delloc
    deinit {
        NotificationCenter.default.removeObserver(self, name: kChangeLoginAccountNotification, object: nil)
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
