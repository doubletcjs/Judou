//
//  CollectionDetailViewController.swift
//  Judou
//
//  Created by 4work on 2019/1/3.
//  Copyright © 2019 Sam Cooper Studio. All rights reserved.
//

import UIKit

class CollectionDetailViewController: BaseHideBarViewController, MXParallaxHeaderDelegate, UIScrollViewDelegate {
    var collectionModel: CollectionModel!
    
    private var statusBarStyle: UIStatusBarStyle!
    private var parallaxScrollView: MXScrollView!
    private var headerImageView: UIImageView!
    private var topBar: UIView!
    private var topBarImageView: UIImageView!
    private var backButton: UIButton!
    private var nameLabel: UILabel!

    private var topBarBackImageView: UIImageView!
    private var headerBackImageView: UIImageView!
    
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
        headerImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: height)~)
        headerImageView.yy_setImage(with: URL.init(string: collectionModel.cover),
                                    placeholder: UIImage.init(named: "topic_default_avatar")?.byBlurLight(),
                                    options: kWebImageOptions) { [weak self] (image, url, imageFromType, imageStage, error) in
                                        if image != nil {
                                            self?.headerImageView.image = image!.byBlurLight()
                                        }
        }
        
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.isUserInteractionEnabled = true
        
        //顶部栏背景图片
        topBarImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: height)~)
        topBarImageView.yy_setImage(with: URL.init(string: collectionModel.cover),
                                    placeholder: UIImage.init(named: "topic_default_avatar")?.byBlurLight(),
                                    options: kWebImageOptions) { [weak self] (image, url, imageFromType, imageStage, error) in
                                        if image != nil {
                                            self?.topBarImageView.image = image!.byBlurLight()
                                        }
        }
        
        topBarImageView.contentMode = .scaleAspectFill
        topBar.insertSubview(topBarImageView, at: 0)
        
        //高清、模糊
        headerBackImageView = UIImageView.init(frame: headerImageView.bounds)
        headerBackImageView.yy_setImage(with: URL.init(string: collectionModel.cover),
                                        placeholder: UIImage.init(named: "topic_default_avatar"),
                                        options: kWebImageOptions) { (image, url, imageFromType, imageStage, error) in
        }
        headerBackImageView.contentMode = .scaleAspectFill
        headerBackImageView.isUserInteractionEnabled = true
        headerImageView.addSubview(headerBackImageView)
        
        topBarBackImageView = UIImageView.init(frame: topBarImageView.bounds)
        topBarBackImageView.yy_setImage(with: URL.init(string: collectionModel.cover),
                                        placeholder: UIImage.init(named: "topic_default_avatar"),
                                        options: kWebImageOptions) { (image, url, imageFromType, imageStage, error) in
        }
        topBarBackImageView.contentMode = .scaleAspectFill
        topBarImageView.addSubview(topBarBackImageView)
        
        headerImageView.alpha = 0
        topBarImageView.alpha = 0
        
        headerBackImageView.alpha = 1
        topBarBackImageView.alpha = 1
        
        //设置parallaxHeader
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
        
        //顶部用户名
        nameLabel = UILabel.init(frame: CGRect.init(x: 0, y: topBar.frame.size.height, width: topBar.frame.size.width-54*2, height: backButton.frame.size.height)~)
        topBar.addSubview(nameLabel)
        nameLabel.font = kBaseFont(17)
        nameLabel.text = collectionModel.name
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.center = CGPoint.init(x: topBar.frame.size.width/2, y: nameLabel.center.y)~
        
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
        
        headerImageView.alpha = alpha
        topBarImageView.alpha = alpha
        
        headerBackImageView.alpha = progress
        topBarBackImageView.alpha = progress
        
//        headerBackImageView.frame = headerImageView.bounds
//        topBarBackImageView.frame = topBarImageView.bounds
        
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
