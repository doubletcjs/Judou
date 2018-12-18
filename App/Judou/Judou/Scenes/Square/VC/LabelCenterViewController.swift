//
//  LabelCenterViewController.swift
//  Judou
//
//  Created by 4work on 2018/12/16.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class LabelCenterViewController: BaseShowBarViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "选择标签"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_close"), style: .plain, target: self, action: #selector(self.labelCloseAction))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_add"), style: .plain, target: self, action: #selector(self.createLabelAction))
        
        let flowLayout = UICollectionViewFlowLayout.init()
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = kRGBColor(red: 243, green: 244, blue: 245, alpha: 1)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "LabelCenterItemCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
    }
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCenterItemCell", for: indexPath)
        
        for view in cell.subviews {
            if view.tag >= 10 {
                view.removeFromSuperview()
            }
        }
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 4
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        let cellWidth: CGFloat = (self.view.bounds.size.width-CGFloat(2*18)-CGFloat(3*16))/CGFloat(4)
        
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: cellWidth, height: cellWidth)~)
        imageView.sd_setImage(with: URL.init(string: ""),
                              placeholderImage: nil,
                              options: SDWebImageOptions.init(rawValue: SDWebImageOptions.allowInvalidSSLCertificates.rawValue),
                              completed: nil)
        imageView.tag = 10
        cell.addSubview(imageView)
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: imageView.frame.maxY, width: cellWidth, height: 30)~)
        label.font = kBaseFont(13)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "测试测试"
        label.tag = 11
        cell.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (self.view.bounds.size.width-CGFloat(2*18)-CGFloat(3*16))/CGFloat(4)
        
        return CGSize.init(width: cellWidth, height: cellWidth+30)~
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 20, left: 18, bottom: 0, right: 18)~
    }
    
    // MARK: - 添加标签
    @objc private func createLabelAction() -> Void {
        let createLabelVC = CreateLabelViewController()
        let nav = UINavigationController.init(rootViewController: createLabelVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK: - 关闭
    @objc private func labelCloseAction() -> Void {
        self.dismiss(animated: true, completion: nil)
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
