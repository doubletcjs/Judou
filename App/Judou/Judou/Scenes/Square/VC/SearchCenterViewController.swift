//
//  SearchCenterViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class SearchCenterViewController: BaseHideBarViewController, UITextFieldDelegate, SGPageTitleViewDelegate, SGPageContentScrollViewDelegate {
    private var searchTextField: UITextField!
    private var cancelButton: UIButton!
    
    private var pageTitleView: SGPageTitleView!
    private var pageContentScrollView: SGPageContentScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchTextField = UITextField.init(frame: CGRect.init(x: 20, y: kStatusBarHeight()+6, width: kScreenWidth()-100, height: 32)~)
        searchTextField.layer.cornerRadius = searchTextField.frame.size.height/2
        searchTextField.layer.masksToBounds = true
        searchTextField.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        searchTextField.placeholder = "搜索喜欢的内容"
        searchTextField.setValue(kRGBColor(red: 209, green: 210, blue: 211, alpha: 1), forKey: "_placeholderLabel.textColor")
        searchTextField.font = kBaseFont(15)
        searchTextField.leftViewMode = .always
        searchTextField.delegate = self
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect.init(x: 0, y: 0, width: 38, height: 26)~
        imageView.image = UIImage.init(named: "icon_search")
        searchTextField.leftView = imageView
        self.view.addSubview(searchTextField)
        
        cancelButton = UIButton.init(type: .system)
        cancelButton.titleLabel?.font = kBaseFont(15)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.contentHorizontalAlignment = .right
        self.view.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(self.cancelInput), for: .touchUpInside)
        cancelButton.sizeToFit()
        cancelButton.frame = CGRect.init(x: kScreenWidth()-20-cancelButton.frame.size.width, y: kStatusBarHeight(), width: cancelButton.frame.size.width, height: 44)~
        
        searchTextField.frame = CGRect.init(x: 20, y: kStatusBarHeight()+6, width: cancelButton.frame.origin.x-20*2, height: 32)~
        
        searchTextField.becomeFirstResponder()
        //tab
        let titleViewConfigure: SGPageTitleViewConfigure = SGPageTitleViewConfigure()
        titleViewConfigure.bottomSeparatorColor = kRGBColor(red: 249, green: 249, blue: 249, alpha: 1)
        titleViewConfigure.indicatorStyle = SGIndicatorStyleDefault
        
        titleViewConfigure.indicatorColor = kRGBColor(red: 166, green: 146, blue: 91, alpha: 1)
        titleViewConfigure.indicatorHeight = 2
        
        titleViewConfigure.titleFont = kBaseFont(16)
        titleViewConfigure.titleSelectedFont = kBaseFont(16)
        titleViewConfigure.titleSelectedColor = kRGBColor(red: 188, green: 174, blue: 139, alpha: 1)
        titleViewConfigure.titleColor = .black
        
        let types: [String] = ["句子", "作者", "出处", "用户"]
        pageTitleView = SGPageTitleView.init(frame: CGRect.init(x: 0, y: searchTextField.frame.maxY+6, width: kScreenWidth(), height: 40)~, delegate: self, titleNames: types, configure: titleViewConfigure)
        self.view.addSubview(pageTitleView)
        
        let controllerRect = CGRect.init(x: 0, y: pageTitleView.frame.maxY, width: kScreenWidth(), height: self.view.bounds.size.height-pageTitleView.frame.maxY)~
        
        var controllers: [UIViewController] = []
        types.forEach { (type) in
            if type == "句子" {
                let postVC = TabPostViewController()
                postVC.superFrame = controllerRect 
                controllers.append(postVC)
            } else {
                let searchListVC = SearchListViewController()
                searchListVC.searchType = type
                searchListVC.superFrame = controllerRect
                controllers.append(searchListVC)
            }
        }
        
        pageContentScrollView = SGPageContentScrollView.init(frame: controllerRect, parentVC: self, childVCs: controllers)
        pageContentScrollView.delegatePageContentScrollView = self
        self.view.addSubview(pageContentScrollView)
    }
    // MARK: - SGPageTitleViewDelegate / SGPageContentScrollViewDelegate
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        pageContentScrollView.setPageContentScrollViewCurrentIndex(selectedIndex)
        
    }
    
    func pageContentScrollView(_ pageContentScrollView: SGPageContentScrollView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        pageTitleView.setPageTitleViewWithProgress(progress, originalIndex: originalIndex, targetIndex: targetIndex)
        
        if progress == 1 {
            
        }
    }
    // MARK: - 取消输入
    @objc private func cancelInput() -> Void {
        if cancelButton.currentTitle == "取消" {
            searchTextField.resignFirstResponder()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        cancelButton.setTitle("取消", for: .normal)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        cancelButton.setTitle("返回", for: .normal)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
