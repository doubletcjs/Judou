//
//  CollectSelectionViewController.swift
//  Judou
//
//  Created by 4work on 2019/1/6.
//  Copyright © 2019 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias CollectSelectionFinishBlock = (_ isCollect: Bool) -> Void

class CollectSelectionViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!
    private var dataSources: [CollectionModel]! = []
    
    private var currentPage: Int! = 0
    private var pageSize: Int! = 20
    var postModel: PostModel!
    var selectionFinishHandle: CollectSelectionFinishBlock?
    
    private var addList: [String] = []
    private var deleteList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "我的收藏夹"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.collectAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_done"), style: .plain, target: self, action: #selector(self.postJoinCollection))
        
        tableView = UITableView.init(frame: self.view.bounds~, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = kRGBColor(red: 237, green: 238, blue: 238, alpha: 1) 
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 0)~
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        self.view.addSubview(tableView)
        
        tableView.setupRefresh(self, #selector(self.refreshCollection), #selector(self.loadMoreCollection))
        tableView.mj_header.isHidden = false
        tableView.mj_footer.isHidden = false
        
        self.refreshCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
        Networking.collectionListRequest(params: ["postId": postModel.objectId, "userId": UserModel.fetchUser().userId, "loginId": UserModel.fetchUser().userId, "currentPage": "\(currentPage!)", "pageSize": "\(pageSize!)"]) { [weak self] (list, error) in
            if error != nil {
                showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                
                if self!.currentPage > 0 {
                    self?.currentPage -= 1
                    self?.tableView.mj_footer.endRefreshing()
                }
            } else {
                let array: [CollectionModel] = list as! [CollectionModel]
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
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellIdentifier")
        }
        
        for view: UIView in cell!.subviews {
            if view.tag >= 10 {
                view.removeFromSuperview()
            }
        }
        
        var cellTag: Int = 10
        let model = dataSources[indexPath.row]
        let cellHeight: CGFloat = 100
        
        //封面
        let coverImageView = UIImageView.init(frame: CGRect.init(x: tableView.separatorInset.left, y: 16, width: cellHeight-16*2, height: cellHeight-16*2))
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.tag = cellTag
        cellTag += 1
        cell?.addSubview(coverImageView)
        
        coverImageView.yy_setImage(with: URL.init(string: kBaseURL+model.cover),
                                   placeholder: UIImage.init(named: "big_image_placeholder"),
                                   options: kWebImageOptions,
                                   completion: nil)
        
        //选择
        let selectImageView = UIImageView.init(frame: CGRect.init(x: kScreenWidth()-24-18, y: 0, width: 18, height: 18))
        selectImageView.center = CGPoint.init(x: selectImageView.center.x, y: coverImageView.center.y)
        selectImageView.contentMode = .scaleAspectFit
        selectImageView.image = UIImage.init(named: "round_img")
        if model.isPostCollect == true {
            selectImageView.image = UIImage.init(named: "round_selected_img")
        }
        
        selectImageView.tag = cellTag
        cellTag += 1
        cell?.addSubview(selectImageView)
        
        //标题
        let contentLabel = UILabel.init()
        contentLabel.numberOfLines = 3
        contentLabel.text = model.name
        contentLabel.font = kBaseFont(17)
        contentLabel.textColor = .black
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.tag = cellTag
        cellTag += 1
        cell?.addSubview(contentLabel)
        
        let maxContentHeight: CGFloat = coverImageView.frame.size.height-12*2
        let maxW: CGFloat = selectImageView.frame.origin.x-(coverImageView.frame.maxX+tableView.separatorInset.left+24)
        let textSize = contentLabel.sizeThatFits(CGSize.init(width: maxW, height: maxContentHeight)~)
        contentLabel.frame = CGRect.init(x: coverImageView.frame.maxX+tableView.separatorInset.left, y: 0, width: maxW, height: textSize.height)
        contentLabel.center = CGPoint.init(x: contentLabel.center.x, y: coverImageView.center.y)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSources[indexPath.row]
        if model.isPostCollect == true {
            deleteList.append(model.objectId)
            if addList.count > 0 {
                for idx in 0...addList.count-1 {
                    if addList[idx] == model.objectId {
                        addList.remove(at: idx)
                        break
                    }
                }
            }
        } else {
            addList.append(model.objectId)
            if deleteList.count > 0 {
                for idx in 0...deleteList.count-1 {
                    if deleteList[idx] == model.objectId {
                        deleteList.remove(at: idx)
                        break
                    }
                }
            }
        }
        
        model.isPostCollect = !model.isPostCollect
        tableView.reloadRows(at: [indexPath], with: .none)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - 添加收藏夹
    @objc private func createCollectioAction() -> Void {
        let creationVC = CreationViewController()
        creationVC.creationCompletionHandle = { [weak self] (model) -> Void in
            
        }
        let nav = UINavigationController.init(rootViewController: creationVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - 加入收藏夹
    @objc private func postJoinCollection() -> Void {
        let hud = indicatorTextHUD("")
        Networking.postCollectRequest(params: ["postId": postModel.objectId, "addList": addList.joined(separator: ","), "deleteList": deleteList.joined(separator: ","), "authorId": UserModel.fetchUser().userId], completionHandler: { (data, error) in
            if error != nil {
                hud.hide(false)
                showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
            } else {
                let dict: [String: Any] = data as! [String : Any]
                let isSuccessful: Bool = dict["isSuccessful"]! as! Bool
                let isRun: Bool = dict["isRun"]! as! Bool
                var status: Int = 0 //0 查询失败 不改变状态 1 已收藏 2 未收藏
                if dict["status"] != nil {
                    status = dict["status"]! as! Int
                }
                
                if isRun == true {
                    if isSuccessful == true {
                        hud.hide(true)
                        self.tableView.reloadData()
                        NotificationCenter.default.post(name: kCollectSelectionNotification, object: nil)
                        UserModel.updateUserInfo()
                        
                        if status > 0 && self.selectionFinishHandle != nil {
                            var isCollect: Bool = self.postModel.isCollect
                            if status == 1 {
                                isCollect = true
                            } else if status == 2 {
                                isCollect = false
                            }
                            
                            self.selectionFinishHandle!(isCollect)
                        }
                        
                        DispatchQueueMainAsyncAfter(deadline: .now()+0.4, target: self, execute: {
                            self.collectAction()
                        })
                    } else {
                        hud.hide(false)
                        self.refreshCollection()
                    }
                } else {
                    hud.hide(true)
                }
            }
        })
    }
    // MARK: - 关闭
    @objc private func collectAction() -> Void {
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
