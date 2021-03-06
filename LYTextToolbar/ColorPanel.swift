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
    
    /*
     * 返回选择的颜色值
     * tag: 0 字体颜色  1: 背景色
     */
    func colorPanel(_ colorPanel: ColorPanel, color: UIColor, tag: Int)
    
}

/**
 * 显示预置颜色
 */
class ColorPanel: UIView {
    
    weak var colorDelegate: ColorPanelDelegate?
    
    var segment: UISegmentedControl!
    
    // 显示当前颜色
    var colorImageView: UIImageView!
    var slider: UISlider!
    
    var textAlphaValue: Float = 1
    var backgroundAlphaValue: Float = 1
    
    var side: CGFloat = 40
    var mCollectionView: UICollectionView!
    // 预设颜色值
    var presetColors: [String]!
    
    var selectedPosition: Int = -1
    
    var segmentItems: [String] = [String]() {
        
        didSet {
            
            segment.removeAllSegments()
            
            for index in 0 ..< segmentItems.count {
                let title: String = segmentItems[index]
                
                segment.insertSegment(withTitle: title, at: index, animated: true)
            }
            
            segment.selectedSegmentIndex = 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        segment = UISegmentedControl(frame: CGRect(x: (frame.width - 160) / 2, y: 8, width: 160, height: 30))
        segment.tintColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)

        self.addSubview(segment)
        
        segment.addTarget(self, action: #selector(segmentChange(sender:)), for: .valueChanged)
        
        let colorPath = Bundle.main.path(forResource: "color_preset.plist", ofType: nil)!
        self.presetColors = NSArray(contentsOfFile: colorPath) as! [String]
        
        let view = UIView(frame: CGRect(x: 0, y: segment.frame.origin.y + segment.frame.height + 8, width: frame.width, height: 50))
        
        self.addSubview(view)
        
        colorImageView = UIImageView(frame: CGRect(x: 10, y: (view.frame.height - side) / 2, width: side, height: side))
        view.addSubview(colorImageView)
        
        let originX = colorImageView.frame.origin.x + colorImageView.frame.width + 16
        slider = UISlider(frame: CGRect(x: originX, y: (view.frame.height - 30) / 2, width: (view.frame.width - originX - 16), height: 30))
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1
        slider.isContinuous = true
        slider.tintColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)
        slider.addTarget(self, action: #selector(sliderChange(sender: )), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderUp(sender: )), for: .touchUpInside)
        view.addSubview(slider)
        
        let edgeMargin: CGFloat = 6

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: side, height: side)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 3 * 2
        layout.minimumInteritemSpacing = 3
        
        mCollectionView = UICollectionView(frame: CGRect(x: 0, y: view.frame.origin.y + view.frame.height + 8, width: frame.width, height: 150), collectionViewLayout: layout)
        mCollectionView.dataSource = self
        mCollectionView.delegate = self
        mCollectionView.register(ColorCell.classForCoder(), forCellWithReuseIdentifier: "ColorCell")
        mCollectionView.backgroundColor = UIColor.clear
        
//        var verticalInset: CGFloat = 0
//        let contentHeight = edgeMargin * 4 + side * 3
//        if contentHeight < frame.height {
//            verticalInset = (frame.height -  - contentHeight) / 2
//        }
        mCollectionView.contentInset = UIEdgeInsetsMake(edgeMargin, edgeMargin, edgeMargin, edgeMargin)
        
        self.addSubview(mCollectionView)
        
    }
    
    @objc func segmentChange(sender: UISegmentedControl) {
        
        switch segment.selectedSegmentIndex {
        case 0:
            slider.value = textAlphaValue
            break
        case 1:
            slider.value = backgroundAlphaValue
            break
        default:
            break
        }
    }
    
    @objc func sliderChange(sender: UISlider) {
        
        
        print("value: \(slider.value)")
        
        switch segment.selectedSegmentIndex {
        case 0:
            textAlphaValue = slider.value
            break
        case 1:
            backgroundAlphaValue = slider.value
            break
        default:
            break
        }
        
        guard let color = self.colorImageView.backgroundColor else {
            return
        }
        
        self.colorImageView.backgroundColor = color.resetAlpha(alpha: CGFloat(slider.value))
    }
    
    @objc func sliderUp (sender: UISlider) {
        
        guard let color = self.colorImageView.backgroundColor else {
            return
        }
        
        self.colorDelegate?.colorPanel(self, color: color, tag: segment.selectedSegmentIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if selectedPosition == indexPath.row {
            return
        }
        
        var preIndexPath: IndexPath! = nil
        
        if self.selectedPosition >= 0 {
            preIndexPath = IndexPath(row: selectedPosition, section: 0)
        }
        
        self.selectedPosition = indexPath.row
        
        if preIndexPath == nil {
            collectionView.reloadItems(at: [indexPath])
        } else {
            if preIndexPath.row != indexPath.row {
                collectionView.reloadItems(at: [preIndexPath, indexPath])
            }
        }
        
        let colorString = self.presetColors[indexPath.row]
        let color = UIColor(rgba: colorString)
        
        var tagColor: UIColor!
        if segment.selectedSegmentIndex == 0 {
            tagColor = color.withAlphaComponent(CGFloat(textAlphaValue))
        } else {
            tagColor = color.withAlphaComponent(CGFloat(backgroundAlphaValue))
        }
        
        self.colorImageView.backgroundColor = tagColor
        
        self.colorDelegate?.colorPanel(self, color: tagColor, tag: segment.selectedSegmentIndex)
    }
    
}
