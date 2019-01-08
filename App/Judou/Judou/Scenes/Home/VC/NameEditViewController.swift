//
//  NameEditViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/21.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias ChangeNickNameBlock = (_ name: String) -> Void

class NameEditViewController: BaseShowBarViewController {
    private var textField: UITextField!
    var changeNameHandle: ChangeNickNameBlock?
    var currentNickName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "昵称"
        self.view.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        
        textField = UITextField.init(frame: CGRect.init(x: 0, y: kStatusBarHeight()+self.navigationController!.navigationBar.frame.size.height+20, width: kScreenWidth(), height: 38)~)
        textField.backgroundColor = .white
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "2～16个字"
        textField.font = kBaseFont(17)
        textField.text = currentNickName
        
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 16, height: textField.frame.size.height)~)
        rightView.backgroundColor = textField.backgroundColor
        textField.leftView = rightView
        
        self.view.addSubview(textField)
        
        let items: [String] = ["昵称要求:", "1、昵称长度在2-16个字符以内", "2、昵称必须是唯一的，不能和已有用户重复", "3、昵称不能包含空白字符，如空格、回车或者换行符"]
        let itemX: CGFloat = 28
        let itemW: CGFloat = kScreenWidth()-itemX*2
        var itemY: CGFloat = textField.frame.maxY+24
        
        items.forEach { (item) in
            let label = UILabel.init(frame: CGRect.init(x: itemX, y: itemY, width: itemW, height: 15)~)
            label.font = kBaseFont(13)
            label.textColor = kRGBColor(red: 181, green: 182, blue: 183, alpha: 1)
            label.text = item
            self.view.addSubview(label)
            
            itemY = label.frame.maxY+15
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "修改", style: .plain, target: self, action: #selector(self.changeNameAction))
    }
    // MARK: - 修改
    @objc private func changeNameAction() -> Void {
        if isStringEmpty(textField.text) == true {
            showTextHUD("昵称不能为空", inView: nil, hideAfterDelay: 1.5)
            return
        } else {
            var range: Range? = textField.text!.range(of: " ")
            if range != nil && range!.isEmpty == false {
                showTextHUD("昵称不能带空字符", inView: nil, hideAfterDelay: 1.5)
                return
            }
            
            range = textField.text!.range(of: "\n")
            if range != nil && range!.isEmpty == false {
                showTextHUD("昵称不能带回车或者换行符", inView: nil, hideAfterDelay: 1.5)
                return
            }
            
            range = textField.text!.range(of: "\r")
            if range != nil && range!.isEmpty == false {
                showTextHUD("昵称不能带回车或者换行符", inView: nil, hideAfterDelay: 1.5)
                return
            }
            
            range = textField.text!.range(of: "User_")
            if range != nil && range!.isEmpty == false {
                if textField.text!.hasPrefix("User_") == true {
                    let number = textField.text!.replacingOccurrences(of: "User_", with: "")
                    
                    func isPurnInt(string: String) -> Bool {
                        let scan: Scanner = Scanner(string: string)
                        var val: Int = 0
                        return scan.scanInt(&val) && scan.isAtEnd
                    }
                    
                    if isPurnInt(string: number) == true {
                        showTextHUD("昵称不能为默认样式占位符", inView: nil, hideAfterDelay: 1.5)
                        return
                    }
                }
            }
        }
        
        if changeNameHandle != nil {
            changeNameHandle!(textField.text ?? "")
        }
        
        self.navigationController?.popViewController(animated: true)
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
