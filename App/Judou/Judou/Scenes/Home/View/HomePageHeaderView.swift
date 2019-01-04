//
//  HomePageHeaderView.swift
//  Judou
//
//  Created by 4work on 2018/12/21.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class HomePageHeaderView: UIView {
    var account: UserModel! {
        didSet {
            if account != nil {
                let loginUserID: String = UserModel.fetchUser().userId
                if AccountManager.accountLogin() == true && account.userId == loginUserID {
                    button.setTitle("编辑", for: .normal)
                    button.removeTarget(self, action: #selector(self.attentionAccount), for: .touchUpInside)
                    button.addTarget(self, action: #selector(self.showMyInfo), for: .touchUpInside)
                } else {
                    if account.isAttention == true {
                        button.setTitle("取消关注", for: .normal)
                    } else {
                        button.setTitle("关注", for: .normal)
                    }
                }
                
                nameLabel.text = account.nickname
                nameLabel.sizeToFit()
                
                let imageWH: CGFloat = 22
                var rect = nameLabel.frame
                rect.origin.x = (self.bounds.size.width-nameLabel.frame.size.width)/2.0
                rect.origin.y = fanButton.frame.origin.y-rect.size.height-8
                nameLabel.frame = rect~
                
                portraitImageView.center = CGPoint.init(x: button.center.x, y: nameLabel.frame.origin.y-16-portraitImageView.frame.size.height/2)~
                portraitImageView.contentMode = .scaleAspectFill
                portraitImageView.yy_setImage(with: URL.init(string: account.portrait),
                                              placeholder: UIImage.init(named: "topic_default_avatar"),
                                              options: kWebImageOptions,
                                              completion: nil)
                
                if account.gender == 0 {
                    genderImageView.isHidden = true
                } else {
                    genderImageView.isHidden = false
                    genderImageView.image = UIImage.init(named: "icon_male")
                    if account.gender == 2 {
                        genderImageView.image = UIImage.init(named: "icon_female")
                    }
                    
                    genderImageView.contentMode = .scaleAspectFit
                    rect = genderImageView.frame
                    rect.size.width = imageWH
                    rect.size.height = imageWH
                    rect.origin.x = nameLabel.frame.maxX+6
                    genderImageView.frame = rect~
                    genderImageView.center = CGPoint.init(x: genderImageView.center.x, y: nameLabel.center.y)~
                }
            }
        }
    }
    private var button: UIButton!
    private var attentionButton: UIButton!
    private var fanButton: UIButton!
    private var nameLabel: UILabel!
    private var genderImageView: UIImageView!
    private var portraitImageView: UIImageView!
    
    var currentVC: UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //关注、编辑
        button = UIButton.init(type: .system)
        button.frame = CGRect.init(x: (self.bounds.size.width-120)/2, y: self.bounds.size.height-22-28, width: 120, height: 28)~
        self.addSubview(button)
        button.layer.cornerRadius = button.frame.size.height/2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = kBaseFont(14)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("关注", for: .normal)
        button.addTarget(self, action: #selector(self.attentionAccount), for: .touchUpInside)
        
        //关注
        attentionButton = UIButton.init(type: .system)
        attentionButton.titleLabel?.font = kBaseFont(14)
        attentionButton.setTitleColor(.white, for: .normal)
        attentionButton.setTitle("关注0", for: .normal)
        attentionButton.addTarget(self, action: #selector(self.showAttention), for: .touchUpInside)
        self.addSubview(attentionButton)
        attentionButton.sizeToFit()
        attentionButton.frame = CGRect.init(x: self.bounds.size.width/2-attentionButton.frame.size.width-6, y: button.frame.origin.y-16-16, width: attentionButton.frame.size.width, height: 16)~
        
        //粉丝
        fanButton = UIButton.init(type: .system)
        fanButton.titleLabel?.font = kBaseFont(14)
        fanButton.setTitleColor(.white, for: .normal)
        fanButton.setTitle("粉丝0", for: .normal)
        fanButton.addTarget(self, action: #selector(self.showFan), for: .touchUpInside)
        self.addSubview(fanButton)
        fanButton.sizeToFit()
        fanButton.frame = CGRect.init(x: self.bounds.size.width/2+6, y: attentionButton.frame.origin.y, width: fanButton.frame.size.width, height: 16)~
        
        //分割线
        let lineLabel = UILabel.init(frame: CGRect.init(x: (self.bounds.size.width-0.8)/2, y: 0, width: 0.8, height: 17)~)
        lineLabel.backgroundColor = UIColor.white
        self.addSubview(lineLabel)
        lineLabel.center = CGPoint.init(x: lineLabel.center.x, y: attentionButton.center.y)~
        
        //用户名
        nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(22)
        nameLabel.textColor = .white
        self.addSubview(nameLabel)
        //性别
        genderImageView = UIImageView.init()
        genderImageView.contentMode = .scaleAspectFit
        self.addSubview(genderImageView)
        
        //头像
        portraitImageView = UIImageView.init()
        portraitImageView.frame = CGRect.init(x: 0, y: 0, width: 86, height: 86)~
        portraitImageView.contentMode = .scaleAspectFill
        portraitImageView.layer.cornerRadius = portraitImageView.frame.size.width/2
        portraitImageView.layer.masksToBounds = true
        portraitImageView.clipsToBounds = true
        portraitImageView.image = UIImage.init(named: "topic_default_avatar")
        self.addSubview(portraitImageView)
        portraitImageView.isUserInteractionEnabled = true
        portraitImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showPortrait)))
        portraitImageView.center = CGPoint.init(x: button.center.x, y: fanButton.frame.origin.y-16-portraitImageView.frame.size.height/2)~
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } 
    // MARK: - 关注、取消关注
    @objc private func attentionAccount() -> Void {
    }
    // MARK: - 查看关注
    @objc private func showAttention() -> Void {
        let attentionVC = AccountListViewController()
        var gender: String = "Ta"
        if account.gender == 1 {
            gender = "他"
        } else if account.gender == 2 {
            gender = "她"
        }
        attentionVC.title = "\(gender)"+"的关注"
        currentVC.navigationController?.pushViewController(attentionVC, animated: true)
    }
    // MARK: - 查看粉丝
    @objc private func showFan() -> Void {
        let fanVC = AccountListViewController()
        var gender: String = "Ta"
        if account.gender == 1 {
            gender = "他"
        } else if account.gender == 2 {
            gender = "她"
        }
        fanVC.title = "\(gender)"+"的粉丝"
        fanVC.isFan = true
        currentVC.navigationController?.pushViewController(fanVC, animated: true)
    }
    // MARK: - 查看头像
    @objc private func showPortrait() -> Void {
        
    }
    // MARK: - 编辑个人资料
    @objc private func showMyInfo() -> Void {
        let infoVC = MyInfoViewController()
        currentVC.navigationController?.pushViewController(infoVC, animated: true)
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
