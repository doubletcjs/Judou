//
//  AccountListViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/22.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class AccountListViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var tableView: UITableView!
    private var dataSources: [UserModel] = []
    
    private var currentPage: Int! = 0
    private var pageSize: Int! = 20
    
    var isFan: Bool! = false
    var userId: String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(AccountListCell.self, forCellReuseIdentifier: "AccountCellIdentifier")
        
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        tableView.separatorColor = kRGBColor(red: 237, green: 238, blue: 238, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.view.addSubview(tableView)
        
        tableView.setupRefresh(self, #selector(self.refreshAccountData), #selector(self.loadMoreAccountData))
        tableView.mj_header.isHidden = false
        tableView.mj_footer.isHidden = false
        
        self.refreshAccountData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    // MARK: - 加载数据
    @objc private func refreshAccountData() -> Void {
        currentPage = 0
        self.requestAccountData()
    }
    
    @objc private func loadMoreAccountData() -> Void {
        currentPage += 1
        self.requestAccountData()
    }
    
    @objc private func requestAccountData() -> Void {
        if isFan == true {
            Networking.fanListRequest(params: ["userId": userId!, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
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
        } else {
            Networking.attentionListRequest(params: ["userId": userId!, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
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
        if isFan == true {
            return UIImage.init(named: "icon_placeholder_fans")
        }
        
        return UIImage.init(named: "icon_placeholder_follow")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(tableView.bounds.size.height/6)
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
        return dataSources.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell?.createAccountCell(dataSources[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let space: CGFloat = 16
        let imageWH: CGFloat = 50
        let cellHeight: CGFloat = imageWH+space*2
        
        return cellHeight
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
