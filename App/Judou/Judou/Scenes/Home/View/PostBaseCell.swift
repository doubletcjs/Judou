//
//  PostBaseCell.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class PostBaseCell: UITableViewCell {
    var isDetail: Bool! = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // MARK: - 帖子基础cell
    class func getPostBaseCellHeight(_ postModel: PostModel, _ isDetail: Bool) -> CGFloat {
        let baseX: CGFloat = 20
        let baseY: CGFloat = 18
        var cellHeight = baseY
        let imageWH: CGFloat = 38
        
        //头像
        cellHeight = cellHeight+imageWH+2
        
        let maxW = kScreenWidth()-baseX*2
        //内容
        let attr = attributedString(postModel.content, with: kBaseFont(16), withFontColor: .black, with: .left, with: .byCharWrapping, withLineSpace: 0)
        var textSize = sizeOfAttributedString(attr, in: CGSize.init(width: maxW, height: CGFloat(MAXFLOAT))~)
        if textSize.height > 84 && isDetail == false {
            textSize.height = 84
        }
        cellHeight = cellHeight+textSize.height
        cellHeight = cellHeight+2
        
        //图片
        if isStringEmpty(postModel.image) == false {
            let imageH: CGFloat = (maxW*9.0)/16.0
            cellHeight = cellHeight+imageH+14
        }
        
        cellHeight = cellHeight+36
        return cellHeight
    }
    
    func createPostBaseCell(_ postModel: PostModel) -> Void { 
        var cellTag = 10
        let baseX: CGFloat = 20
        var baseY: CGFloat = 18
        //头像
        let userModel = postModel.author
        
        let imageWH: CGFloat = 38
        let portraitImageView = UIImageView.init(frame: CGRect.init(x: baseX, y: baseY, width: imageWH, height: imageWH)~)
        portraitImageView.layer.cornerRadius = portraitImageView.frame.size.height/2
        portraitImageView.layer.masksToBounds = true
        portraitImageView.clipsToBounds = true
        portraitImageView.tag = cellTag
        cellTag += 1
        self.addSubview(portraitImageView)
        portraitImageView.yy_setImage(with: URL.init(string: userModel.portrait),
                                      placeholder: UIImage.init(named: "topic_default_avatar"),
                                      options: kWebImageOptions,
                                      completion: nil)
        
        //更多
        let moreButton = UIButton.init(type: .custom)
        moreButton.setImage(UIImage.init(named: "cell_more"), for: .normal)
        moreButton.tag = cellTag
        cellTag += 1
        self.addSubview(moreButton)
        moreButton.frame = CGRect.init(x: kScreenWidth()-baseX-48, y: 0, width: 48, height: 48)~
        moreButton.center = CGPoint.init(x: moreButton.center.x, y: portraitImageView.center.y)
        moreButton.contentHorizontalAlignment = .right
        
        moreButton.handleControlEvent(controlEvent: .touchUpInside) { [weak self] (sender) in
            self?.copyTextAction(postModel.content)
        }
        
        var maxW: CGFloat = (kScreenWidth()-(portraitImageView.frame.maxX+8+8+48+baseX))~
        
        //用户名
        let nameLabel = UILabel.init()
        nameLabel.font = kBaseFont(16)
        nameLabel.textColor = .black
        nameLabel.text = userModel.nickname
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.tag = cellTag
        cellTag += 1
        self.addSubview(nameLabel)
        var nameSize = nameLabel.sizeThatFits(CGSize.init(width: maxW, height: 17)~)
        if nameSize.width > maxW {
            nameSize.width = maxW
        }
        
        nameLabel.frame = CGRect.init(x: portraitImageView.frame.maxX+8, y: portraitImageView.center.y-nameSize.height-1, width: nameSize.width, height: nameSize.height)~
        
        //日期
        let dateLabel = UILabel.init()
        dateLabel.font = kBaseFont(12)~
        dateLabel.textColor = .lightGray
        dateLabel.tag = cellTag
        cellTag += 1
        dateLabel.text = postModel.postDate+"发布"
        self.addSubview(dateLabel)
        var dateSize = dateLabel.sizeThatFits(CGSize.init(width: maxW, height: 13)~)
        if dateSize.width > maxW {
            dateSize.width = maxW
        }
        
        dateLabel.frame = CGRect.init(x: nameLabel.frame.origin.x, y: portraitImageView.center.y+1, width: dateSize.width, height: dateSize.height)~
        
        maxW = (kScreenWidth()-baseX*2)~
        baseY = (portraitImageView.frame.maxY+2)~
        //内容 
        let attr = attributedString(postModel.content, with: kBaseFont(16), withFontColor: .black, with: .left, with: .byCharWrapping, withLineSpace: 0)
        var textSize = sizeOfAttributedString(attr, in: CGSize.init(width: maxW, height: CGFloat(MAXFLOAT))~)
        if textSize.height > 84 && isDetail == false {
            textSize.height = 84
        }
        
        let contentLabel = UILabel.init(frame: CGRect.init(x: baseX, y: baseY, width: maxW, height: textSize.height)~)
        contentLabel.numberOfLines = 0
        contentLabel.attributedText = attr
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.tag = cellTag
        cellTag += 1
        self.addSubview(contentLabel)
        
        baseY = contentLabel.frame.maxY+2
        //图片
        if isStringEmpty(postModel.image) == false {
            // maxW / x = 16 / 9
            let imageH: CGFloat = (maxW*9.0)/16.0
            let postImageView = UIImageView.init(frame: CGRect.init(x: baseX, y: baseY, width: maxW, height: imageH)~)
            postImageView.layer.cornerRadius = 16~
            postImageView.layer.masksToBounds = true
            postImageView.clipsToBounds = true
            postImageView.tag = cellTag
            cellTag += 1
            self.addSubview(postImageView)
            postImageView.yy_setImage(with: URL.init(string: postModel.image),
                                      placeholder: UIImage.init(named: "topic_default_avatar"),
                                      options: kWebImageOptions,
                                      completion: nil)
            baseY = (postImageView.frame.maxY+14)~
        }
        //功能按钮
        let itemView = UIView.init(frame: CGRect.init(x: baseX, y: baseY, width: maxW, height: 36)~)
        itemView.tag = cellTag
        cellTag += 1
        self.addSubview(itemView)
        
        let lineLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: itemView.frame.size.width, height: 1)~)
        lineLabel.backgroundColor = kRGBColor(red: 249, green: 250, blue: 250, alpha: 1)
        itemView.addSubview(lineLabel)
        
        var items: [String] = ["icon_like", "icon_comment", "icon_collect", "icon_share"]
        let itemValues: [Int] = [postModel.praise, postModel.comment, postModel.collect, 0]
        if postModel.isPraise == true {
            items[0] = "icon_like_selected"
        }
        
        if postModel.isCollect == true {
            items[2] = "icon_comment_selected"
        }
        
        let itemH = 36~
        let itemW = itemView.frame.size.width/CGFloat(items.count)
        for idx in 0...(items.count-1) {
            let button = UIButton.init(type: .custom)
            itemView.addSubview(button)
            button.titleLabel?.font = kBaseFont(12)
            button.setTitleColor(.lightGray, for: .normal)
            
            button.setImage(UIImage.init(named: items[idx]), for: .normal)
            if itemValues[idx] > 0 {
                button.setTitle("\(itemValues[idx])", for: .normal)
            }
            
            if idx == 0 {
                button.contentHorizontalAlignment = .left
            } else if idx == 1 {
                button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -itemW/4, bottom: 0, right: 0)
                button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -itemW/4, bottom: 0, right: 0)
            } else if idx == 2 {
                button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: itemW/4, bottom: 0, right: 0)
                button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: itemW/4, bottom: 0, right: 0)
            } else if idx == 3 {
                button.contentHorizontalAlignment = .right
            }
            
            button.frame = CGRect.init(x: CGFloat(idx)*itemW, y: 0, width: itemW, height: itemH)~
        }
    }
    // MARK: - 复制文字
    @objc private func copyTextAction(_ copyText: String) -> Void {
        let actionSheet: JSActionSheet = JSActionSheet.init(title: nil, cancelTitle: "取消", otherTitles: ["复制文字"])
        actionSheet.destructiveColor = kRGBColor(red: 200, green: 114, blue: 99, alpha: 1)
        actionSheet.showView()
        actionSheet.dismiss(forCompletionHandle: { (index, isCancel) in
            if isCancel == false {
                
            }
        })
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
