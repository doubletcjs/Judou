//
//  BlurImageView.swift
//  Judou
//
//  Created by 4work on 2019/1/3.
//  Copyright © 2019 Sam Cooper Studio. All rights reserved.
//

import UIKit

class BlurImageView: UIImageView {
    private var originalImageView: UIImageView!
    
    var showBlurOriginal: Bool! {
        didSet {
            if originalImageView != nil {
                if showBlurOriginal == false {
                    originalImageView.alpha = 0
                    originalImageView.removeFromSuperview()
                } else {
                    originalImageView.alpha = 1
                    if self.subviews.contains(originalImageView) == false {
                        self.addSubview(originalImageView)
                    }
                }
            }
        }
    }
    
    var blurAlpha: CGFloat! {
        didSet {
            if originalImageView != nil {
                originalImageView.alpha = blurAlpha
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = .scaleAspectFill
        originalImageView = UIImageView.init(frame: self.bounds)
        originalImageView.contentMode = .scaleAspectFill
        self.addSubview(originalImageView)
        
        showBlurOriginal = false
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(with imageURLString: String?, placeholder: UIImage) -> Void {
        self.yy_setImage(with: URL.init(string: imageURLString ?? ""),
                         placeholder: placeholder.byBlurLight(),
                         options: kWebImageOptions) { [weak self] (image, url, imageFromType, imageStage, error) in
                            if image != nil {
                                self?.image = image!.byBlurLight()
                            }
        }
        
        originalImageView.yy_setImage(with: URL.init(string: imageURLString ?? ""),
                                      placeholder: placeholder,
                                      options: kWebImageOptions) { (image, url, imageFromType, imageStage, error) in
                                
        }
    }
    
    override var frame: CGRect {
        didSet {
            if originalImageView != nil {
                originalImageView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            }
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            if originalImageView != nil {
                originalImageView.isUserInteractionEnabled = isUserInteractionEnabled
            }
        }
    }
    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
