//
//  PostBaseCell.swift
//  Judou
//
//  Created by 4work on 2018/12/12.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias PostCellAuthorBlock = () -> Void
typealias PostCellFamousBlock = () -> Void
typealias PostCellPraiseBlock = () -> Void
typealias PostCellCommentBlock = () -> Void
typealias PostCellCollectionBlock = () -> Void
typealias PostCellShareBlock = () -> Void

class PostBaseCell: UITableViewCell {
    var isDetail: Bool! = false

    var postAuthorHandle: PostCellAuthorBlock?
    var postFamousHandle: PostCellFamousBlock?
    var postPraiseHandle: PostCellPraiseBlock?
    var postCommentHandle: PostCellCommentBlock?
    var postCollectionHandle: PostCellCollectionBlock?
    var postShareHandle: PostCellShareBlock?
    
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
        let baseX: CGFloat = 18
        let baseY: CGFloat = 18
        var cellHeight = baseY
        let imageWH: CGFloat = 38
        
        //头像
        cellHeight = cellHeight+imageWH+12
        
        let maxW = kScreenWidth()-baseX*2
        //内容
        let contentLabel = UILabel.init()
        contentLabel.numberOfLines = 3
        contentLabel.text = postModel.content
        contentLabel.font = kBaseFont(16)
        contentLabel.textColor = .black
        contentLabel.lineBreakMode = .byTruncatingTail
        
        var maxContentHeight: CGFloat = 84
        if isDetail == true {
            maxContentHeight = CGFloat(MAXFLOAT)
            contentLabel.numberOfLines = 0
        }
        let textSize = contentLabel.sizeThatFits(CGSize.init(width: maxW, height: maxContentHeight)~)
        
        cellHeight = cellHeight+textSize.height
        
        //图片
        if isStringEmpty(postModel.image) == false {
            let imageH: CGFloat = (maxW*9.0)/16.0
            cellHeight = cellHeight+14+imageH+14
        } else {
            cellHeight = cellHeight+14
        }
        //收录人
        if postModel.postType == 0 {
            cellHeight = cellHeight+38-6*2
        }
        
