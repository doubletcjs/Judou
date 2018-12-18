//
//  JSVariableMenuHeader.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class JSVariableMenuHeader: UICollectionReusableView {
    var title: String! {
        didSet {
            if titleLabel != nil {
                titleLabel.text = title
            }
        }
    } //标题名称
    var subTitle: String! {
        didSet {
            if subTitleLabel != nil {
                subTitleLabel.text = subTitle
            }
        }
    } //副标题名称
    
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 初始化
    private func buildUI() -> Void {
        let marginX: CGFloat = 16
        let labelWidth: CGFloat = (self.bounds.size.width-marginX*2)/2
        
        titleLabel = UILabel.init(frame: CGRect.init(x: marginX, y: 0, width: labelWidth, height: self.bounds.size.height)~)
        titleLabel.textColor = .black
        titleLabel.font = kBaseFont(12)
        self.addSubview(titleLabel)
        
        subTitleLabel = UILabel.init(frame: CGRect.init(x: labelWidth+marginX, y: 0, width: labelWidth, height: self.bounds.size.height)~)
        subTitleLabel.textColor = kRGBColor(red: 189, green: 190, blue: 191, alpha: 1)
        subTitleLabel.font = kBaseFont(12)
        subTitleLabel.textAlignment = .right
        self.addSubview(subTitleLabel)
    }
}
