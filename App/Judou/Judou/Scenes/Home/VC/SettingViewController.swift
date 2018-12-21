//
//  SettingViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class SettingViewController: BaseShowBarViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!
    private var cacheLabel: UILabel!
    private var cacheSize: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cacheLabel = UILabel()
        cacheLabel.font = kBaseFont(15)
        cacheLabel.textColor = kHEXColor(hex: "#666666", alpha: 1)
        cacheSize = 0.0

        // Do any additional setup after loading the view.
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = tableView.separatorColor?.withAlphaComponent(0.4)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        self.view.addSubview(tableView)
        self.getCacheSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getCacheSize()
    }
    // MARK: - 缓存
    private func getCacheSize() -> Void {
        DispatchQueue.global().async {
            let totalCost = YYImageCache.shared().diskCache.totalCost()
            self.cacheSize = round(Double(totalCost)/(1024.0*1024.0)*100.0)/100.0
            DispatchQueue.main.async {
                self.cacheLabel.text = "\(String(format: "%.2f", self.cacheSize)) M"
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && AccountManager.accountLogin() == true {
            return 26
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        } else if section == 1 {
            return 2
        } else if section == 2 {
            if AccountManager.accountLogin() == true {
                return 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellIdentifier")
        }
        
        for view: UIView in cell!.subviews {
            if view.tag >= 10 {
                view.removeFromSuperview()
            }
        }
        
        cell?.selectionStyle = .default
        cell?.textLabel?.textColor = .black
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.font = kBaseFont(17)
        cell?.accessoryView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "账号安全"
                break
            case 1:
                cell?.textLabel?.text = "修改资料"
                break
            case 2:
                cell?.textLabel?.text = "每日推送"
                let pushSwitch = UISwitch.init()
                pushSwitch.isOn = false
                pushSwitch.isEnabled = false
                
                cell?.accessoryView = pushSwitch
                cell?.selectionStyle = .none
                break
            case 3:
                cell?.textLabel?.text = "夜间模式"
                let modelSwitch = UISwitch.init()
                modelSwitch.isOn = false
                modelSwitch.isEnabled = false
                
                cell?.accessoryView = modelSwitch
                cell?.selectionStyle = .none
                break
            case 4:
                cell?.textLabel?.text = "缓存管理"
                cacheLabel.sizeToFit()
                cell?.accessoryView = cacheLabel
                
                if cacheSize <= 0.01 {
                    cell?.selectionStyle = .none
                }
                break
            case 5:
                cell?.textLabel?.text = "插件设置"
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "去给好评"
                break
            case 1:
                cell?.textLabel?.text = "关于我们"
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.textColor = kRGBColor(red: 240, green: 84, blue: 85, alpha: 1)
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.text = "退出登录"
                cell?.accessoryView = nil
                break
            default:
                break
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                if AccountManager.accountLogin() == true {
                    let infoVC = MyInfoViewController()
                    self.navigationController?.pushViewController(infoVC, animated: true)
                } else {
                    self.publicLoginAction()
                }
                
                break
            case 4:
                if cacheSize > 0.01 {
                    let alertViewController: UIAlertController = UIAlertController.init(title: nil, message: "您确定要清理缓存吗？", preferredStyle: .alert)
                    let cancel: UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction?) in
                        
                    })
                    
                    let clean: UIAlertAction = UIAlertAction.init(title: "确定", style: .default, handler: { [weak self] (action: UIAlertAction?) in
                        let hud = indicatorTextHUD("正在退出...")
                        
                        YYImageCache.shared().memoryCache.removeAllObjects()
                        YYImageCache.shared().diskCache.removeAllObjects()
                        
                        DispatchQueueMainAsyncAfter(deadline: .now()+0.6, target: self, execute: {
                            self?.getCacheSize()
                            hud.hide(true)
                        })
                    })
                    
                    alertViewController.addAction(cancel)
                    alertViewController.addAction(clean)
                    self.present(alertViewController, animated: true, completion: nil)
                }
                
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let url: String = APP_URL
                if #available(iOS 10, *) {
                    UIApplication.shared.open(URL.init(string: url)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL.init(string: url)!)
                }
                
                break
            case 1:
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let alertViewController: UIAlertController = UIAlertController.init(title: "提示", message: "确定退出当前账号？", preferredStyle: .alert)
                let cancel: UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction?) in
                    
                })
                
                let clean: UIAlertAction = UIAlertAction.init(title: "确定", style: .default, handler: { [weak self] (action: UIAlertAction?) in
                    let hud = indicatorTextHUD("正在退出...")
                    AccountManager.logout()
                    
                    DispatchQueueMainAsyncAfter(deadline: .now()+0.6, target: self, execute: {
                        hud.hide(false)
                        
                        self?.navigationController?.popViewController(animated: true)
                        showTextHUD("退出成功", inView: nil, hideAfterDelay: 1.8)
                    })
                })
                
                alertViewController.addAction(cancel)
                alertViewController.addAction(clean)
                self.present(alertViewController, animated: true, completion: nil)
                break
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - 登录
    @objc private func publicLoginAction() -> Void {
        let loginVC = LoginViewController()
        let nav = UINavigationController.init(rootViewController: loginVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
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