        cellHeight = cellHeight+36
        return cellHeight
    }
    
    func createPostBaseCell(_ postModel: PostModel) -> Void { 
        var cellTag = 10
        let baseX: CGFloat = 18
        var baseY: CGFloat = 18
        //头像
        let userModel = postModel.author
        
        let imageWH: CGFloat = 38
        let portraitImageView = UIImageView.init(frame: CGRect.init(x: baseX, y: baseY, width: imageWH, height: imageWH)~)
        portraitImageView.layer.cornerRadius = portraitImageView.frame.size.height/2
        portraitImageView.layer.masksToBounds = true
        portraitImageView.clipsToBounds = true
        portraitImageView.contentMode = .scaleAspectFill
        portraitImageView.tag = cellTag
        cellTag += 1
        self.addSubview(portraitImageView)
        portraitImageView.yy_setImage(with: URL.init(string: userModel.portrait),
                                      placeholder: UIImage.init(named: "topic_default_avatar"),
                                      options: kWebImageOptions,
                                      completion: nil)
        portraitImageView.isUserInteractionEnabled = true
        portraitImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showAccountAction)))
        
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
        
        var maxW: CGFloat = (kScreenWidth()-(portraitImageView.frame.maxX+10+8+48+baseX))~
        
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
        
        nameLabel.frame = CGRect.init(x: portraitImageView.frame.maxX+10, y: portraitImageView.center.y-nameSize.height, width: nameSize.width, height: nameSize.height)~
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showAccountAction)))
        
        //收录
        if postModel.postType == 0 {
            portraitImageView.layer.cornerRadius = 4
            portraitImageView.yy_setImage(with: URL.init(string: postModel.famous.cover),
                                          placeholder: UIImage.init(named: "topic_default_avatar"),
                                          options: kWebImageOptions,
                                          completion: nil)
            nameLabel.text = postModel.famous.name
            nameSize = nameLabel.sizeThatFits(CGSize.init(width: maxW, height: 17)~)
            if nameSize.width > maxW {
                nameSize.width = maxW
            }
            
            nameLabel.frame = CGRect.init(x: portraitImageView.frame.maxX+8, y: portraitImageView.center.y-nameSize.height, width: nameSize.width, height: nameSize.height)~
            nameLabel.center = CGPoint.init(x: nameLabel.center.x, y: portraitImageView.center.y)~
            nameLabel.gestureRecognizers = nil
            nameLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showFamousAction)))
            
            //认证标识
            let markImageView = UIImageView.init(frame: CGRect.init(x: nameLabel.frame.maxX+4, y: 0, width: 26, height: 26)~)
            markImageView.image = UIImage.init(named: "icon_topic_verified")
            markImageView.contentMode = .scaleAspectFit
            markImageView.tag = cellTag
            cellTag += 1
            self.addSubview(markImageView)
            markImageView.center = CGPoint.init(x: markImageView.center.x, y: portraitImageView.center.y)~
            markImageView.isUserInteractionEnabled = true
            markImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showFamousAction)))
        } else {
            //日期
            let dateLabel = UILabel.init()
            dateLabel.font = kBaseFont(12)
            dateLabel.textColor = .lightGray
            dateLabel.tag = cellTag
            cellTag += 1
            dateLabel.text = postModel.postDate+"发布"
            self.addSubview(dateLabel)
            var dateSize = dateLabel.sizeThatFits(CGSize.init(width: maxW, height: 13)~)
            if dateSize.width > maxW {
                dateSize.width = maxW
            }
            
            dateLabel.frame = CGRect.init(x: nameLabel.frame.origin.x, y: portraitImageView.center.y, width: dateSize.width, height: dateSize.height)~
            dateLabel.isUserInteractionEnabled = true
            dateLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showAccountAction)))
        }
        
        maxW = kScreenWidth()-baseX*2
        baseY = portraitImageView.frame.maxY+12
        
        //内容
        let contentLabel = UILabel.init()
        contentLabel.numberOfLines = 3
        contentLabel.text = postModel.content
        contentLabel.font = kBaseFont(16)
        contentLabel.textColor = .black
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.tag = cellTag
        cellTag += 1
        self.addSubview(contentLabel)
        var maxContentHeight: CGFloat = 84
        if isDetail == true {
            contentLabel.numberOfLines = 0
            maxContentHeight = CGFloat(MAXFLOAT)
        }
        let textSize = contentLabel.sizeThatFits(CGSize.init(width: maxW, height: maxContentHeight)~)
        contentLabel.frame = CGRect.init(x: baseX, y: baseY, width: maxW, height: textSize.height)
        
        baseY = contentLabel.frame.maxY+14
        //图片
        if isStringEmpty(postModel.image) == false {
            // maxW / x = 16 / 9
            let imageH: CGFloat = (maxW*9.0)/16.0
            let postImageView = UIImageView.init(frame: CGRect.init(x: baseX, y: baseY, width: maxW, height: imageH)~)
            postImageView.layer.cornerRadius = 16
            postImageView.layer.masksToBounds = true
            postImageView.clipsToBounds = true
            postImageView.contentMode = .scaleAspectFill
            postImageView.tag = cellTag
            cellTag += 1
            self.addSubview(postImageView)
            postImageView.yy_setImage(with: URL.init(string: postModel.image),
                                      placeholder: UIImage.init(named: "big_image_placeholder"),
                                      options: kWebImageOptions,
                                      completion: nil)
            baseY = postImageView.frame.maxY+14
        }
        
        //收录人
        if postModel.postType == 0 {
            let includedButton = UIButton.init()
            includedButton.frame = CGRect.init(x: baseX, y: baseY-6, width: maxW, height: 38-14)~
            includedButton.tag = cellTag
            cellTag += 1
            self.addSubview(includedButton)
            includedButton.addTarget(self, action: #selector(self.showAccountAction), for: .touchUpInside)
            
            let imageWH: CGFloat = includedButton.frame.size.height-2*2
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 2, width: imageWH, height: imageWH)~)
            imageView.layer.cornerRadius = imageView.frame.size.height/2
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            includedButton.addSubview(imageView)
            imageView.yy_setImage(with: URL.init(string: userModel.portrait),
                                  placeholder: UIImage.init(named: "topic_default_avatar"),
                                  options: kWebImageOptions,
                                  completion: nil)
            
            let nameLabel = UILabel.init()
            nameLabel.font = kBaseFont(11)
            nameLabel.textColor = .black
            nameLabel.text = userModel.nickname
            nameLabel.lineBreakMode = .byTruncatingTail
            includedButton.addSubview(nameLabel)
            nameLabel.sizeToFit()
            nameLabel.frame = CGRect.init(x: imageView.frame.maxX+6, y: imageView.frame.origin.y, width: nameLabel.frame.size.width, height: imageView.frame.size.height)~
            
            let dateLabel = UILabel.init()
            dateLabel.font = kBaseFont(11)
            dateLabel.textColor = .lightGray
            dateLabel.text = postModel.postDate+"收录"
            includedButton.addSubview(dateLabel)
            dateLabel.sizeToFit()
            dateLabel.frame = CGRect.init(x: nameLabel.frame.maxX+10, y: imageView.frame.origin.y, width: dateLabel.frame.size.width, height: imageView.frame.size.height)~
            
            baseY = baseY+38-6*2
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
        let itemValues: [Int] = [postModel.praiseCount, postModel.commentCount, postModel.collectCount, 0]
        if postModel.isPraise == true {
            items[0] = "icon_like_selected"
        }
        
        if postModel.isCollect == true {
            items[2] = "icon_comment_selected"
        }
        
        let itemH: CGFloat = 36
        let itemW: CGFloat = itemView.frame.size.width/CGFloat(items.count)
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
                button.addTarget(self, action: #selector(self.showPraisetAction), for: .touchUpInside)
            } else if idx == 1 {
                button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -itemW/4, bottom: 0, right: 0)~
                button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -itemW/4, bottom: 0, right: 0)~
                button.addTarget(self, action: #selector(self.showCommentAction), for: .touchUpInside)
            } else if idx == 2 {
                button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: itemW/4, bottom: 0, right: 0)~
                button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: itemW/4, bottom: 0, right: 0)~
                button.addTarget(self, action: #selector(self.showCollectionAction), for: .touchUpInside)
            } else if idx == 3 {
                button.contentHorizontalAlignment = .right
                button.addTarget(self, action: #selector(self.showShareAction), for: .touchUpInside)
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
    // MARK: - 查看用户
    @objc private func showAccountAction() -> Void {
        if postAuthorHandle != nil {
            postAuthorHandle!()
        }
    }
    // MARK: - 查看名人
    @objc private func showFamousAction() -> Void {
        if postFamousHandle != nil {
            postFamousHandle!()
        }
    }
    // MARK: - 点赞
    @objc private func showPraisetAction() -> Void {
        if postPraiseHandle != nil {
            postPraiseHandle!()
        }
    }
    // MARK: - 评论
    @objc private func showCommentAction() -> Void {
        if postCommentHandle != nil {
            postCommentHandle!()
        }
    }
    // MARK: - 收藏
    @objc private func showCollectionAction() -> Void {
        if postCollectionHandle != nil {
            postCollectionHandle!()
        }
    }
    // MARK: - 分享
    @objc private func showShareAction() -> Void {
        if postShareHandle != nil {
            postShareHandle!()
        }
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
