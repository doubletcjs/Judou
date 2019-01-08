//
//  AddFunctionViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/16.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class AddFunctionViewController: BaseShowBarViewController {
    var isFamous: Bool! = false // 名人、书籍

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.addCloseAction))
        
        if UserModel.fetchUser().level == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_add"), style: .plain, target: self, action: #selector(self.createCollectioAction))
        }
    }
    // MARK: - 添加收藏夹、名人、书籍
    @objc private func createCollectioAction() -> Void {
        let creationVC = CreationViewController()
        creationVC.createType = 2
        if isFamous == true {
            creationVC.createType = 1
        }
        let nav = UINavigationController.init(rootViewController: creationVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - 关闭
    @objc private func addCloseAction() -> Void {
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
