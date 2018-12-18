//
//  ForgotViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class ForgotViewController: BaseShowBarViewController {
    private var scrollView: UIScrollView!
    private var phoneTextField: UITextField!
    private var verifycodeTextField: UITextField!
    private var passwdTextField: UITextField!
    private var verifyPasswdTextField: UITextField!
    private var verifycodeButton: UIButton!
    private var passwdVisibleButton: UIButton!
    private var verifyPasswdVisibleButton: UIButton!
    private var confirmButton: UIButton!
    
    private var timer: Timer?
    private var seconds: Int?

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
        phoneTextField = UITextField.init(frame: CGRect.init(x: 40, y: 30, width: kScreenWidth()-40*2, height: 34)~)
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
        passwdTextField.placeholder = "新密码"
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
        
        //确认密码
        verifyPasswdTextField = UITextField.init(frame: CGRect.init(x: 40, y: passwdTextField.frame.maxY+26, width: kScreenWidth()-40*2, height: 34)~)
        verifyPasswdTextField.placeholder = "确认密码"
        verifyPasswdTextField.font = kBaseFont(16)
        verifyPasswdTextField.returnKeyType = .done
        verifyPasswdTextField.clearButtonMode = .whileEditing
        scrollView.addSubview(verifyPasswdTextField)
        verifyPasswdTextField.isSecureTextEntry = true
        verifyPasswdTextField.addTarget(self, action: #selector(self.textFieldValueChanged(_:)), for: .editingChanged)
        
        verifyPasswdVisibleButton = UIButton.init(type: .custom)
        verifyPasswdVisibleButton.setImage(UIImage.init(named: "icon_pwd_invisible"), for: .normal)
        verifyPasswdVisibleButton.imageView?.contentMode = .scaleAspectFit
        verifyPasswdVisibleButton.contentMode = .scaleAspectFit
        verifyPasswdVisibleButton.contentHorizontalAlignment = .left
        verifyPasswdVisibleButton.addTarget(self, action: #selector(self.showOrHideVerifyPasswd), for: .touchUpInside)
        verifyPasswdTextField.rightView = verifyPasswdVisibleButton
        verifyPasswdTextField.rightViewMode = .always
        verifyPasswdVisibleButton.sizeToFit()
        
        lineLabel = UILabel.init(frame: CGRect.init(x: verifyPasswdTextField.frame.origin.x, y: verifyPasswdTextField.frame.maxY+2, width: passwdTextField.frame.size.width, height: 1)~)
        lineLabel.backgroundColor = kRGBColor(red: 219, green: 220, blue: 220, alpha: 1)
        scrollView.addSubview(lineLabel)
        
        //确认按钮
        confirmButton = UIButton.init(type: .custom)
        confirmButton.frame = CGRect.init(x: lineLabel.frame.origin.x, y: lineLabel.frame.maxY+30, width: lineLabel.frame.size.width, height: 46)~
        confirmButton.backgroundColor = kRGBColor(red: 71, green: 73, blue: 76, alpha: 1)
        confirmButton.layer.cornerRadius = 3
        confirmButton.layer.masksToBounds = true
        confirmButton.setTitle("注册", for: .normal)
        confirmButton.titleLabel?.font = kBaseFont(16)
        confirmButton.showsTouchWhenHighlighted = true
        scrollView.addSubview(confirmButton)
        confirmButton.addTarget(self, action: #selector(self.confirmResetPasswd), for: .touchUpInside)
    }
    // MARK: - 重置密码
    @objc private func confirmResetPasswd() -> Void {
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
        
        if isStringEmpty(verifyPasswdTextField.text) == true || verifyPasswdTextField.text!.count < 6 || verifyPasswdTextField.text!.count > 20 {
            let alertView = UIAlertView.init(title: nil, message: "请输入合法的密码(6-20位字母数字密码)", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
        }
        
        if passwdTextField.text != verifyPasswdTextField.text {
            let alertView = UIAlertView.init(title: nil, message: "两次输入密码不一致", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
            return
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
        
        if textField == verifyPasswdTextField {
            if verifyPasswdTextField.text!.count > 20 {
                let text: String = textField.text!
                let endIndex = text.index(text.startIndex, offsetBy: 20)
                
                verifyPasswdTextField.text = String(text.prefix(upTo: endIndex))
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
    
    @objc private func showOrHideVerifyPasswd() -> Void {
        verifyPasswdTextField.isSecureTextEntry = !verifyPasswdTextField.isSecureTextEntry
        if verifyPasswdTextField.isSecureTextEntry == true {
            verifyPasswdVisibleButton.setImage(UIImage.init(named: "icon_pwd_invisible"), for: .normal)
        } else {
            verifyPasswdVisibleButton.setImage(UIImage.init(named: "icon_pwd_visible"), for: .normal)
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
