//
//  MyPageViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class MyPageViewController: BaseHideBarViewController, MXParallaxHeaderDelegate, SGPageTitleViewDelegate, SGPageContentScrollViewDelegate {
    private var statusBarStyle: UIStatusBarStyle!
    private var scrollView: MXScrollView!
    private var headerImageView: UIImageView!
    private var topBar: UIView!
    private var backButton: UIButton!
    private var nameLabel: UILabel!
    private var pageHeaderView: HomePageHeaderView!
    
    private var pageTitleView: SGPageTitleView!
    private var pageContentScrollView: SGPageContentScrollView!
    
    var account: UserModel!

    override func viewDidLoad() {
        statusBarStyle = UIApplication.shared.statusBarStyle
        
        super.viewDidLoad()
        
        if account == nil {
            account = UserModel.fetchUser()
        }

        // Do any additional setup after loading the view.
        scrollView = MXScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)~)
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize.init(width: 0, height: kScreenHeight()-currentSafeAreaInsets().bottom)~
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        // 5/4 = w/h
        let height = (kScreenWidth()*3.0)/5.0+kStatusBarHeight()
        headerImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: height)~)
        headerImageView.yy_setImage(with: URL.init(string: account.portrait),
                                    placeholder: UIImage.init(named: "default_music_big")?.byBlurLight(),
                                    options: kWebImageOptions) { [weak self] (image, url, imageFromType, imageStage, error) in
                                        if image != nil {
                                            self?.headerImageView.image = image!.byBlurLight()
                                        }
        }
        
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.isUserInteractionEnabled = true
        
        scrollView.parallaxHeader.height = headerImageView.bounds.size.height
        scrollView.parallaxHeader.minimumHeight = kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height
        scrollView.parallaxHeader.view = headerImageView
        scrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        scrollView.parallaxHeader.delegate = self
        
        //个人信息
        pageHeaderView = HomePageHeaderView.init(frame: CGRect.init(x: 0, y: scrollView.parallaxHeader.minimumHeight, width: headerImageView.bounds.size.width, height: scrollView.parallaxHeader.height-kStatusBarHeight())~)
        pageHeaderView.account = account
        pageHeaderView.currentVC = self
        headerImageView.addSubview(pageHeaderView)
        
        //导航栏
        topBar = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height)~)
        self.view.addSubview(topBar)
        topBar.clipsToBounds = true
        
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
        
        //顶部用户名
        nameLabel = UILabel.init(frame: CGRect.init(x: 0, y: topBar.frame.size.height, width: topBar.frame.size.width-54*2, height: backButton.frame.size.height)~)
        topBar.addSubview(nameLabel)
        nameLabel.font = kBaseFont(16)
        nameLabel.text = account.nickname
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.center = CGPoint.init(x: topBar.frame.size.width/2, y: nameLabel.center.y)~
        
        //tab
        let titleViewConfigure: SGPageTitleViewConfigure = SGPageTitleViewConfigure()
        titleViewConfigure.bottomSeparatorColor = kRGBColor(red: 249, green: 249, blue: 249, alpha: 1)
        titleViewConfigure.indicatorStyle = SGIndicatorStyleFixed
        titleViewConfigure.indicatorFixedWidth = 64
        
        titleViewConfigure.indicatorColor = kRGBColor(red: 166, green: 146, blue: 91, alpha: 1)
        titleViewConfigure.indicatorHeight = 2
        
        titleViewConfigure.titleFont = kBaseFont(16)
        titleViewConfigure.titleSelectedFont = kBaseFont(16)
        titleViewConfigure.titleSelectedColor = kRGBColor(red: 188, green: 174, blue: 139, alpha: 1)
        titleViewConfigure.titleColor = .black
        
        pageTitleView = SGPageTitleView.init(frame: CGRect.init(x: 0, y: 0, width: scrollView.bounds.size.width, height: 40)~, delegate: self, titleNames: ["句子 0", "收藏夹 0"], configure: titleViewConfigure)
        scrollView.addSubview(pageTitleView)
        
        let controllerRect = CGRect.init(x: 0, y: pageTitleView.frame.maxY, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height-pageTitleView.frame.maxY-bottomHeight-kStatusBarHeight())~
        
        let postVC = TabPostViewController()
        postVC.superFrame = controllerRect
        postVC.isHomePage = true
        
        let collectionVC = UIViewController()
        collectionVC.view.backgroundColor = .white
        collectionVC.view.frame = controllerRect
        
        pageContentScrollView = SGPageContentScrollView.init(frame: controllerRect, parentVC: self, childVCs: [postVC, collectionVC])
        pageContentScrollView.delegatePageContentScrollView = self
        scrollView.addSubview(pageContentScrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if statusBarStyle == .default {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
        
        if account.userId == UserModel.fetchUser().userId {
            account = UserModel.fetchUser()
            pageHeaderView.account = account
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if statusBarStyle == .default && (self.presentedViewController == nil || "\(self.presentedViewController!.classForCoder)" != "STPopupContainerViewController") {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
    }
    // MARK: - SGPageTitleViewDelegate / SGPageContentScrollViewDelegate
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        pageContentScrollView.setPageContentScrollViewCurrentIndex(selectedIndex)
        
    }
    
    func pageContentScrollView(_ pageContentScrollView: SGPageContentScrollView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        pageTitleView.setPageTitleViewWithProgress(progress, originalIndex: originalIndex, targetIndex: targetIndex)
        
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
        
        var frame = pageHeaderView.frame
        frame.origin.y = parallaxHeader.contentView.bounds.size.height-pageHeaderView.frame.size.height
        pageHeaderView.frame = frame
        pageHeaderView.alpha = progress
        
        if alpha > 0.6 {
            UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration) {
                var frame = self.nameLabel.frame
                frame.origin.y = self.backButton.frame.origin.y
                self.nameLabel.frame = frame
            }
        } else {
            UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration) {
                var frame = self.nameLabel.frame
                frame.origin.y = self.topBar.frame.size.height
                self.nameLabel.frame = frame
            }
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
