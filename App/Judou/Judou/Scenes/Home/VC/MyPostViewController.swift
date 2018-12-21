//
//  MyPostViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class MyPostViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var tableView: UITableView!
    var isMyPost: Bool! = false // false 喜欢的帖子 true 我的帖子
    var superFrame: CGRect! = CGRect.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if superFrame != CGRect.zero { 
            self.view.frame = superFrame
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            if isMyPost == true {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_add"), style: .plain, target: self, action: #selector(self.goCreatePost))
            } else { 
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_search"), style: .plain, target: self, action: #selector(self.goSearchPost))
            }
        }
        
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
        
        if superFrame != CGRect.zero {
            if #available(iOS 11.0, *) {
                if UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0 && UIApplication.shared.keyWindow!.safeAreaInsets.bottom != tableView.contentInset.bottom {
                    var contentInset: UIEdgeInsets = tableView.contentInset
                    contentInset.bottom = tableView.contentInset.bottom+UIApplication.shared.keyWindow!.safeAreaInsets.bottom
                    tableView.contentInset = contentInset
                }
            }
        }
        
    }
    // MARK: - 搜索
    @objc private func goSearchPost() -> Void {
        let searchPostVC = PostSearchViewController()
        searchPostVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(searchPostVC, animated: true)
    }
    // MARK: - 发布
    @objc private func goCreatePost() -> Void {
        let createPostVC = PostCreateViewController()
        let nav = UINavigationController.init(rootViewController: createPostVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if isMyPost == true {
            return UIImage.init(named: "icon_placeholder_sentence")
        }
        
        return UIImage.init(named: "icon_placeholder_favourite")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var tip = "你还没有发布过句子"
        if isMyPost == false {
            tip = "你还没有喜欢的句子"
        }
        
        let attributedString = NSMutableAttributedString.init(string: tip)
        let range = NSRange.init(location: 0, length: attributedString.string.count)
        attributedString.addAttributes([.font : kBaseFont(14)], range: range)
        attributedString.addAttributes([.foregroundColor : kRGBColor(red: 187, green: 188, blue: 189, alpha: 1)], range: range)
        
        return attributedString
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(tableView.bounds.size.height/4)
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
        return 0
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
        cell?.createPostBaseCell(PostModel())
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostBaseCell.getPostBaseCellHeight(PostModel(), false)
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
