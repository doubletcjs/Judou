//
//  AccountListCell.swift
//  Judou
//
//  Created by 4work on 2018/12/22.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class AccountListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func createAccountCell(_ account: UserModel) -> Void {
        let space: CGFloat = 16
        let imageWH: CGFloat = 50
        let cellHeight: CGFloat = imageWH+space*2
        
        var itemTag: Int = 10
        
        //关注
        let button = UIButton.init(type: .system)
        button.frame = CGRect.init(x: kScreenWidth()-self.separatorInset.left-74, y: (cellHeight-28)/2, width: 74, height: 28)~
        button.tag = itemTag
        itemTag += 1
        self.addSubview(button)
        button.layer.cornerRadius = button.frame.size.height/2
        button.layer.borderWidth = 0.8
        button.titleLabel?.font = kBaseFont(14)
        button.setTitle("关注", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = kRGBColor(red: 206, green: 210, blue: 219, alpha: 1).cgColor
        
        if account.isAttention == true {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = kRGBColor(red: 206, green: 210, blue: 219, alpha: 1)
        }
        
        //头像
        let portraitImageView = UIImageView.init(frame: CGRect.init(x: self.separatorInset.left, y: space, width: imageWH, height: imageWH)~)
        portraitImageView.layer.cornerRadius = portraitImageView.frame.size.height/2
        portraitImageView.layer.masksToBounds = true
        portraitImageView.clipsToBounds = true
        portraitImageView.contentMode = .scaleAspectFill
        portraitImageView.tag = itemTag
        itemTag += 1
        self.addSubview(portraitImageView)
        
        portraitImageView.yy_setImage(with: URL.init(string: account.portrait),
                                      placeholder: UIImage.init(named: "topic_default_avatar"),
                                      options: kWebImageOptions,
                                      completion: nil)
        
        //用户名
        let nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(17)
        nameLabel.textColor = .black
        nameLabel.text = account.nickname
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.tag = itemTag
        itemTag += 1
        self.addSubview(nameLabel)
        
        let maxW: CGFloat = button.frame.origin.x-(portraitImageView.frame.maxX+8+8)
        nameLabel.frame = CGRect.init(x: portraitImageView.frame.maxX+8, y: portraitImageView.frame.origin.y, width: maxW, height: portraitImageView.frame.size.height)~
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
