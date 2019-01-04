//
//  TabPostViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/24.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias TapPostFinishLoadBlock = () -> Void

class TabPostViewController: BaseHideBarViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var tableView: UITableView!
    private var dataSources: [PostModel] = []
    
    private var currentPage: Int! = 0
    private var pageSize: Int! = 20
    
    var isHomePage: Bool! = false
    var isCollection: Bool! = false
    var userID: String! = ""
    var superFrame: CGRect! = CGRect.zero
    var collectionModel: CollectionModel!
    var finishLoadHandle: TapPostFinishLoadBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.frame = superFrame
        
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(PostBaseCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.view.addSubview(tableView)
        tableView.fixAreaInsets()
        
        tableView.setupRefresh(self, #selector(self.refreshPostData(_:)), #selector(self.loadMorePostData(_:)))
        tableView.mj_header.isHidden = false
        tableView.mj_footer.isHidden = false
        
        if isCollection == true {
            tableView.mj_header.isHidden = true
        }
    }
    // MARK: - 加载数据
    func pageRefreshData() -> Void {
        if isHomePage == true {
            if dataSources.count == 0 && userID.count > 0 {
                if tableView.mj_header != nil && tableView.mj_header.isRefreshing == false {
                    tableView.mj_header.beginRefreshing()
                }
            }
        } else if isCollection == true {
            let hud: MBProgressHUD = indicatorTextHUD("")
            self.refreshPostData(hud)
        } else {
            
        }
    }
    
    @objc private func refreshPostData(_ hud: MBProgressHUD?) -> Void {
        currentPage = 0
        self.requestPostData(hud)
    }
    
    @objc private func loadMorePostData(_ hud: MBProgressHUD?) -> Void {
        currentPage += 1
        self.requestPostData(hud)
    }
    
    @objc private func requestPostData(_ aHud: Any?) -> Void {
        var hud: MBProgressHUD = MBProgressHUD()
        if aHud != nil && aHud! is MBProgressHUD {
            hud = aHud! as! MBProgressHUD
        }
        
        if isHomePage == true {
            Networking.myPostListRequest(params: ["userId": userID!, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
                if error != nil {
                    hud.hide(false)
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
                    
                    hud.hide(true)
                }
                
                self?.tableView.mj_header.endRefreshing()
            }
        } else if isCollection == true {
            Networking.collectionPostListRequest(params: ["collectionId": collectionModel.objectId, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
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
                    hud.hide(true)
                }
                
                DispatchQueue.main.async(execute: {
                    if self?.finishLoadHandle != nil {
                        self?.finishLoadHandle!()
                    }
                })
            }
        } else {
            //搜索
        }
    }
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if isHomePage == true {
            return UIImage.init(named: "icon_placeholder_sentence")
        }
        
        return UIImage.init(named: "icon_placeholder_default")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributedString = NSMutableAttributedString.init(string: "这里什么都没有哦")
        let range = NSRange.init(location: 0, length: attributedString.string.count)
        attributedString.addAttributes([.font : kBaseFont(14)], range: range)
        attributedString.addAttributes([.foregroundColor : kRGBColor(red: 187, green: 188, blue: 189, alpha: 1)], range: range)
        
        return attributedString
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        if isHomePage == true {
            return -(tableView.bounds.size.height/5)
        }
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
        
        let model = dataSources[indexPath.section]
        cell?.createPostBaseCell(model)
        
        cell?.postAuthorHandle = { [weak self] () -> Void in
            var showHomePage: Bool = true
            if self?.isHomePage == true {
                if model.author.userId == self?.userID {
                    showHomePage = false
                }
            }
            
            if showHomePage == true {
                let postVC = MyPageViewController()
                postVC.hidesBottomBarWhenPushed = true
                postVC.account = model.author
                self?.navigationController?.pushViewController(postVC, animated: true)
            }
        }
        
        cell?.postFamousHandle = { [weak self] () -> Void in
            Log("famous")
        }
        
        cell?.postPraiseHandle = { [weak self] () -> Void in
            Log("praise")
        }
        
        cell?.postCommentHandle = { [weak self] () -> Void in
            let postDetailVC = PostDetailViewController()
            postDetailVC.postModel = model
            self?.navigationController?.pushViewController(postDetailVC, animated: true)
        }
        
        cell?.postCollectionHandle = { [weak self] () -> Void in
            Log("collection")
        }
        
        cell?.postShareHandle = { [weak self] () -> Void in
            Log("share")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataSources[indexPath.section] as! PostModel
        
        return PostBaseCell.getPostBaseCellHeight(model, false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSources[indexPath.section] as! PostModel
        
        let postDetailVC = PostDetailViewController()
        postDetailVC.postModel = model
        self.navigationController?.pushViewController(postDetailVC, animated: true)
        
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
