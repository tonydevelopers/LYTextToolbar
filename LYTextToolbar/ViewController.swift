//
//  ViewController.swift
//  LYSubtitleToolbar
//
//  Created by tony on 2016/12/21.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var subtitleToolbar: LYTextToolbar!
    
    // 字体路径
    var fontsPath: [String]! = [String]()
    var colors: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setup()
    }
    
    fileprivate func setup() {
        
        for i in 0 ..< 20 {
            fontsPath.append("font\(i)")
        }
        subtitleToolbar = LYTextToolbar()
        subtitleToolbar.textToolbarDelegate = self
        
        subtitleToolbar.attachToViewController(controller: self)
        
        let width = self.view.frame.width
        let panelHeight = subtitleToolbar.panelHeight
        let view0 = self.fontsPanel(width: width, height: panelHeight)
        let view1 = ColorPanel(frame: CGRect(x: 0, y: 0, width: width, height: panelHeight))
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: width, height: panelHeight))
        
        subtitleToolbar.attachPanelView(panelView: view0, index: 0)
        subtitleToolbar.attachPanelView(panelView: view1, index: 1)
        subtitleToolbar.attachPanelView(panelView: view2, index: 2)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        
        subtitleToolbar.show()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        
        subtitleToolbar.hide()
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let control = storyboard.instantiateViewController(withIdentifier: "FontViewController")
        
        self.present(control, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if fontsPath == nil {
            return 0
        }
        
        return fontsPath.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCollectionCell", for: indexPath) as! FontCollectionCell
        
        let text = fontsPath[indexPath.row]
        
        cell.fontLabel.text = text
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let text = fontsPath[indexPath.row]
        
        print("text: \(text)")
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
        self.fontLabel.textColor = .gray
        
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


extension ViewController: LYTextToolbarDelegate {
    
    // completion: 是否完成编辑
    func textToolbar(toolbar: LYTextToolbar, text: String?, completion: Bool){
        
        print("text: \(text)   \(completion)")
    }
    
}

