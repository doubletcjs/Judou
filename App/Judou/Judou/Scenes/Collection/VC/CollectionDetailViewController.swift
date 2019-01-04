//
//  CollectionDetailViewController.swift
//  Judou
//
//  Created by 4work on 2019/1/3.
//  Copyright © 2019 Sam Cooper Studio. All rights reserved.
//

import UIKit

class CollectionDetailViewController: BaseHideBarViewController, MXParallaxHeaderDelegate, SGPageContentScrollViewDelegate, UIScrollViewDelegate {
    var collectionModel: CollectionModel!
    
    private var statusBarStyle: UIStatusBarStyle!
    private var parallaxScrollView: MXScrollView!
    private var headerImageView: BlurImageView!
    private var topBar: UIView!
    private var topBarImageView: BlurImageView!
    private var backButton: UIButton!
    private var moreButton: UIButton!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var nameLabel: UILabel!
    
    private var pageContentScrollView: SGPageContentScrollView!
    private var controllers: [TabPostViewController]! = []
    private var centerNameLabel: UILabel!
    private var countLabel: UILabel!

    override func viewDidLoad() {
        statusBarStyle = UIApplication.shared.statusBarStyle
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //导航栏
        topBar = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height)~)
        self.view.addSubview(topBar)
        topBar.clipsToBounds = true
        
        parallaxScrollView = MXScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)~)
        self.view.addSubview(parallaxScrollView)
        parallaxScrollView.contentSize = CGSize.init(width: 0, height: kScreenHeight()-currentSafeAreaInsets().bottom)~
        parallaxScrollView.showsVerticalScrollIndicator = false
        parallaxScrollView.showsHorizontalScrollIndicator = false
        parallaxScrollView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        let originalScrollView: UIScrollView = parallaxScrollView as UIScrollView
        originalScrollView.delegate = self
        
        // 5/4 = w/h
        let height = (kScreenWidth()*2.0)/5.0+kStatusBarHeight()
        headerImageView = BlurImageView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: height)~)
        headerImageView.setImage(with: collectionModel.cover, placeholder: UIImage.init(named: "big_image_placeholder")!)
        headerImageView.showBlurOriginal = true
        headerImageView.isUserInteractionEnabled = true
        
        //顶部栏背景图片
        topBarImageView = BlurImageView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: height)~)
        topBarImageView.setImage(with: collectionModel.cover, placeholder: UIImage.init(named: "big_image_placeholder")!)
        topBarImageView.showBlurOriginal = true
        topBar.insertSubview(topBarImageView, at: 0)
        
        parallaxScrollView.parallaxHeader.height = headerImageView.bounds.size.height
        parallaxScrollView.parallaxHeader.minimumHeight = kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height
        parallaxScrollView.parallaxHeader.view = headerImageView
        parallaxScrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        parallaxScrollView.parallaxHeader.delegate = self
        
        //返回
        let bottomHeight = self.navigationController!.navigationBar.frame.size.height
        backButton = UIButton.init(type: .system)
        backButton.tintColor = .white
        backButton.setImage(UIImage.init(named: "nav_back_white"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.contentMode = .scaleAspectFit
        backButton.frame = CGRect.init(x: 0, y: kStatusBarHeight(), width: bottomHeight, height: bottomHeight)~
        topBar.addSubview(backButton)
        backButton.addTarget(self, action: #selector(self.defaultBackAction), for: .touchUpInside)
        
        //更多
        moreButton = UIButton.init(type: .system)
        moreButton.tintColor = .white
        moreButton.imageView?.contentMode = .scaleAspectFit
        moreButton.contentMode = .scaleAspectFit
        moreButton.frame = CGRect.init(x: topBar.frame.size.width-bottomHeight, y: kStatusBarHeight(), width: bottomHeight, height: bottomHeight)~
        topBar.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(self.moreAction), for: .touchUpInside)
        if collectionModel.authorId == UserModel.fetchUser().userId {
            moreButton.setImage(UIImage.init(named: "nav_more_white"), for: .normal)
        }
        
        activityIndicatorView = UIActivityIndicatorView.init(style: .white)
        activityIndicatorView.hidesWhenStopped = true
        moreButton.addSubview(activityIndicatorView)
        activityIndicatorView.sizeToFit()
        activityIndicatorView.center = CGPoint.init(x: moreButton.frame.size.width/2, y: moreButton.frame.size.height/2)
        
        //顶部用户名
        nameLabel = UILabel.init(frame: CGRect.init(x: 0, y: topBar.frame.size.height, width: topBar.frame.size.width-54*2, height: backButton.frame.size.height)~)
        topBar.addSubview(nameLabel)
        nameLabel.font = kBaseFont(17)
        nameLabel.text = collectionModel.name
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.center = CGPoint.init(x: topBar.frame.size.width/2, y: nameLabel.center.y)~
        
        //标题
        centerNameLabel = UILabel.init()
        centerNameLabel.font = kBaseFont(17)
        centerNameLabel.textColor = .white
        centerNameLabel.numberOfLines = 0
        centerNameLabel.text = collectionModel.name
        headerImageView.addSubview(centerNameLabel)
        let nameSize = centerNameLabel.sizeThatFits(CGSize.init(width: headerImageView.bounds.size.width-20*2, height: headerImageView.bounds.size.height)~)
        centerNameLabel.frame = CGRect.init(x: 0, y: 0, width: nameSize.width, height: nameSize.height)~
        centerNameLabel.center = CGPoint.init(x: headerImageView.bounds.size.width/2, y: headerImageView.bounds.size.height/2)
        
        //帖子数
        countLabel = UILabel.init()
        countLabel.font = kBaseFont(13)
        countLabel.textColor = .white
        countLabel.numberOfLines = 0
        if collectionModel.postCount > 0 {
            countLabel.text = "\(collectionModel.postCount)"+"句"
        }
        headerImageView.addSubview(countLabel)
        let countSize = countLabel.sizeThatFits(CGSize.init(width: headerImageView.bounds.size.width-20*2, height: headerImageView.bounds.size.height)~)
        countLabel.frame = CGRect.init(x: 0, y: 0, width: countSize.width, height: countSize.height)~
        countLabel.center = CGPoint.init(x: centerNameLabel.center.x, y: centerNameLabel.center.y+10+countLabel.frame.size.height/2+centerNameLabel.bounds.size.height/2)
        
        let controllerRect = CGRect.init(x: 0, y: 0, width: parallaxScrollView.bounds.size.width, height: parallaxScrollView.bounds.size.height-bottomHeight-kStatusBarHeight())~
        
        let postVC = TabPostViewController()
        postVC.superFrame = controllerRect
        postVC.isCollection = true
        postVC.collectionModel = collectionModel
        postVC.finishLoadHandle = { [weak self] () -> Void in
            DispatchQueueMainAsyncAfter(deadline: .now()+0.4, target: self, execute: {
                if self?.collectionModel.authorId == UserModel.fetchUser().userId {
                    self?.moreButton.setImage(UIImage.init(named: "nav_more_white"), for: .normal)
                }
                self?.activityIndicatorView.stopAnimating()
            })
        }
        controllers.append(postVC)
        
        pageContentScrollView = SGPageContentScrollView.init(frame: controllerRect, parentVC: self, childVCs: controllers)
        pageContentScrollView.delegatePageContentScrollView = self
        parallaxScrollView.addSubview(pageContentScrollView)
        pageContentScrollView.setPageContentScrollViewCurrentIndex(0)
        self.refreshCollectionPost()
        
        self.view.bringSubviewToFront(topBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if statusBarStyle == .default {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if statusBarStyle == .default && (self.presentedViewController == nil || "\(self.presentedViewController!.classForCoder)" != "STPopupContainerViewController") {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
    }
    // MARK: - 更多
    @objc private func moreAction() -> Void {
        let actionSheet: JSActionSheet = JSActionSheet.init(title: nil, cancelTitle: "取消", otherTitles: ["编辑", "删除"])
        actionSheet.destructiveButtonIndex = 1
        actionSheet.destructiveColor = .red
        actionSheet.showView()
        actionSheet.dismiss(forCompletionHandle: { [weak self] (index, isCancel) in
            if isCancel == false {
                DispatchQueueMainAsyncAfter(deadline: .now(), target: self, execute: {
                    if index == 0 {
                        
                    } else {
                        
                    }
                })
            }
        })
    }
    // MARK: - 刷新
    private func refreshCollectionPost() -> Void {
        moreButton.setImage(nil, for: .normal)
        activityIndicatorView.startAnimating()
        
        let postVC: TabPostViewController = controllers[0]
        postVC.pageRefreshData()
    }
    // MARK: - SGPageContentScrollViewDelegate
    func pageContentScrollView(_ pageContentScrollView: SGPageContentScrollView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {  
        if progress == 1 {
            
        }
    }
    // MARK: - MXParallaxHeaderDelegate
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        //状态栏过度
        var progress = parallaxHeader.progress
        if progress > 1.0 {
            progress = 1.0
        }
        
        let alpha: CGFloat = 1-progress
        
//        var frame = pageHeaderView.frame
//        frame.origin.y = parallaxHeader.contentView.bounds.size.height-pageHeaderView.frame.size.height
//        pageHeaderView.frame = frame
        
        var frame = topBarImageView.frame
        frame.size.height = parallaxHeader.contentView.bounds.size.height
        topBarImageView.frame = frame
        
        frame = headerImageView.frame
        frame.size.height = parallaxHeader.contentView.bounds.size.height
        headerImageView.frame = frame
        
        centerNameLabel.center = CGPoint.init(x: headerImageView.bounds.size.width/2, y: headerImageView.bounds.size.height/2)
        countLabel.center = CGPoint.init(x: centerNameLabel.center.x, y: centerNameLabel.center.y+10+countLabel.frame.size.height/2+centerNameLabel.bounds.size.height/2)
        
        topBarImageView.blurAlpha = progress
        headerImageView.blurAlpha = progress
        
        if alpha > 0.6 {
            UIView.animate(withDuration: 0.4) {
                var frame = self.nameLabel.frame
                frame.origin.y = self.backButton.frame.origin.y
                self.nameLabel.frame = frame
            }
        } else {
            UIView.animate(withDuration: 0.4) {
                var frame = self.nameLabel.frame
                frame.origin.y = self.topBar.frame.size.height
                self.nameLabel.frame = frame
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if -scrollView.contentOffset.y-parallaxScrollView.parallaxHeader.height > self.navigationController!.navigationBar.frame.size.height+kStatusBarHeight() {
            Log("刷新数据")
            self.refreshCollectionPost()
        }
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
