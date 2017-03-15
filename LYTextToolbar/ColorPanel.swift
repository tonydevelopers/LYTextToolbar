//
//  ColorPanel.swift
//  LYTextToolbar
//
//  Created by tony on 2017/3/12.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

import UIKit

protocol ColorPanelDelegate: NSObjectProtocol {
    
    /// 返回选择的颜色值
    func colorPanel(_ colorPanel: ColorPanel, rgbColor: String)
    
}

/**
 * 显示预置颜色
 */
class ColorPanel: UIView {
    
    weak var colorDelegate: ColorPanelDelegate?
    
    var segment: UISegmentedControl!
    var slider: UISlider!
    
    var mCollectionView: UICollectionView!
    // 预设颜色值
    var presetColors: [String]!
    
    var selectedPosition: Int = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //segment = UISegmentedControl(frame: CGRect(x: 10, y: 10, width: 100, height: 40))
        segment = UISegmentedControl(items: ["颜色", "背景"])
        self.addSubview(segment)
        
        //segment.setTitle("颜色", forSegmentAt: 0)
        //segment.setTitle("背景", forSegmentAt: 1)
        segment.addTarget(self, action: #selector(change(sender:)), for: .valueChanged)
        
        let colorPath = Bundle.main.path(forResource: "color_preset.plist", ofType: nil)!
        self.presetColors = NSArray(contentsOfFile: colorPath) as! [String]
        
        let edgeMargin: CGFloat = 6
        let column: CGFloat = 8
        let size = (frame.width - edgeMargin * 2 - edgeMargin * (column - 1)) / column
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: size, height: size)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 3 * 2
        layout.minimumInteritemSpacing = 3
        
        mCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 180), collectionViewLayout: layout)
        mCollectionView.dataSource = self
        mCollectionView.delegate = self
        mCollectionView.register(ColorCell.classForCoder(), forCellWithReuseIdentifier: "ColorCell")
        mCollectionView.backgroundColor = UIColor.clear
        
        var verticalInset: CGFloat = 0
        let contentHeight = edgeMargin * 4 + size * 3
        if contentHeight < frame.height {
            verticalInset = (frame.height - contentHeight) / 2
        }
        mCollectionView.contentInset = UIEdgeInsetsMake(verticalInset, edgeMargin, verticalInset, edgeMargin)
        
        self.addSubview(mCollectionView)
        
        slider = UISlider(frame: CGRect(x: 40, y: mCollectionView.frame.origin.y + mCollectionView.frame.height + 10, width: frame.width - 40 * 2, height: 30))
        
        self.addSubview(slider)
    }
    
    @objc func change(sender: UISegmentedControl) {
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}

class ColorCell: UICollectionViewCell {
    
    var colorView: UIImageView!
    var colorViewMarker: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let padding:CGFloat = 2
        colorView = UIImageView(frame: CGRect(x: padding, y: padding, width: frame.width - padding * 2, height: frame.height - padding * 2))
        colorView.layer.cornerRadius = 2
        
        self.addSubview(colorView)
        
        colorViewMarker = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        colorViewMarker.layer.borderColor = UIColor.orange.cgColor
        colorViewMarker.layer.borderWidth = 2
        colorViewMarker.layer.cornerRadius = 2
        
        self.addSubview(colorViewMarker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ColorPanel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.presetColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        
        let colorString = self.presetColors[indexPath.row]
        
        cell.colorView.backgroundColor = UIColor(rgba: colorString)
        
        cell.colorViewMarker.isHidden = indexPath.row != selectedPosition
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var preIndexPath: IndexPath! = nil
        
        if self.selectedPosition >= 0 {
            preIndexPath = IndexPath(row: selectedPosition, section: 0)
        }
        
        self.selectedPosition = indexPath.row
        
        if preIndexPath == nil {
            collectionView.reloadItems(at: [indexPath])
        } else {
            collectionView.reloadItems(at: [preIndexPath, indexPath])
        }
        
        let colorString = self.presetColors[indexPath.row]
        self.colorDelegate?.colorPanel(self, rgbColor: colorString)
    }
    
}
