//
//  JSVariableMenuCell.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class JSVariableMenuCell: UICollectionViewCell {
    var title: String! {
        didSet {
            if textLabel != nil {
                textLabel.text = title
            }
        }
    } //标签名称
    var isMoving: Bool! {
        didSet {
            if isMoving == true {
                
            } else {
                
            }
        }
    }//是否正在移动状态
    var isFixed: Bool! {
        didSet {
            if textLabel != nil {
                if isFixed == true {
                    textLabel.backgroundColor = kRGBColor(red: 236, green: 237, blue: 238, alpha: 1)
                    textLabel.textColor = kRGBColor(red: 211, green: 212, blue: 213, alpha: 1)
                } else {
                    textLabel.backgroundColor = kRGBColor(red: 240, green: 241, blue: 242, alpha: 1)
                    textLabel.textColor = .black
                }
            }
        }
    } //是否不可移动
    var showCancel: Bool! {
        didSet {
            if cancelImageView != nil {
                cancelImageView.isHidden = !showCancel
            }
        }
    }
    private var textLabel: UILabel!
    private var cancelImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 初始化
    private func initUI() -> Void {
        let cancelImage: UIImage = UIImage.init(named: "icon_channel_close")!
        let space: CGFloat = cancelImage.size.width/2
        
        textLabel = UILabel.init(frame: CGRect.init(x: space, y: space, width: self.bounds.size.width-space*2, height: self.bounds.size.height-space*2)~)
        textLabel.backgroundColor = kRGBColor(red: 240, green: 241, blue: 242, alpha: 1)
        textLabel.textColor = .black
        textLabel.textAlignment = .center 
        textLabel.font = kBaseFont(16)
        self.addSubview(textLabel)
        
        cancelImageView = UIImageView.init(image: cancelImage)
        cancelImageView.contentMode = .scaleAspectFit
        self.addSubview(cancelImageView)
        cancelImageView.frame = CGRect.init(x: self.bounds.width-cancelImage.size.width, y: 0, width: cancelImage.size.width, height: cancelImage.size.height)~
    }
}
