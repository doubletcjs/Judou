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
        let space: CGFloat = 12
        let imageWH: CGFloat = 54
        let cellHeight: CGFloat = imageWH+space*2
        
        var itemTag: Int = 10
        //头像
        let imageView = UIImageView.init(frame: CGRect.init(x: self.separatorInset.left, y: space, width: imageWH, height: imageWH)~)
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.tag = itemTag
        itemTag += 1
        self.addSubview(imageView)
        
        imageView.yy_setImage(with: URL.init(string: account.portrait),
                              placeholder: UIImage.init(named: "topic_default_avatar"),
                              options: kWebImageOptions,
                              completion: nil)
        
        //用户名
        let nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(17)
        nameLabel.textColor = .black
        nameLabel.text = account.nickname
        nameLabel.tag = itemTag
        itemTag += 1
        self.addSubview(nameLabel)
    }
}
