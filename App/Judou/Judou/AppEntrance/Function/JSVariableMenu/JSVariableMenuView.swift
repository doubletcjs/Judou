//
//  JSVariableMenuView.swift
//  Judou
//
//  Created by 4work on 2018/12/13.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

//菜单列数
private let ColumnNumber: Int = 4
//横向和纵向的间距
private let CellMarginX: CGFloat = 0
private let CellMarginY: CGFloat = 0

class JSVariableMenuView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var inUseTitles: [String]! = []
    var unUseTitles: [String]! = []
    var fixedNum: Int! = -1
    
    private var collectionView: UICollectionView!
    private var dragingItem: JSVariableMenuCell!
    private var dragingIndexPath: IndexPath!
    private var targetIndexPath: IndexPath!
    private var dragingCell: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let flowLayout = UICollectionViewFlowLayout.init()
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(JSVariableMenuCell.self, forCellWithReuseIdentifier: "JSVariableMenuCell")
        collectionView.register(JSVariableMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "JSVariableMenuHeader")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.addSubview(collectionView)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.longPressMethod(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(longPress)
    }
    // MARK: - 拖拽手势
    @objc private func longPressMethod(_ gesture: UILongPressGestureRecognizer) -> Void {
        let point: CGPoint = gesture.location(in: collectionView)
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            self.dragBegin(point)
        case UIGestureRecognizer.State.changed:
            self.dragChanged(point)
        case UIGestureRecognizer.State.ended:
            self.dragEnd()
        default:
            break
        }
    }
    
    private func dragBegin(_ point: CGPoint) {
        dragingCell = true
        
        dragingIndexPath = self.getDragingIndexPathWith(point)
        if dragingIndexPath == nil {
            return
        }
        
        collectionView.bringSubviewToFront(dragingItem)
        let item = collectionView.cellForItem(at: dragingIndexPath) as! JSVariableMenuCell
        item.isMoving = true
        item.isHidden = true
        //更新被拖拽的item
        dragingItem.isHidden = false
        dragingItem.frame = item.frame
        dragingItem.title = item.title
        dragingItem.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    
    private func dragChanged(_ point: CGPoint) {
        dragingCell = true
        
        if dragingIndexPath == nil {
            return
        }
        
        dragingItem.center = point
        targetIndexPath = self.getTargetIndexPathWith(point)
        //交换位置 如果没有找到_targetIndexPath则不交换位置
        if dragingIndexPath != nil && targetIndexPath != nil {
            //更新数据源
            self.reArrangeInUseTitles()
            //更新item位置
            collectionView.moveItem(at: dragingIndexPath, to: targetIndexPath)
            dragingIndexPath = targetIndexPath
            
        }
    }
    
    private func dragEnd() -> Void {
        if dragingIndexPath == nil {
            dragingCell = false
            
            return
        }
        
        let endFrame: CGRect = collectionView.cellForItem(at: dragingIndexPath)!.frame
        dragingItem.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dragingItem.frame = endFrame
        }) { (finish) in
            self.dragingItem.isHidden = true
            let item = self.collectionView.cellForItem(at: self.dragingIndexPath) as! JSVariableMenuCell
            item.isMoving = false
            item.isHidden = false
            
            if finish == true {
                self.dragingCell = false
            }
        }
    }
    
    private func getTargetIndexPathWith(_ point: CGPoint) -> IndexPath? {
        var targetIndexPath: IndexPath? = nil
        for indexPath in collectionView.indexPathsForVisibleItems {
            if indexPath == dragingIndexPath {
                continue
            }
            
            if indexPath.section > 0 {
                continue
            }
            
            if indexPath.row < fixedNum {
                continue
            }
            
            if collectionView.cellForItem(at: indexPath)?.frame.contains(point) == true {
                if indexPath.row != 0 {
                    targetIndexPath = indexPath
                }
                
                break
            }
        }
        
        return targetIndexPath
    }
    
    private func getDragingIndexPathWith(_ point: CGPoint) -> IndexPath? {
        var dragIndexPath: IndexPath? = nil
        if collectionView.numberOfItems(inSection: 0) == 1 {
            return dragIndexPath
        }
        
        for indexPath in collectionView.indexPathsForVisibleItems {
            if indexPath.section > 0 {
                continue
            }
            
            if indexPath.row < fixedNum {
                continue
            }
            
            if collectionView.cellForItem(at: indexPath)?.frame.contains(point) == true {
                if indexPath.row != 0 {
                    dragIndexPath = indexPath
                }
                
                break
            }
        }
        
        return dragIndexPath
    }
    
    private func reArrangeInUseTitles() -> Void {
        let obj = inUseTitles[dragingIndexPath.row]
        
        inUseTitles.remove(at: dragingIndexPath.row)
        inUseTitles.insert(obj, at: targetIndexPath.row)
    }
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return inUseTitles.count
        } else {
            return unUseTitles.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "JSVariableMenuHeader", for: indexPath) as! JSVariableMenuHeader
        
        if indexPath.section == 0 {
            headerView.title = "已选频道"
            headerView.subTitle = "长按拖动调整排序"
        } else {
            headerView.title = "推荐频道"
            headerView.subTitle = ""
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: JSVariableMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "JSVariableMenuCell", for: indexPath) as! JSVariableMenuCell
        
        if indexPath.section == 0 {
            cell.title = inUseTitles[indexPath.row]
            cell.isFixed = indexPath.row<fixedNum
            cell.showCancel = true
        } else {
            cell.showCancel = false
            cell.title = unUseTitles[indexPath.row]
        } 
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (self.bounds.size.width-2*16-3*CellMarginX)/CGFloat(ColumnNumber)
        
        if dragingItem == nil {
            dragingItem = JSVariableMenuCell.init(frame: CGRect.init(x: 0, y: 0, width: cellWidth, height: 58)~)
            dragingItem.isHidden = true 
            collectionView.addSubview(dragingItem)
        }
        
        return CGSize.init(width: cellWidth, height: 58)~
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CellMarginY
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CellMarginX
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)~
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: self.bounds.size.width, height: 40)~
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dragingCell == true {
            return
        }
        
        if indexPath.section == 0 {
            if collectionView.numberOfItems(inSection: 0) == 1 {
                return
            }
            
            if indexPath.row < fixedNum {
                return
            }
            
            let obj = inUseTitles[indexPath.row]
            
            inUseTitles.remove(at: indexPath.row)
            unUseTitles.insert(obj, at: 0)
            
            collectionView.moveItem(at: indexPath, to: IndexPath.init(row: 0, section: 1))
            
            let insertCell = collectionView.cellForItem(at: IndexPath.init(row: 0, section: 1)) as! JSVariableMenuCell
            insertCell.showCancel = false
        } else {
            let obj = unUseTitles[indexPath.row]
            
            unUseTitles.remove(at: indexPath.row)
            inUseTitles.append(obj)
            
            collectionView.moveItem(at: indexPath, to: IndexPath.init(row: inUseTitles.count-1, section: 0))
            
            let originalCell = collectionView.cellForItem(at: IndexPath.init(row: inUseTitles.count-1, section: 0)) as! JSVariableMenuCell
            originalCell.showCancel = true
        }
    }
    // MARK: - 刷新数据
    func reloadData() -> Void {
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
