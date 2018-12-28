//
//  TabPostViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/24.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class TabPostViewController: BaseHideBarViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var tableView: UITableView!
    private var dataSources: [Any] = []
    private var currentPage: Int = 0
    
    var isHomePage: Bool! = false
    var superFrame: CGRect! = CGRect.zero

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
    }
    // MARK: - 加载数据
    @objc private func refreshPostData() -> Void {
        currentPage = 0
        self.requestPostData()
    }
    
    @objc private func loadMorePostData() -> Void {
        currentPage += 1
        self.requestPostData()
    }
    
    @objc private func requestPostData() -> Void {
        
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
            return -(tableView.bounds.size.height/4)
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
        
        let model = dataSources[indexPath.section] as! PostModel
        cell?.createPostBaseCell(model)
        
        cell?.postAuthorHandle = { [weak self] () -> Void in
            Log("author")
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
