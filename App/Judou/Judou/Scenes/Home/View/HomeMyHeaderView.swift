//
//  HomeMyHeaderView.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias homePageTapBlock = () -> Void
typealias itemTapBlock = (_ index: Int) -> Void

class HomeMyHeaderView: UIView {
    var homePageTapHandle: homePageTapBlock?
    var itemTapHandle: itemTapBlock?
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var tipLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.homePageTapAction)))
        
        //头像
        imageView = UIImageView.init(frame: CGRect.init(x: 20, y: 30, width: 58, height: 58)~)
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        imageView.yy_setImage(with: URL.init(string: ""),
                              placeholder: UIImage.init(named: "topic_default_avatar"),
                              options: kWebImageOptions,
                              completion: nil)
        
        let baseX = imageView.frame.maxX+20
        let maxW = frame.size.width-(baseX+20)
        //用户名
        nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(17)
        nameLabel.textColor = .black
        nameLabel.text = "点击头像登录"
        nameLabel.lineBreakMode = .byTruncatingTail
        self.addSubview(nameLabel)
        var nameSize = nameLabel.sizeThatFits(CGSize.init(width: maxW, height: 18)~)
        if nameSize.width > maxW {
            nameSize.width = maxW
        }
        
        nameLabel.frame = CGRect.init(x: baseX, y: imageView.center.y-nameSize.height-2, width: nameSize.width, height: nameSize.height)~
        //提示
        tipLabel = UILabel.init()
        tipLabel.font = kBaseFont(14)~
        tipLabel.textColor = .lightGray
        tipLabel.text = "登录句读收藏喜欢的句子"
        self.addSubview(tipLabel)
        var tipSize = tipLabel.sizeThatFits(CGSize.init(width: maxW, height: 15)~)
        if tipSize.width > maxW {
            tipSize.width = maxW
        }
        
        tipLabel.frame = CGRect.init(x: baseX, y: imageView.center.y+2, width: tipSize.width, height: tipSize.height)~
        
        //内容
        let items: [String] = ["订阅", "句子", "喜欢"];
        let lineW: CGFloat = 1
        let itemW: CGFloat = (frame.size.width-lineW*CGFloat(items.count-1))/CGFloat(items.count)
        let itemH: CGFloat = 54
        let itemY: CGFloat = tipLabel.frame.maxY+40
        
        for idx in 0...items.count-1 {
            let button = UIButton.init(frame: CGRect.init(x: (itemW+lineW)*CGFloat(idx), y: itemY, width: itemW, height: itemH)~)
            button.tag = 10+idx
            self.addSubview(button)
            button.addTarget(self, action: #selector(self.itemTapAction(_:)), for: .touchUpInside)
            
            if idx < items.count-1 {
                let lineLabel = UILabel.init(frame: CGRect.init(x: button.frame.maxX, y: button.frame.origin.y+12, width: lineW, height: button.frame.size.height-12*2)~)
                lineLabel.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
                self.addSubview(lineLabel)
            }
            
            let centerY: CGFloat = button.frame.size.height/2.0
            let valueLabel = UILabel.init()
            valueLabel.font = kBaseFont(16)
            valueLabel.textColor = .black
            valueLabel.textAlignment = .center
            valueLabel.text = "0"
            valueLabel.tag = 99999
            button.addSubview(valueLabel)
            var valueSize = valueLabel.sizeThatFits(CGSize.init(width: button.frame.size.width, height: 17)~)
            if valueSize.width > button.frame.size.width {
                valueSize.width = button.frame.size.width
            }
            valueLabel.frame = CGRect.init(x: (button.frame.size.width-valueSize.width)/2, y: centerY-valueSize.height-2, width: valueSize.width, height: valueSize.height)~
            
            let itemLabel = UILabel.init()
            itemLabel.font = kBaseFont(13)
            itemLabel.textColor = .lightGray
            itemLabel.textAlignment = .center
            itemLabel.text = items[idx]
            button.addSubview(itemLabel)
            var itemSize = itemLabel.sizeThatFits(CGSize.init(width: button.frame.size.width, height: 14)~)
            if itemSize.width > button.frame.size.width {
                itemSize.width = button.frame.size.width
            }
            itemLabel.frame = CGRect.init(x: (button.frame.size.width-itemSize.width)/2, y: centerY+2, width: itemSize.width, height: itemSize.height)~
        }
        
        var rect = frame
        rect.size.height = tipLabel.frame.maxY+44+54+12
        self.frame = rect
        
        let coverButton = UIButton.init(frame: CGRect.init(x: 0, y: imageView.frame.maxY+16, width: self.bounds.size.width, height: self.bounds.size.height-(imageView.frame.maxY+16))~)
        self.insertSubview(coverButton, belowSubview: imageView)
        
        self.refreshUserInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 刷新用户信息
    func refreshUserInfo() -> Void {
        if AccountManager.accountLogin() == true {
            let userModel = UserModel.fetchUser()
            
            imageView.yy_setImage(with: URL.init(string: kBaseURL+userModel.portrait),
                                  placeholder: UIImage.init(named: "topic_default_avatar"),
                                  options: kWebImageOptions,
                                  completion: nil)
            nameLabel.text = userModel.nickname
            tipLabel.text = "点击查看个人主页"
            
            let values: [String] = ["0", "\(userModel.postCount)", "\(userModel.praiseCount)"];
            self.subviews.forEach { (view) in
                if view.tag >= 10 {
                    let btn = view as! UIButton
                    let label = btn.viewWithTag(99999) as! UILabel
                    label.text = values[btn.tag-10]
                }
            }
        } else {
            imageView.yy_setImage(with: URL.init(string: ""),
                                  placeholder: UIImage.init(named: "topic_default_avatar"),
                                  options: kWebImageOptions,
                                  completion: nil)
            nameLabel.text = "点击头像登录"
            tipLabel.text = "登录句读收藏喜欢的句子"
            
            let values: [String] = ["0", "0", "0"];
            self.subviews.forEach { (view) in
                if view.tag >= 10 {
                    let btn = view as! UIButton
                    let label = btn.viewWithTag(99999) as! UILabel
                    label.text = values[btn.tag-10]
                }
            }
        }
    }
    // MARK: - 查看个人主页
    @objc private func homePageTapAction() -> Void {
        if homePageTapHandle != nil {
            homePageTapHandle!()
        }
    }
    // MARK: - 跳转相关页面
    @objc private func itemTapAction(_ button: UIButton) -> Void {
        if itemTapHandle != nil {
            itemTapHandle!(button.tag-10)
        }
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
