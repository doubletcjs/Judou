//
//  DatePickerViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/21.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

typealias DatePickerSelectBlock = (_ selectedDate: Date) -> Void

class DatePickerViewController: BaseShowBarViewController {
    private var datePicker: UIDatePicker!
    var dateSelectHandle: DatePickerSelectBlock?
    var currentDate: Date!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if currentDate == nil {
            currentDate = Date.init()
        }
        
        datePicker = UIDatePicker.init()
        datePicker.datePickerMode = .date
        datePicker.date = currentDate
        self.view.addSubview(datePicker)
        datePicker.sizeToFit()
        datePicker.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth(), height: datePicker.frame.size.height)~
        
        self.contentSizeInPopup = CGSize.init(width: kScreenWidth(), height: datePicker.frame.size.height+self.popupController!.navigationBar.frame.size.height+49+currentSafeAreaInsets().bottom)~
        
        self.popupController?.hidesCloseButton = true
        self.popupController?.navigationBar.isTranslucent = false
        self.popupController?.navigationBar.tintColor = UIColor.black
        self.popupController?.navigationBar.barTintColor = UIColor.white
        self.popupController?.navigationBar.shadowImage = UIImage()
        self.popupController?.backgroundView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.pickerCloseAction)))
        
        self.title = "日期选择"
        
        self.popupController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.popupController!.navigationBar.tintColor as UIColor, NSAttributedString.Key.font: kBaseFont(18)]
        
        //取消
        let cancelButton = UIButton.init(type: .system)
        cancelButton.titleLabel?.font = kBaseFont(20)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        self.view.addSubview(cancelButton)
        cancelButton.frame = CGRect.init(x: 0, y: datePicker.frame.maxY, width: self.contentSizeInPopup.width/2, height: 49)~
        cancelButton.addTarget(self, action: #selector(self.pickerCloseAction), for: .touchUpInside)
        
        //确定
        let doneButton = UIButton.init(type: .system)
        doneButton.titleLabel?.font = kBaseFont(20)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.setTitle("确定", for: .normal)
        self.view.addSubview(doneButton)
        doneButton.frame = CGRect.init(x: self.contentSizeInPopup.width/2, y: datePicker.frame.maxY, width: self.contentSizeInPopup.width/2, height: 49)~
        doneButton.addTarget(self, action: #selector(self.selectDateAction), for: .touchUpInside)
        
        //分割线
        let lineLabel = UILabel.init(frame: CGRect.init(x: (self.contentSizeInPopup.width-0.8)/2, y: 0, width: 0.8, height: 20)~)
        lineLabel.backgroundColor = kRGBColor(red: 248, green: 248, blue: 249, alpha: 1)
        self.view.addSubview(lineLabel)
        lineLabel.center = CGPoint.init(x: lineLabel.center.x, y: cancelButton.center.y)
    }
    // MARK: - 关闭
    @objc private func pickerCloseAction() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - 确定
    @objc private func selectDateAction() -> Void {
        if dateSelectHandle != nil {
            dateSelectHandle!(datePicker.date)
        }
        
        self.pickerCloseAction()
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
