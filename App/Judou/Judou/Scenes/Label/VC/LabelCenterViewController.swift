//
//  LabelCenterViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/16.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias LabelCenterSelectBlock = (_ labelModel: LabelModel) -> Void

class LabelCenterViewController: BaseShowBarViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    private var collectionView: UICollectionView!
    private var dataSources: [LabelModel]! = []
    var labelSelectHandle: LabelCenterSelectBlock?
    
    private var loadingList: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "选择标签"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.labelCloseAction)) 
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_add"), style: .plain, target: self, action: #selector(self.createLabelAction))
        
        let flowLayout = UICollectionViewFlowLayout.init()
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout) 
        collectionView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "LabelCenterItemCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
         
        self.view.addSubview(collectionView)
        collectionView.setupRefresh(self, #selector(self.requestLabelList), nil)
        collectionView.mj_header.isHidden = false
        
        self.requestLabelList()
    }
    // MARK: - 获取标签列表
    @objc private func requestLabelList() -> Void {
        if loadingList == true {
            return
        }
        
        var isAdmin: Bool = false
        if UserModel.fetchUser().level == 0 {
            isAdmin = true
        }
        
        loadingList = true
        Networking.labelListRequest(params: ["isAdmin": "\(isAdmin)"]) { [weak self] (list, error) in
            if error != nil {
                showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
            } else {
                self?.dataSources = list as? [LabelModel]
                self?.collectionView.reloadData()
            }
            
            self?.loadingList = false
            self?.collectionView.mj_header.endRefreshing()
        }
    }
    // MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
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
        return -(collectionView.bounds.size.height/6)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
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
        
        let cellWidth: CGFloat = (self.view.bounds.size.width-CGFloat(2*18)-CGFloat(3*16))/CGFloat(4)
        let model: LabelModel = dataSources[indexPath.item]
        
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: cellWidth, height: cellWidth)~)
        imageView.contentMode = .scaleAspectFill
        imageView.yy_setImage(with: URL.init(string: model.cover),
                              placeholder: nil,
                              options: kWebImageOptions,
                              completion: nil)
        imageView.tag = 10
        cell.addSubview(imageView)
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: imageView.frame.maxY, width: cellWidth, height: 30)~)
        label.font = kBaseFont(13)
        label.textColor = .black
        label.textAlignment = .center
        label.text = model.title
        label.tag = 11
        cell.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (self.view.bounds.size.width-CGFloat(2*18)-CGFloat(3*16))/CGFloat(4)
        
        return CGSize.init(width: cellWidth, height: cellWidth+30)~
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 16, left: 18, bottom: 0, right: 18)~
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model: LabelModel = dataSources[indexPath.item]
        
        if UserModel.fetchUser().level == 0 && model.status == 0 {
            let actionSheet: JSActionSheet = JSActionSheet.init(title: nil, cancelTitle: "取消", otherTitles: ["选择标签", "通过审核"])
            actionSheet.showView()
            actionSheet.dismiss(forCompletionHandle: { [weak self] (index, isCancel) in
                if isCancel == false {
                    DispatchQueueMainAsyncAfter(deadline: .now(), target: self, execute: {
                        if index == 0 {
                            if self!.labelSelectHandle != nil {
                                self?.labelSelectHandle!(model)
                            }
                            
                            self?.labelCloseAction()
                        } else {
                            
                        }
                    })
                }
            })
        } else {
            if labelSelectHandle != nil {
                labelSelectHandle!(model)
            }
            
            self.labelCloseAction()
        }
    }
    // MARK: - 添加标签
    @objc private func createLabelAction() -> Void {
        let createLabelVC = CreateLabelViewController()
        createLabelVC.creationCompletionHandle = { [weak self] () -> Void in
            self?.requestLabelList()
        }
        let nav = UINavigationController.init(rootViewController: createLabelVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - 关闭
    @objc private func labelCloseAction() -> Void {
        self.dismiss(animated: true, completion: nil)
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
