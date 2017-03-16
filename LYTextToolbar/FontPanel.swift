//
//  FontPanel.swift
//  LYTextToolbar
//
//  Created by tony on 2017/3/16.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

protocol FontPanelDelegate: NSObjectProtocol {
    
    /// 返回选择的颜色值
    func fontPanel(_ fontPanel: FontPanel, fontName: String)
    
}

class FontPanel: UIView {

    weak var fontDelegate: FontPanelDelegate?
    
    var defaultMaker: String = ""
    var labelName: String = "ABC"
    // 字体路径
    var fontNames: [String]! = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        let defaultFont = UIFont.systemFont(ofSize: 18)
        let defaultFontBold = UIFont.boldSystemFont(ofSize: 18)
        let defaultFontItalic = UIFont.italicSystemFont(ofSize: 18)
        
        fontNames.append(defaultFont.fontName)
        fontNames.append(defaultFontBold.fontName)
        fontNames.append(defaultFontItalic.fontName)
        
        let fontFileNames = ["zcool_gaoduanhei.ttf", "zcool_kuaileti.ttf", "zcool_kuhei.ttf", "zcool_yidali.ttf", "droidsansfallback.ttf"]
        for fontFileName in fontFileNames {
            
            if let path = Bundle.main.path(forResource: fontFileName, ofType: "") {
                
                let (fontName, _) = UIFont.register(path: path)
                
                if fontName != nil {
                    fontNames.append(fontName!)
                }
            }
            
        }
        
        let contentView = self .fontsPanel(width: self.frame.width, height: self.frame.height)
        self.addSubview(contentView)
    }
    
    func fontsPanel(width: CGFloat, height: CGFloat) ->UIView {
        
        let layout_space: CGFloat = 4.0
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (width - layout_space * 4) / 3.0
        layout.itemSize = CGSize(width: itemWidth, height: 40)
        layout.sectionInset = UIEdgeInsetsMake(layout_space, layout_space, layout_space, layout_space);
        layout.minimumInteritemSpacing = layout_space;
        layout.minimumLineSpacing = layout_space;
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: layout)
        collectionView.tag = 0
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(FontCollectionCell.classForCoder(), forCellWithReuseIdentifier: "FontCollectionCell")
        
        collectionView.backgroundColor = .clear
        return collectionView
    }
}


extension FontPanel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if fontNames == nil {
            return 0
        }
        
        return fontNames.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCollectionCell", for: indexPath) as! FontCollectionCell
        
        let name = fontNames[indexPath.row]
        
        if indexPath.row == 0 {
            cell.fontLabel.text = defaultMaker.appending(labelName)
        } else {
            cell.fontLabel.text = labelName
        }
        
        cell.fontLabel.font = UIFont(name: name, size: 18)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let fontName = fontNames[indexPath.row]
        
        self.fontDelegate?.fontPanel(self, fontName: fontName)
    }
    
}

/// 这样声明表示可以被objc代码嗲用
class FontCollectionCell: UICollectionViewCell {
    
    var fontLabel: UILabel!
    var selectBorder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        self.clipsToBounds = true
        
        let margin: CGFloat = 4
        self.fontLabel = UILabel(frame: CGRect(x: margin, y: margin, width: self.bounds.width - margin * 2, height: self.bounds.height - margin * 2))
        self.fontLabel.adjustsFontSizeToFitWidth = true
        self.fontLabel.textAlignment = .center
        self.fontLabel.textColor = UIColor.darkGray
        self.backgroundColor = UIColor.white
        
        addSubview(fontLabel)
        
        let borderMargin: CGFloat = 8
        selectBorder = UIView(frame: CGRect(x: borderMargin, y: borderMargin, width: self.bounds.width - borderMargin * 2, height: self.bounds.height - borderMargin * 2))
        selectBorder.layer.borderWidth = 2
        selectBorder.layer.cornerRadius = 3
        selectBorder.layer.borderColor = UIColor.orange.cgColor
        
        addSubview(selectBorder)
        
        selectBorder.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin: CGFloat = 10
        fontLabel.frame = CGRect(x: margin, y: margin, width: self.bounds.width - margin * 2, height: self.bounds.height - margin * 2)
        
        let borderMargin: CGFloat = 6
        selectBorder.frame = CGRect(x: borderMargin, y: borderMargin, width: self.bounds.width - borderMargin * 2, height: self.bounds.height - borderMargin * 2)
        
    }
    
}
