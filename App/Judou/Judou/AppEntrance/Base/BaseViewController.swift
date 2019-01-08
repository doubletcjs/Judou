//
//  BaseViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    var disablePopGestureRecognizer: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        if self.navigationController != nil && self.navigationController!.viewControllers.count > 1 {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.defaultReturnBackBarItem()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false && disablePopGestureRecognizer == true {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false && disablePopGestureRecognizer == true {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    // MARK: - 默认返回按钮
    private func defaultReturnBackBarItem() -> Void {
        let leftItem: UIBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: .plain, target: self, action: #selector(self.defaultBackAction)) 
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc func defaultBackAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - 登录
    @objc func publicLoginAction() -> Void {
        let loginVC = LoginViewController()
        let nav = UINavigationController.init(rootViewController: loginVC)
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
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
