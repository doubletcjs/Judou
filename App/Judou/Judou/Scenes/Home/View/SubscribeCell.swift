//
//  SubscribeCell.swift
//  Judou
//
//  Created by 4work on 2018/12/24.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class SubscribeCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createSubscribeCell(_ subscribeModel: Any) -> Void {
        let space: CGFloat = 10
        let coverWH: CGFloat = 88-space*2
        var cellTag: Int = 10
        
        var cover: String = ""
        var isSubscribe: Bool = false
        var name: String = ""
        var isFamous: Bool = false
        var introduction: String = ""
        
        if subscribeModel is FamousModel {
            let famousModel: FamousModel = subscribeModel as! FamousModel
            cover = famousModel.cover
            isSubscribe = famousModel.isSubscribe
            name = famousModel.name
            isFamous = true
            introduction = famousModel.introduction
        } else if subscribeModel is BookModel {
            let bookModel: BookModel = subscribeModel as! BookModel
            cover = bookModel.cover
            isSubscribe = bookModel.isSubscribe
            name = bookModel.name
            isFamous = true
            introduction = bookModel.introduction
        }
        
        //封面
        let coverImageView = UIImageView.init(frame: CGRect.init(x: self.separatorInset.left, y: space, width: coverWH, height: coverWH)~)
        coverImageView.layer.cornerRadius = 2
        coverImageView.layer.masksToBounds = true
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.tag = cellTag
        cellTag += 1
        self.addSubview(coverImageView)
        
        coverImageView.yy_setImage(with: URL.init(string: kBaseURL+cover),
                                   placeholder: UIImage.init(named: "big_image_placeholder"),
                                   options: kWebImageOptions,
                                   completion: nil)
        
        //订阅
        let button = UIButton.init(type: .system)
        button.frame = CGRect.init(x: kScreenWidth()-self.separatorInset.left-54, y: coverImageView.frame.origin.y, width: 54, height: 25)~
        button.tag = cellTag
        cellTag += 1
        self.addSubview(button)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.8
        button.titleLabel?.font = kBaseFont(13)
        button.setTitle("订阅", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = kRGBColor(red: 206, green: 210, blue: 219, alpha: 1).cgColor
        
        if isSubscribe == false {
            button.setTitle("已订阅", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = kRGBColor(red: 206, green: 210, blue: 219, alpha: 1)
        }
        
        //人名
        let nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(15)
        nameLabel.textColor = .black
        nameLabel.text = name
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.tag = cellTag
        cellTag += 1
        self.addSubview(nameLabel)
        
        let maxW: CGFloat = button.frame.origin.x-(coverImageView.frame.maxX+8+8)
        let nameSize = nameLabel.sizeThatFits(CGSize.init(width: maxW, height: 26)~)
        nameLabel.frame = CGRect.init(x: coverImageView.frame.maxX+8, y: 0, width: nameSize.width, height: nameSize.height)~
        nameLabel.center = CGPoint.init(x: nameLabel.center.x, y: button.center.y)
        
        if isFamous == true {
            //认证标识
            let markImageView = UIImageView.init(frame: CGRect.init(x: nameLabel.frame.maxX+4, y: 0, width: 26, height: 26)~)
            markImageView.image = UIImage.init(named: "icon_topic_verified")
            markImageView.contentMode = .scaleAspectFit
            markImageView.tag = cellTag
            cellTag += 1
            self.addSubview(markImageView)
            markImageView.center = CGPoint.init(x: markImageView.center.x, y: coverImageView.center.y)~
        }
        
        //简介
        let introductLabel = UILabel.init()
        introductLabel.numberOfLines = 2
        introductLabel.text = introduction
        introductLabel.font = kBaseFont(13)
        introductLabel.textColor = .black
        introductLabel.lineBreakMode = .byTruncatingTail
        introductLabel.tag = cellTag
        cellTag += 1
        self.addSubview(introductLabel)
        
        let maxContentHeight: CGFloat = coverWH/2
        let textSize = introductLabel.sizeThatFits(CGSize.init(width: maxW, height: maxContentHeight)~)
        if textSize.height > maxContentHeight {
            introductLabel.frame = CGRect.init(x: nameLabel.frame.origin.x, y: coverImageView.frame.maxY-textSize.height, width: maxW, height: textSize.height)
        } else {
            introductLabel.frame = CGRect.init(x: nameLabel.frame.origin.x, y: coverImageView.frame.origin.y+maxContentHeight, width: maxW, height: textSize.height)
        }
        
        if isFamous == false {
            //类型图片
        }
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
