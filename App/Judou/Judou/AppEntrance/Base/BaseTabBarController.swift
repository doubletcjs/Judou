//
//  BaseTabBarController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.tintColor = UIColor.black
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.isTranslucent = false
        
        let dailyVC: UIViewController = DailyViewController()
        dailyVC.tabBarItem.image = UIImage.init(named: "tab_home")
        dailyVC.tabBarItem.selectedImage = UIImage.init(named: "tab_home_selected")
        
        let squareVC: UIViewController = SquareViewController()
        squareVC.tabBarItem.image = UIImage.init(named: "tab_explore")
        squareVC.tabBarItem.selectedImage = UIImage.init(named: "tab_explore_selected")
        
        let homeVC: UIViewController = HomeViewController()
        homeVC.tabBarItem.image = UIImage.init(named: "tab_mine")
        homeVC.tabBarItem.selectedImage = UIImage.init(named: "tab_mine_selected")
        
        let dailyNav = UINavigationController.init(rootViewController: dailyVC)
        let squareNav = UINavigationController.init(rootViewController: squareVC)
        let homeNav = UINavigationController.init(rootViewController: homeVC)
        
        self.viewControllers = [dailyNav, squareNav, homeNav]
        
        let offSet: CGFloat = 6
        for item: UITabBarItem in self.tabBar.items! {
            item.imageInsets = UIEdgeInsets.init(top: offSet, left: 0, bottom: -offSet, right: 0)
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
