//
//  RegisterViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

let kCountDownSecond: Int = 60

class RegisterViewController: BaseShowBarViewController {
    private var scrollView: UIScrollView!
    private var phoneTextField: UITextField!
    private var verifycodeTextField: UITextField!
    private var passwdTextField: UITextField!
    private var verifycodeButton: UIButton!
    private var passwdVisibleButton: UIButton!
    private var registerButton: UIButton!
    
    private var timer: Timer?
    private var seconds: Int?
    
    private var adminRegister: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        seconds = kCountDownSecond
        timer = nil
        
        scrollView = UIScrollView.init(frame: self.view.bounds)
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize.init(width: 0, height: kScreenHeight()-currentSafeAreaInsets().bottom)~
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        
        //手机号
        phoneTextField = UITextField.init(frame: CGRect.init(x: 40, y: 90, width: kScreenWidth()-40*2, height: 34)~)
        phoneTextField.placeholder = "手机号码"
        phoneTextField.font = kBaseFont(16)
        phoneTextField.keyboardType = .numberPad
        phoneTextField.returnKeyType = .next
        phoneTextField.clearButtonMode = .whileEditing
        scrollView.addSubview(phoneTextField)
        
        var lineLabel = UILabel.init(frame: CGRect.init(x: phoneTextField.frame.origin.x, y: phoneTextField.frame.maxY+2, width: phoneTextField.frame.size.width, height: 1)~)
        lineLabel.backgroundColor = kRGBColor(red: 219, green: 220, blue: 220, alpha: 1)
        scrollView.addSubview(lineLabel)
        
        //验证码
        verifycodeTextField = UITextField.init(frame: CGRect.init(x: 40, y: phoneTextField.frame.maxY+26, width: kScreenWidth()-40*2, height: 34)~)
        verifycodeTextField.placeholder = "您收到的验证码"
        verifycodeTextField.font = kBaseFont(16)
        verifycodeTextField.returnKeyType = .next
        verifycodeTextField.clearButtonMode = .whileEditing
        scrollView.addSubview(verifycodeTextField)
        
