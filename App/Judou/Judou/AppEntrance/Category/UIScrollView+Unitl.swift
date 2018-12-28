//
//  UIScrollView+Unitl.swift
//  Judou
//
//  Created by 4work on 2018/12/27.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit 

extension UIScrollView {

    func setupRefresh(_ target: AnyObject, _ headerAction: Selector?, _ footerAction: Selector?) -> Void {
        if headerAction != nil {
            let header = MJRefreshNormalHeader()
            header.setRefreshingTarget(target, refreshingAction: headerAction)
            header.setTitle("下拉刷新", for: .idle)
            header.setTitle("释放更新", for: .pulling)
            header.setTitle("刷新中", for: .refreshing)
            header.stateLabel.font = kBaseFont(15)
            header.lastUpdatedTimeLabel.isHidden = true
            
            self.mj_header = header
            self.mj_header.isHidden = true
            
            DispatchQueue.main.async(execute: {
                self.mj_header.beginRefreshing {
                    self.isUserInteractionEnabled = false
                }
                
                self.mj_header.endRefreshing {
                    self.isUserInteractionEnabled = true
                }
            })
        }
        
        if footerAction != nil {
            let footer = MJRefreshBackNormalFooter.init(refreshingTarget: target, refreshingAction: footerAction!)
            footer?.setTitle("上拉加载更多", for: .idle)
            footer?.setTitle("释放加载", for: .pulling)
            footer?.setTitle("加载中...", for: .refreshing)
            footer?.setTitle("已显示全部", for: .noMoreData)
            footer?.stateLabel.font = kBaseFont(15)
            footer?.isAutomaticallyChangeAlpha = true
            footer?.arrowView.image = nil
            
            self.mj_footer = footer 
            self.mj_footer.isHidden = true
            
            DispatchQueue.main.async(execute: {
                self.mj_footer.beginRefreshing {
                    self.isUserInteractionEnabled = false
                }
                
                self.mj_footer.endRefreshing {
                    self.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    func fixAreaInsets() -> Void {
        if #available(iOS 11.0, *) {
            if UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0 && UIApplication.shared.keyWindow!.safeAreaInsets.bottom != self.contentInset.bottom {
                var contentInset: UIEdgeInsets = self.contentInset
                contentInset.bottom = self.contentInset.bottom+UIApplication.shared.keyWindow!.safeAreaInsets.bottom
                self.contentInset = contentInset
            }
        }
    }

}
