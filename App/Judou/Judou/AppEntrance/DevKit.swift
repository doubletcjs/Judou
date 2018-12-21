//
//  DevKit.swift
//  Judou
//
//  Created by 4work on 2018/12/11.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

let kLoginUserID = "kLoginUserID"
let APP_ID = ""
let APP_URL = "https://itunes.apple.com/cn/app/id\(APP_ID)?mt=8"
let kWebImageOptions: YYWebImageOptions = YYWebImageOptions.init(rawValue: YYWebImageOptions.allowInvalidSSLCertificates.rawValue | YYWebImageOptions.allowBackgroundTask.rawValue | YYWebImageOptions.progressiveBlur.rawValue | YYWebImageOptions.setImageWithFadeAnimation.rawValue)

private func JSScreenScale() -> CGFloat {
    return UIScreen.main.scale
}

private func JSScreenSize() -> CGSize {
    var size: CGSize = UIScreen.main.bounds.size
    if (size.height < size.width) {
        let tmp: CGFloat = size.height
        size.height = size.width
        size.width = tmp
    }
    
    return size
}

func kScreenScale() -> CGFloat {
    return JSScreenScale()
}
// MARK: - 屏幕宽度
func kScreenWidth() -> CGFloat {
    return JSScreenSize().width
}
// MARK: - 屏幕高度
func kScreenHeight() -> CGFloat {
    return JSScreenSize().height
}
// MARK: - tabbar高度
func kTabBarHeight() -> CGFloat {
    var tabBarC: UITabBarController? = nil
    if UIApplication.shared.keyWindow!.rootViewController != nil {
        if UIApplication.shared.keyWindow!.rootViewController is UITabBarController {
            tabBarC = UIApplication.shared.keyWindow!.rootViewController as? UITabBarController
        } else {
            tabBarC = UIApplication.shared.keyWindow!.rootViewController?.tabBarController
        }
        
        if tabBarC != nil {
            return tabBarC!.tabBar.bounds.size.height
        }
    }
    
    if #available(iOS 11.0, *) {
        return 49+currentSafeAreaInsets().bottom
    } else {
        return 49
    }
}
// MARK: - 状态栏高度
func kStatusBarHeight() -> CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}
// MARK: - iPhoneX安全区域
func currentSafeAreaInsets() -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow!.safeAreaInsets
    } else {
        return UIEdgeInsets.zero
    }
}
// MARK: - hex颜色
func kHEXColor(hex: String!, alpha: Float) -> UIColor {
    var newHex: String! = hex
    if newHex.contains("#") {
        newHex = newHex.replacingOccurrences(of: "#", with: "")
    }
    
    let scanner = Scanner(string: newHex)
    scanner.scanLocation = 0
    
    var rgbValue: UInt64 = 0
    
    scanner.scanHexInt64(&rgbValue)
    
    let r = (rgbValue & 0xff0000) >> 16
    let g = (rgbValue & 0xff00) >> 8
    let b = rgbValue & 0xff
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
}
// MARK: - rgb颜色
func kRGBColor(red: Float, green: Float, blue: Float, alpha: Float) -> UIColor {
    return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
}
// MARK: - 非空判断
func isStringEmpty(_ text: String?) -> Bool {
    if text == nil {
        return true
    } else {
        let set: CharacterSet = CharacterSet.whitespacesAndNewlines
        let trimedString: String = text!.trimmingCharacters(in: set)
        
        if trimedString.count == 0 {
            return true
        } else {
            return false
        }
    }
}
// MARK: - 提示文字
func functionHUD(_ text: String!, inView: UIView?, hideAfterDelay: CGFloat) -> Void {
    var view: UIView? = inView
    if view == nil {
        view = UIApplication.shared.keyWindow
    }
    
    for aView: UIView in view!.subviews {
        if aView.isKind(of: MBProgressHUD.self) {
            let hud: MBProgressHUD = aView as!  MBProgressHUD
            hud.hide(false)
        }
    }
    
    var afterDelay: CGFloat = hideAfterDelay
    if afterDelay < 0.1 {
        afterDelay = 0.8
    }
    
    let hud: MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = .text
    hud.detailsLabelText = text
    hud.detailsLabelFont = kBaseFont(16)
    
    hud.hide(true, afterDelay: TimeInterval(afterDelay))
}

func showTextHUD(_ text: String!, inView: UIView?, hideAfterDelay: CGFloat) -> Void {
    functionHUD(text, inView: inView, hideAfterDelay: hideAfterDelay)
}

func indicatorTextHUD(_ tip: String) -> MBProgressHUD {
    let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)!
    if tip.count > 1 {
        hud.labelText = tip
    }
    
    return hud
}
// MARK: - 定制字符串
func attributedString(_ string: String, with font: UIFont, withFontColor fontColor: UIColor, with textAlignment: NSTextAlignment, with lineBreakMode: NSLineBreakMode, withLineSpace lineSpace: CGFloat) -> NSMutableAttributedString? {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.lineSpacing = lineSpace 
    
    let attributesString = NSMutableAttributedString.init(string: string)
    attributesString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: fontColor], range: NSMakeRange(0, string.count))
    
    return attributesString
}

func sizeOfAttributedString(_ attributedString: NSMutableAttributedString?, in rangeSize: CGSize) -> CGSize {
    let size: CGSize? = attributedString?.boundingRect(with: rangeSize, options: NSStringDrawingOptions.init(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue), context: nil).size
    
    return size ?? CGSize.zero
}
// MARK: - 安全释放延时
func DispatchQueueMainAsyncAfter(deadline: DispatchTime, target: Any?, execute: @escaping () -> Void) -> Void {
    let sourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    sourceTimer.schedule(deadline: deadline, repeating: 1, leeway: .milliseconds(10))
    sourceTimer.resume()
    sourceTimer.setEventHandler(handler: {
        sourceTimer.cancel()
        
        if target != nil {
            DispatchQueue.main.async(execute: {
                execute()
            })
        }
    })
}
// MARK: - Debug和Release print()
func Log(_ item: Any) {
    #if DEBUG
    print(item)
    #endif
}
// MARK: - 默认字体
func kBaseFont(_ fontSize: CGFloat) -> UIFont {
    let font = UIFont.init(name: "NotoSansCJKsc-Light", size: fontSize)!
    return font~
}
