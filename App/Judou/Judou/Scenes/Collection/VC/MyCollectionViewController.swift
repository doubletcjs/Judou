//
//  MyCollectionViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class MyCollectionViewController: BaseShowBarViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var collectionView: UICollectionView!
    private var dataSources: [CollectionModel]! = []
    
    private var currentPage: Int! = 0
    private var pageSize: Int! = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_add"), style: .plain, target: self, action: #selector(self.createCollectioAction))
        
        let flowLayout = UICollectionViewFlowLayout.init()
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "LabelCenterItemCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        self.view.addSubview(collectionView)
        
        collectionView.setupRefresh(self, #selector(self.refreshCollection), #selector(self.loadMoreCollection))
        collectionView.mj_header.isHidden = false
        collectionView.mj_footer.isHidden = false
        
        self.refreshCollection()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCollection), name: kCollectSelectionNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    // MARK: - 获取收藏夹列表
    @objc private func refreshCollection() -> Void {
        currentPage = 0
        self.requestCollectionList()
    }
    
    @objc private func loadMoreCollection() -> Void {
        currentPage += 1
        self.requestCollectionList()
    }
    
    @objc private func requestCollectionList() -> Void {
        Networking.collectionListRequest(params: ["userId": UserModel.fetchUser().userId, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
            if error != nil {
                showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                
                if self!.currentPage > 0 {
                    self?.currentPage -= 1
                    self?.collectionView.mj_footer.endRefreshing()
                }
            } else {
                let array: [CollectionModel] = list as! [CollectionModel]
                if self!.currentPage == 0 {
                    self?.dataSources = array
                } else {
                    self?.dataSources = self!.dataSources+array
                }
                
                self?.collectionView.reloadData()
                
                if array.count < self!.pageSize {
                    self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self?.collectionView.mj_footer.endRefreshing()
                }
            }
            
            self?.collectionView.mj_header.endRefreshing()
        }
    }
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "icon_placeholder_default")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(collectionView.bounds.size.height/6)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributedString = NSMutableAttributedString.init(string: "你还没有创建过收藏夹哦")
        let range = NSRange.init(location: 0, length: attributedString.string.count)
        attributedString.addAttributes([.font : kBaseFont(14)], range: range)
        attributedString.addAttributes([.foregroundColor : kRGBColor(red: 187, green: 188, blue: 189, alpha: 1)], range: range)
        
        return attributedString
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    // MARK: - 添加收藏夹
    @objc private func createCollectioAction() -> Void {
        let creationVC = CreationViewController()
        creationVC.creationCompletionHandle = { [weak self] (model) -> Void in
            self?.refreshCollection()
        }
        let nav = UINavigationController.init(rootViewController: creationVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCenterItemCell", for: indexPath)
        
        for view in cell.subviews {
            if view.tag >= 10 {
                view.removeFromSuperview()
            }
        }
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 4
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        var cellTag: Int = 10
        let model = dataSources[indexPath.row]
        
        //封面
        let coverImageView = UIImageView.init(frame: cell.bounds~)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.tag = cellTag 
        cellTag += 1
        cell.addSubview(coverImageView)
        
        coverImageView.yy_setImage(with: URL.init(string: kBaseURL+model.cover),
                                   placeholder: UIImage.init(named: "big_image_placeholder"),
                                   options: kWebImageOptions,
                                   completion: nil)
        
        let coverView = UIView.init(frame: coverImageView.bounds)
        coverView.backgroundColor = kRGBColor(red: 65, green: 65, blue: 65, alpha: 1).withAlphaComponent(0.2)
        coverImageView.addSubview(coverView)
        
        //标题
        let nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(15)
        nameLabel.textColor = .white
        nameLabel.text = model.name
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.tag = cellTag
        cellTag += 1
        cell.addSubview(nameLabel)
        let maxW: CGFloat = cell.bounds.size.width-10*2
        let nameSize = nameLabel.sizeThatFits(CGSize.init(width: maxW, height: cell.bounds.size.height-10*2)~)
        nameLabel.frame = CGRect.init(x: 0, y: 0, width: nameSize.width, height: nameSize.height)~
        nameLabel.center = CGPoint.init(x: cell.bounds.size.width/2, y: cell.bounds.size.height/2)
        
        //私密
        if model.isPrivate == true {
            let privateBtn = UIButton.init(type: .system)
            privateBtn.tintColor = .white
            privateBtn.imageView?.contentMode = .scaleAspectFit
            privateBtn.contentMode = .scaleAspectFit
            privateBtn.setImage(UIImage.init(named: "icon_post_private"), for: .normal)
            privateBtn.tag = cellTag
            cellTag += 1
            cell.addSubview(privateBtn)
            privateBtn.frame = CGRect.init(x: 12, y: cell.bounds.size.height-12-8, width: 8, height: 8)~
        }
        
        //数量
        if model.postCount > 0 {
            let countLabel = UILabel.init()
            countLabel.font = kBaseFont(10)
            countLabel.textColor = .white
            countLabel.text = "\(model.postCount)"+"句"
            countLabel.numberOfLines = 0
            countLabel.textAlignment = .center
            countLabel.tag = cellTag
            cellTag += 1
            cell.addSubview(countLabel)
            countLabel.sizeToFit()
            countLabel.frame = CGRect.init(x: cell.bounds.size.width-12-countLabel.frame.size.width, y: cell.bounds.size.height-8-countLabel.frame.size.height, width: countLabel.frame.size.width, height: countLabel.frame.size.height)~
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (self.view.bounds.size.width-CGFloat(2*20)-16)/CGFloat(2)
        
        return CGSize.init(width: cellWidth, height: cellWidth)~
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)~
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSources[indexPath.row]
        
        let detailVC = CollectionDetailViewController()
        detailVC.collectionModel = model
        detailVC.userID = UserModel.fetchUser().userId
        detailVC.editCompletionHandle = { [weak self] (newModel) -> Void in
            if newModel == nil {
                self?.dataSources.remove(at: indexPath.row)
                self?.collectionView.deleteItems(at: [indexPath])
            } else {
                self?.dataSources[indexPath.row] = newModel as! CollectionModel
                self?.collectionView.reloadItems(at: [indexPath])
            }
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    // MARK: - delloc
    deinit {
        NotificationCenter.default.removeObserver(self, name: kCollectSelectionNotification, object: nil)
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
