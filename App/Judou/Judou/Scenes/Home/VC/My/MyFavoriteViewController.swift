//
//  MyFavoriteViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/24.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class MyFavoriteViewController: BaseShowBarViewController, SGPageTitleViewDelegate, SGPageContentScrollViewDelegate {
    private var pageTitleView: SGPageTitleView!
    private var pageContentScrollView: SGPageContentScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_search"), style: .plain, target: self, action: #selector(self.goSearchPost))
        
        let titleViewConfigure: SGPageTitleViewConfigure = SGPageTitleViewConfigure()
        titleViewConfigure.showBottomSeparator = false
        titleViewConfigure.indicatorStyle = SGIndicatorStyleDynamic
        
        titleViewConfigure.indicatorColor = kRGBColor(red: 206, green: 210, blue: 219, alpha: 1)
        titleViewConfigure.indicatorHeight = 4
        titleViewConfigure.indicatorCornerRadius = titleViewConfigure.indicatorHeight/2
        
        titleViewConfigure.titleFont = kBaseFont(17)
        titleViewConfigure.titleSelectedFont = kBaseFont(18)
        titleViewConfigure.titleSelectedColor = .black
        titleViewConfigure.titleColor = kRGBColor(red: 159, green: 163, blue: 164, alpha: 1)
        
        let titleNames: [String] = ["句子", "随笔", "视频"]
        pageTitleView = SGPageTitleView.init(frame: CGRect.init(x: 0, y: kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height, width: kScreenWidth(), height: 44)~, delegate: self, titleNames: titleNames, configure: titleViewConfigure)
        self.view.addSubview(pageTitleView)
        
        let controllerRect = CGRect.init(x: 0, y: pageTitleView.frame.maxY, width: kScreenWidth(), height: self.view.bounds.size.height-pageTitleView.frame.maxY)~
        var controllers: Array<FavoriteListViewController> = Array()
        titleNames.forEach { (name) in
            let favoriteListVC = FavoriteListViewController()
            favoriteListVC.favoriteType = name
            favoriteListVC.superFrame = controllerRect
            controllers.append(favoriteListVC)
        }
        
        pageContentScrollView = SGPageContentScrollView.init(frame: controllerRect, parentVC: self, childVCs: controllers)
        pageContentScrollView.delegatePageContentScrollView = self
        self.view.addSubview(pageContentScrollView)
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
    // MARK: - 搜索
    @objc private func goSearchPost() -> Void {
        let searchCenterVC = SearchCenterViewController()
        searchCenterVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(searchCenterVC, animated: true)
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
