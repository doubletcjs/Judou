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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.frame = superFrame
        
        tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if searchType == "作者" {
            tableView.register(FamousCell.self, forCellReuseIdentifier: "FamousCellIdentifier")
        } else if searchType == "出处" {
            tableView.register(BookCell.self, forCellReuseIdentifier: "BookCellIdentifier")
        } else {
            tableView.register(AccountListCell.self, forCellReuseIdentifier: "AccountCellIdentifier")
        }
        
        tableView.separatorColor = kRGBColor(red: 237, green: 238, blue: 238, alpha: 1)
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        self.view.addSubview(tableView)
        tableView.fixAreaInsets() 
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
            cell?.createAccountCell(dataSources[indexPath.row] as! UserModel)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchType == "作者" {
            return 88
        } else if searchType == "出处" {
            return 88
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
