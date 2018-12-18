//
//  UINavigationController+Unitl.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

extension UINavigationController {

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBar.tintColor = UIColor.black
        self.navigationBar.barTintColor = UIColor.white
        
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.navigationBar.tintColor! as UIColor, NSAttributedString.Key.font: kBaseFont(17)]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font : kBaseFont(16)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font : kBaseFont(16)], for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font : kBaseFont(16)], for: .highlighted)
        
        self.navigationBar.shadowImage = UIImage()
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
