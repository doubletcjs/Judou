//
//  JSVariableMenuControl.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias VariableMenuHandleBlock = (_ inUseTitles: [String], _ unUseTitles: [String]) -> Void

class JSVariableMenuControl: NSObject {
    private var nav: UINavigationController!
    private var variableMenu: JSVariableMenuView!
    private var handle: VariableMenuHandleBlock?
    private var blurEffectView: UIVisualEffectView!
    
    var screenShot: UIImage!
    
    override init() {
        super.init()
        
        variableMenu = JSVariableMenuView.init(frame: UIScreen.main.bounds)
        
        nav = UINavigationController.init(rootViewController: UIViewController())
        nav.topViewController?.title = "频道管理"
        nav.topViewController?.view = variableMenu
        nav.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(self.backMethod))
    }
    
    @objc private func backMethod() -> Void {
        UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
            var frame: CGRect = self.nav.view.frame
            frame.origin.y = -self.nav.view.bounds.size.height
            self.nav.view.frame = frame
        }) { (finish) in
            self.nav.view.removeFromSuperview()
        }
        
        if handle != nil {
            handle!(variableMenu.inUseTitles, variableMenu.unUseTitles)
        }
    }
    
    func showChannelViewWith(inUseTitles: [String], unUseTitles: [String], fixedNum: Int, completionHandler: VariableMenuHandleBlock?) -> Void {
        handle = completionHandler
        
        variableMenu.inUseTitles = inUseTitles
        variableMenu.unUseTitles = unUseTitles
        variableMenu.fixedNum = fixedNum
        variableMenu.reloadData()
        
        var frame: CGRect = nav.view.frame
        frame.origin.y = -nav.view.bounds.size.height
        nav.view.frame = frame
        nav.view.alpha = 0
        
        variableMenu.backgroundColor = UIColor.init(patternImage: screenShot) 
        
        if blurEffectView == nil {
            let blurEffect = UIBlurEffect.init(style: .light)
            blurEffectView = UIVisualEffectView.init(effect: blurEffect)
            blurEffectView.frame = CGRect.init(x: 0, y: 0, width: variableMenu.bounds.size.width, height: variableMenu.bounds.size.height)~
        } else {
            blurEffectView.removeFromSuperview()
        }
        
        variableMenu.insertSubview(blurEffectView, at: 0)
        
        UIApplication.shared.keyWindow?.addSubview(nav.view)
        UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
            self.nav.view.alpha = 1
            self.nav.view.frame = UIScreen.main.bounds
        })
    }
}
