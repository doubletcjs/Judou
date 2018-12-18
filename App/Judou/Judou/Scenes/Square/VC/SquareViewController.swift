//
//  SquareViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class SquareViewController: BaseShowBarViewController, SGPageTitleViewDelegate, SGPageContentScrollViewDelegate {
    private var createButton: UIButton!
    private var pageTitleView: SGPageTitleView!
    private var pageContentScrollView: SGPageContentScrollView!
    private var controllerArray: Array<ChannelPostViewController> = Array()
    private var listButton: UIButton!
    
    private var allChannelNames: Array<String>! = []
    private var currentChannelNames: Array<String>! = []
    private var currentChannelName: String!
    private var selectedPage: Int!
    private var controllersRect: CGRect!
    
    private var menuControl: JSVariableMenuControl! = JSVariableMenuControl.init()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        ChannelModel.defaultChannels().forEach { (model) in
            allChannelNames.append(model.name)
        }
        
        ChannelModel.readAllChannel().forEach { (model) in
            currentChannelNames.append(model.name)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        createButton = UIButton.init(type: .custom)
        createButton.setImage(UIImage.init(named: "icon_create"), for: .normal)
        createButton.contentMode = .scaleAspectFit
        createButton.imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(createButton)
        createButton.sizeToFit()
        createButton.center = CGPoint.init(x: kScreenWidth()-createButton.frame.size.width/2-14, y: kScreenHeight()-createButton.frame.size.height/2-kTabBarHeight()-16)~
        createButton.addTarget(self, action: #selector(self.goCreatePost), for: .touchUpInside)
        
        let searchButton = UIButton.init(type: .system)
        searchButton.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth()-20*2, height: 32)~
        searchButton.layer.cornerRadius = searchButton.frame.size.height/2
        searchButton.layer.masksToBounds = true
        searchButton.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        searchButton.setTitle(" 搜索喜欢的内容", for: .normal)
        searchButton.titleLabel?.font = kBaseFont(15)
        searchButton.setTitleColor(kRGBColor(red: 209, green: 210, blue: 211, alpha: 1), for: .normal)
        searchButton.setImage(UIImage.init(named: "icon_search"), for: .normal)
        self.navigationItem.titleView = searchButton
        searchButton.addTarget(self, action: #selector(self.goSearchPost), for: .touchUpInside)
        
        self.loadPageTitleView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
            self.createButton.center = CGPoint.init(x: (kScreenWidth()+self.createButton.frame.size.width/2)~, y: self.createButton.center.y)
        }) { (finish) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
            self.createButton.center = CGPoint.init(x: (kScreenWidth()-self.createButton.frame.size.width/2-16)~, y: self.createButton.center.y)
        }) { (finish) in
            
        }
    }
    // MARK: - 频道列表
    func loadPageScrollView() -> Void {
        if pageContentScrollView != nil {
            for vc in self.children {
                if vc is ChannelPostViewController {
                    vc.removeFromParent()
                }
            }
            
            pageContentScrollView.removeFromSuperview()
            pageContentScrollView.delegatePageContentScrollView = nil
            pageContentScrollView = nil
        }
        
        pageContentScrollView = SGPageContentScrollView.init(frame: controllersRect, parentVC: self, childVCs: controllerArray)
        pageContentScrollView.delegatePageContentScrollView = self
        self.view.addSubview(pageContentScrollView)
        self.view.bringSubviewToFront(createButton)
        
        pageContentScrollView.setPageContentScrollViewCurrentIndex(selectedPage)
    }
    
    private func loadPageTitleView() -> Void {
        if pageTitleView != nil {
            pageTitleView.removeFromSuperview()
        }
        
        let baseX: CGFloat = 20
        if listButton == nil {
            listButton = UIButton.init(type: .custom)
            listButton.setImage(UIImage.init(named: "nav_lists"), for: .normal)
            listButton.contentMode = .scaleAspectFit
            listButton.imageView?.contentMode = .scaleAspectFit
            self.view.addSubview(listButton)
            listButton.sizeToFit()
            listButton.frame = CGRect.init(x: kScreenWidth()-baseX-listButton.frame.size.width, y: 0, width: listButton.frame.size.width, height: listButton.frame.size.height)~
            listButton.addTarget(self, action: #selector(self.manageChannel), for: .touchUpInside)
        }
        
        let titleViewConfigure: SGPageTitleViewConfigure = SGPageTitleViewConfigure()
        titleViewConfigure.showBottomSeparator = false
        titleViewConfigure.indicatorStyle = SGIndicatorStyleDynamic
        
        titleViewConfigure.indicatorColor = kRGBColor(red: 206, green: 210, blue: 219, alpha: 1)
        titleViewConfigure.indicatorHeight = 4~
        titleViewConfigure.indicatorCornerRadius = titleViewConfigure.indicatorHeight/2
        
        titleViewConfigure.titleFont = kBaseFont(17)
        titleViewConfigure.titleSelectedFont = kBaseFont(18)
        titleViewConfigure.titleSelectedColor = .black
        titleViewConfigure.titleColor = kRGBColor(red: 159, green: 163, blue: 164, alpha: 1)
        
        pageTitleView = SGPageTitleView.init(frame: CGRect.init(x: baseX, y: kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height, width: listButton.frame.origin.x-6-baseX, height: 44)~, delegate: self, titleNames: currentChannelNames, configure: titleViewConfigure)
        self.view.addSubview(pageTitleView)
        
        listButton.center = CGPoint.init(x: listButton.center.x, y: pageTitleView.center.y)
        controllersRect = CGRect.init(x: 0, y: pageTitleView.frame.maxY, width: kScreenWidth(), height: kScreenHeight()-pageTitleView.frame.maxY-kTabBarHeight())~
    }
    // MARK: - SGPageTitleViewDelegate / SGPageContentScrollViewDelegate
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        if pageContentScrollView != nil {
            pageContentScrollView.setPageContentScrollViewCurrentIndex(selectedIndex)
        }
        
        currentChannelName = currentChannelNames[selectedIndex]
        selectedPage = selectedIndex
        
        if controllerArray.count == 0 {
            currentChannelNames.forEach { (channelName) in
                let channelPostVC = ChannelPostViewController()
                channelPostVC.channelName = channelName
                channelPostVC.superFrame = CGRect.init(x: 0, y: 0, width: controllersRect.size.width, height: controllersRect.size.height)~
                controllerArray.append(channelPostVC)
            }
            
            self.loadPageScrollView()
        }
    }
    
    func pageContentScrollView(_ pageContentScrollView: SGPageContentScrollView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        pageTitleView.setPageTitleViewWithProgress(progress, originalIndex: originalIndex, targetIndex: targetIndex)
        
        if progress == 1 {
            currentChannelName = currentChannelNames[targetIndex]
        }
    }
    // MARK: - 管理频道
    @objc private func manageChannel() -> Void {
        createButton.center = CGPoint.init(x: (kScreenWidth()+createButton.frame.size.width/2)~, y: createButton.center.y)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
            UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, kScreenScale())
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            self.menuControl.screenShot = image
            UIGraphicsEndImageContext()
            
            let unUseTitles: NSMutableArray = NSMutableArray.init(array: self.allChannelNames)
            unUseTitles.removeObjects(in: self.currentChannelNames)
            
            self.menuControl.showChannelViewWith(inUseTitles: self.currentChannelNames, unUseTitles: unUseTitles as! [String], fixedNum: 1) { (inUseTitles, unUseTitles) in
                if inUseTitles != self.currentChannelNames {
                    self.currentChannelNames = inUseTitles
                    self.loadPageTitleView()
                    
                    var currentIndex: Int = 0
                    for idx in 0...self.currentChannelNames.count-1 {
                        let name = self.currentChannelNames[idx]
                        if self.currentChannelName == name {
                            currentIndex = idx
                            break
                        }
                    }
                    
                    self.pageTitleView.selectedIndex = currentIndex
                    self.selectedPage = currentIndex
                    self.refreshControllers()
                    
                    var array: [ChannelModel] = []
                    let channels: [String] = inUseTitles
                    channels.forEach { (channel) in
                        let model = ChannelModel()
                        model.name = channel
                        array.append(model)
                    }
                    ChannelModel.recordChannel(array)
                }
            }
            
            DispatchQueueMainAsyncAfter(deadline: .now()+UIApplication.shared.statusBarOrientationAnimationDuration, target: self, execute: {
                self.createButton.center = CGPoint.init(x: (kScreenWidth()-self.createButton.frame.size.width/2-16)~, y: self.createButton.center.y)
            })
        })
    }
    // MARK: - 重新加载controllers
    private func refreshControllers() -> Void {
        func getPageController(_ channelName: String) -> ChannelPostViewController? {
            for vc: ChannelPostViewController in controllerArray {
                if vc.channelName == channelName {
                    return vc
                }
            }
            
            return nil
        }
        
        var tempControllerArray: Array<ChannelPostViewController> = Array()
        for idx in 0...currentChannelNames.count-1 {
            let channelName = currentChannelNames[idx]
            let vc: ChannelPostViewController? = getPageController(channelName)
            if vc != nil {
                tempControllerArray.append(vc!)
            } else {
                let channelPostVC = ChannelPostViewController()
                channelPostVC.channelName = channelName
                channelPostVC.superFrame = CGRect.init(x: 0, y: 0, width: controllersRect.size.width, height: controllersRect.size.height)~
                
                tempControllerArray.append(channelPostVC)
            }
        }
        
        DispatchQueue.main.async(execute: {
            self.controllerArray = tempControllerArray
            self.loadPageScrollView()
        })
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
