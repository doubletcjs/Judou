//
//  LoginViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class LoginViewController: BaseShowBarViewController, UITextFieldDelegate {
    private var scrollView: UIScrollView!
    private var phoneTextField: UITextField!
    private var passwdTextField: UITextField!
    private var passwdVisibleButton: UIButton!
    private var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.loginCloseAction))
        self.title = "登录"
        
        scrollView = UIScrollView.init(frame: self.view.bounds)
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize.init(width: 0, height: kScreenHeight()-currentSafeAreaInsets().bottom)~
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        
        //logo
        let logoImageView = UIImageView.init(image: UIImage.init(named: "icon_login_judou"))
        logoImageView.contentMode = .scaleAspectFit
        scrollView.addSubview(logoImageView)
        logoImageView.center = CGPoint.init(x: scrollView.bounds.size.width/2, y: logoImageView.frame.size.height/2+30)~
        
        //手机号
        phoneTextField = UITextField.init(frame: CGRect.init(x: 40, y: logoImageView.frame.maxY+50, width: kScreenWidth()-40*2, height: 34)~)
        phoneTextField.placeholder = "手机号码"
        phoneTextField.font = kBaseFont(16)
        phoneTextField.keyboardType = .numberPad
        phoneTextField.returnKeyType = .next
        phoneTextField.clearButtonMode = .whileEditing
        phoneTextField.delegate = self
        scrollView.addSubview(phoneTextField)
        
        var lineLabel = UILabel.init(frame: CGRect.init(x: phoneTextField.frame.origin.x, y: phoneTextField.frame.maxY+2, width: phoneTextField.frame.size.width, height: 1)~)
        lineLabel.backgroundColor = kRGBColor(red: 219, green: 220, blue: 220, alpha: 1)
        scrollView.addSubview(lineLabel)
        
        //密码
        passwdTextField = UITextField.init(frame: CGRect.init(x: 40, y: phoneTextField.frame.maxY+26, width: kScreenWidth()-40*2, height: 34)~)
        passwdTextField.placeholder = "登录密码"
        passwdTextField.font = kBaseFont(16)
        passwdTextField.delegate = self
        passwdTextField.returnKeyType = .done
        passwdTextField.clearButtonMode = .whileEditing
        scrollView.addSubview(passwdTextField)
        passwdTextField.isSecureTextEntry = true
        
        passwdVisibleButton = UIButton.init(type: .custom)
        passwdVisibleButton.setImage(UIImage.init(named: "icon_pwd_invisible"), for: .normal)
        passwdVisibleButton.imageView?.contentMode = .scaleAspectFit
        passwdVisibleButton.contentMode = .scaleAspectFit
        passwdVisibleButton.contentHorizontalAlignment = .left
        passwdVisibleButton.addTarget(self, action: #selector(self.showOrHidePasswd), for: .touchUpInside)
        passwdTextField.rightView = passwdVisibleButton
        passwdTextField.rightViewMode = .always
        passwdVisibleButton.sizeToFit()
        
        lineLabel = UILabel.init(frame: CGRect.init(x: passwdTextField.frame.origin.x, y: passwdTextField.frame.maxY+2, width: passwdTextField.frame.size.width, height: 1)~)
        lineLabel.backgroundColor = kRGBColor(red: 219, green: 220, blue: 220, alpha: 1)
        scrollView.addSubview(lineLabel)
        
        //登录按钮
        loginButton = UIButton.init(type: .custom)
        loginButton.frame = CGRect.init(x: lineLabel.frame.origin.x, y: lineLabel.frame.maxY+30, width: lineLabel.frame.size.width, height: 46)~
        loginButton.backgroundColor = kRGBColor(red: 71, green: 73, blue: 76, alpha: 1)
        loginButton.layer.cornerRadius = 3
        loginButton.layer.masksToBounds = true
        loginButton.setTitle("登录", for: .normal)
        loginButton.titleLabel?.font = kBaseFont(16)
        loginButton.showsTouchWhenHighlighted = true
        scrollView.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(self.requestLogin), for: .touchUpInside)
        
        //注册
        let registerButton = UIButton.init(type: .system)
        registerButton.setTitle("快速注册", for: .normal)
        registerButton.titleLabel?.font = kBaseFont(12)
        registerButton.setTitleColor(.black, for: .normal)
        scrollView.addSubview(registerButton)
        registerButton.sizeToFit()
        registerButton.frame = CGRect.init(x: loginButton.frame.origin.x, y: loginButton.frame.maxY+12, width: registerButton.frame.size.width, height: registerButton.frame.size.height)~
        registerButton.addTarget(self, action: #selector(self.registerAction), for: .touchUpInside)
        
        //忘记密码
        let forgotButton = UIButton.init(type: .system)
        forgotButton.setTitle("忘记密码", for: .normal)
        forgotButton.titleLabel?.font = kBaseFont(12)
        forgotButton.setTitleColor(.black, for: .normal)
        scrollView.addSubview(forgotButton)
        forgotButton.sizeToFit()
        forgotButton.frame = CGRect.init(x: loginButton.frame.maxX-forgotButton.frame.size.width, y: loginButton.frame.maxY+12, width: forgotButton.frame.size.width, height: forgotButton.frame.size.height)~
        forgotButton.addTarget(self, action: #selector(self.forgotAction), for: .touchUpInside)
    }
    // MARK: - 登录
    @objc private func requestLogin() -> Void {
        if isStringEmpty(phoneTextField.text) == true || phoneTextField.text?.count != 11 {
            let alertView = UIAlertView.init(title: nil, message: "请输入合法的手机号", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
        } 
        
        let hud = indicatorTextHUD("正在登录")
        Networking.loginRequest(mobile: phoneTextField.text!, password: passwdTextField.text!) { (userModel, error) in
            if error != nil {
                hud.hide(false)
                
                showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
            } else {
                AccountManager.login(userModel!)
                
                DispatchQueueMainAsyncAfter(deadline: .now()+0.5, target: self, execute: {
                    hud.hide(false)
                    DispatchQueue.main.async(execute: {
                        showTextHUD("登录成功", inView: nil, hideAfterDelay: 1)
                        self.loginCloseAction()
                    })
                })
            }
        }
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            passwdTextField.becomeFirstResponder()
        } else if textField == passwdTextField {
            if isStringEmpty(phoneTextField.text) == true {
                phoneTextField.becomeFirstResponder()
            } else {
                
            }
        }
        
        return true
    }
    // MARK: - 显示、隐藏密码
    @objc private func showOrHidePasswd() -> Void {
        passwdTextField.isSecureTextEntry = !passwdTextField.isSecureTextEntry
        if passwdTextField.isSecureTextEntry == true {
            passwdVisibleButton.setImage(UIImage.init(named: "icon_pwd_invisible"), for: .normal)
        } else {
            passwdVisibleButton.setImage(UIImage.init(named: "icon_pwd_visible"), for: .normal)
        }
    }
    // MARK: - 注册
    @objc private func registerAction() -> Void {
        let registerVC = RegisterViewController()
        registerVC.title = "手机注册"
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    // MARK: - 找回密码
    @objc private func forgotAction() -> Void {
        let forgotVC = ForgotViewController()
        forgotVC.title = "找回密码"
        self.navigationController?.pushViewController(forgotVC, animated: true)
    }
    // MARK: - 关闭
    @objc private func loginCloseAction() -> Void {
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