        verifycodeButton = UIButton.init(type: .custom)
        verifycodeButton.setTitle("60s后重新发送", for: .normal)
        verifycodeButton.setTitleColor(kRGBColor(red: 180, green: 160, blue: 118, alpha: 1), for: .normal)
        verifycodeButton.titleLabel?.font = kBaseFont(16)
        verifycodeButton.addTarget(self, action: #selector(self.requestVerifycode), for: .touchUpInside)
        verifycodeButton.contentHorizontalAlignment = .right
        verifycodeTextField.rightView = verifycodeButton
        verifycodeTextField.rightViewMode = .always
        verifycodeButton.sizeToFit()
        
        lineLabel = UILabel.init(frame: CGRect.init(x: verifycodeTextField.frame.origin.x, y: verifycodeTextField.frame.maxY+2, width: verifycodeTextField.frame.size.width, height: 1)~)
        lineLabel.backgroundColor = kRGBColor(red: 219, green: 220, blue: 220, alpha: 1)
        scrollView.addSubview(lineLabel)
        verifycodeButton.setTitle("获取验证码", for: .normal)
        
        //密码
        passwdTextField = UITextField.init(frame: CGRect.init(x: 40, y: verifycodeTextField.frame.maxY+26, width: kScreenWidth()-40*2, height: 34)~)
        passwdTextField.placeholder = "6-20位字母数字密码"
        passwdTextField.font = kBaseFont(16)
        passwdTextField.returnKeyType = .done
        passwdTextField.clearButtonMode = .whileEditing
        scrollView.addSubview(passwdTextField)
        passwdTextField.isSecureTextEntry = true
        passwdTextField.addTarget(self, action: #selector(self.textFieldValueChanged(_:)), for: .editingChanged)
        
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
        
        //注册按钮
        registerButton = UIButton.init(type: .custom)
        registerButton.frame = CGRect.init(x: lineLabel.frame.origin.x, y: lineLabel.frame.maxY+30, width: lineLabel.frame.size.width, height: 46)~
        registerButton.backgroundColor = kRGBColor(red: 71, green: 73, blue: 76, alpha: 1)
        registerButton.layer.cornerRadius = 3
        registerButton.layer.masksToBounds = true
        registerButton.setTitle("注册", for: .normal)
        registerButton.titleLabel?.font = kBaseFont(16)
        registerButton.showsTouchWhenHighlighted = true
        scrollView.addSubview(registerButton)
        registerButton.addTarget(self, action: #selector(self.requestRegister), for: .touchUpInside)
        
        //是否开放注册管理员
        Networking.adminAvailable { [weak self] (isAdminAvailable, error) in
            if isAdminAvailable == true {
                let availableSwitch = UISwitch.init()
                availableSwitch.addTarget(self, action: #selector(self?.availableSwitchAction(_:)), for: .valueChanged)
                self?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: availableSwitch)
            }
        }
    }
    // MARK: - 开启、关闭注册管理员
    @objc private func availableSwitchAction(_ availableSwitch: UISwitch) -> Void {
        availableSwitch.isOn = !availableSwitch.isOn
        
        adminRegister = availableSwitch.isOn
    }
    // MARK: - 注册
    @objc private func requestRegister() -> Void {
        if isStringEmpty(phoneTextField.text) == true || phoneTextField.text?.count != 11 {
            let alertView = UIAlertView.init(title: nil, message: "请输入合法的手机号", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
        }
        
        if isStringEmpty(verifycodeTextField.text) == true {
            let alertView = UIAlertView.init(title: nil, message: "请输入合法的验证码", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
        }
        
        if isStringEmpty(passwdTextField.text) == true || passwdTextField.text!.count < 6 || passwdTextField.text!.count > 20 {
            let alertView = UIAlertView.init(title: nil, message: "请输入合法的密码(6-20位字母数字密码)", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
        }
        
        let hud = indicatorTextHUD("正在注册")
        
        if adminRegister == true {
            Networking.adminRegisterRequest(mobile: phoneTextField.text!, password: passwdTextField.text!) { (userModel, error) in
                if error != nil {
                    hud.hide(false)
                    
                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                } else {
                    AccountManager.login(userModel!)
                    
                    DispatchQueueMainAsyncAfter(deadline: .now()+0.5, target: self, execute: {
                        hud.hide(false)
                        DispatchQueue.main.async(execute: {
                            showTextHUD("注册成功", inView: nil, hideAfterDelay: 1)
                            self.dismiss(animated: true, completion: nil)
                        })
                    })
                }
            }
        } else {
            Networking.mobileRegisterRequest(mobile: phoneTextField.text!, password: passwdTextField.text!) { (userModel, error) in
                if error != nil {
                    hud.hide(false)
                    
                    showTextHUD(error?.localizedDescription, inView: nil, hideAfterDelay: 1.5)
                } else {
                    AccountManager.login(userModel!)
                    
                    DispatchQueueMainAsyncAfter(deadline: .now()+0.5, target: self, execute: {
                        hud.hide(false)
                        DispatchQueue.main.async(execute: {
                            showTextHUD("注册成功", inView: nil, hideAfterDelay: 1)
                            self.dismiss(animated: true, completion: nil)
                        })
                    })
                }
            }
        }
    }
    // MARK: - 限制密码长度
    @objc private func textFieldValueChanged(_ textField: UITextField) -> Void {
        if textField == passwdTextField {
            if passwdTextField.text!.count > 20 {
                let text: String = textField.text!
                let endIndex = text.index(text.startIndex, offsetBy: 20)
                
                passwdTextField.text = String(text.prefix(upTo: endIndex))
            }
        }
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
    // MARK: - 获取验证码
    @objc private func requestVerifycode() -> Void {
        if isStringEmpty(phoneTextField.text) == true || phoneTextField.text?.count != 11 {
            let alertView = UIAlertView.init(title: nil, message: "请输入合法的手机号", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
        }
        //获取验证码
        Networking.getVerificationCode(phoneTextField.text) { [weak self] (aError: NSError?) in
            if self != nil {
                if aError != nil {
                    Log("\(String(describing: aError))")
                } else {
                    self?.startCount()
                }
            }
        }
    }
    // MARK: - 倒数时
    @objc private func startCount() -> Void {
        seconds = kCountDownSecond
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countSeconds), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    
    @objc private func countSeconds() -> Void {
        seconds = seconds!-1
        verifycodeButton.isUserInteractionEnabled = false
        
        if seconds! > 0 {
            verifycodeButton.setTitle("\(String(seconds!))s后重新发送", for: .normal)
        } else {
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            
            seconds = kCountDownSecond
            verifycodeButton.isUserInteractionEnabled = true
            verifycodeButton.setTitle("获取验证码", for: .normal)
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
