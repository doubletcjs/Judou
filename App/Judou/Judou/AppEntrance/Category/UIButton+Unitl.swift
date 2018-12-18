//
//  UIButton+Unitl.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias ButtonEventBlock = (_ button : UIButton) ->Void
var buttonEventHandle : ButtonEventBlock?

extension UIButton {

    func handleControlEvent(controlEvent: UIControl.Event, eventBlock : @escaping ButtonEventBlock) -> Void {
        buttonEventHandle = eventBlock
        if buttonEventHandle != nil {
            self.addTarget(self, action: #selector(btnEvent(button:)), for: controlEvent)
        } else {
            self.removeTarget(self, action: #selector(btnEvent(button:)), for: controlEvent)
        }
    }

    @objc private func btnEvent(button : UIButton) {
        if (buttonEventHandle != nil) {
            buttonEventHandle!(button)
        }
    }
    
    private var block : ButtonEventBlock {
        get {
            return objc_getAssociatedObject(self, "ButtonEventBlock_Key") as! ButtonEventBlock
        }
        set {
            objc_setAssociatedObject(self, "ButtonEventBlock_Key", buttonEventHandle.self, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}
