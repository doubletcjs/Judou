//
//  AppDelegate.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

let kAppdelegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var networkReachable: Bool!
    private let net = NetworkReachabilityManager()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.isStatusBarHidden = false
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let tabBar = BaseTabBarController()
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
        
        net.listener = { [weak self] status in
            if self?.net.isReachable ?? false {
                self?.networkReachable = false
                
                switch status {
                case .notReachable:
                    print("the noework is not reachable")
                case .unknown:
                    print("It is unknown whether the network is reachable")
                case .reachable(.ethernetOrWiFi):
                    print("通过WiFi链接")
                    self?.networkReachable = true
                case .reachable(.wwan):
                    print("通过移动网络链接")
                    self?.networkReachable = true
                }
            } else {
                print("网络不可用")
            }
        }
        net.startListening() 
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

