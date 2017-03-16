//
//  ControlPanel.swift
//  LYTextToolbar
//
//  Created by tony on 2017/3/16.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

protocol ControlPanelDelegate: NSObjectProtocol {
    
    /// 返回位置
    func controlPanel(_ controlPanel: ControlPanel, location: Int)
    
    /// 返回平移参数
    func controlPanel(_ controlPanel: ControlPanel, translationX: CGFloat, translationY: CGFloat)
    
}

class ControlPanel: UIView {

    weak var controlDelegate: ControlPanelDelegate?
    
    var lineWidth:CGFloat = 1;// 线的宽度
    var numberOfColumns:UInt = 2;// 列数
    var numberOfRows:UInt = 2;// 行数
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.setup();
    }
    
    init () {
        super.init(frame: CGRect.zero);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
        self.lineWidth = 0.3
        
        let width: CGFloat = self.frame.width / 3
        let height: CGFloat = self.frame.height / 3
        
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        
        for i: Int in 0 ..< 9 {
            
            let row = i / 3
            let col = i % 3
            
            originX = width * CGFloat(col)
            originY = height * CGFloat(row)
            
            let button = UIButton(frame: CGRect(x: originX, y: originY, width: width, height: height))
            
            button.tag = i
            self.addSubview(button)
            
            let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            let color2 = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
            button.setBackgroundImage(color.bitmap(), for: .normal)
            button.setBackgroundImage(color2.bitmap(), for: .highlighted)
            
            button.layer.borderWidth = 0.3
            button.layer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
            button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func buttonClick(sender: UIButton) {

        self.controlDelegate?.controlPanel(self, location: sender.tag)
    }
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        let translation:CGPoint = gesture.translation(in: self);
        switch gesture.state {
        case .began:
            
            break
        case .changed:
            
            self.controlDelegate?.controlPanel(self, translationX: translation.x, translationY: translation.y)
            gesture.setTranslation(CGPoint.zero, in: self);
            
            break;
        case .cancelled, .ended, .failed:
            
            break;
        default:
            break;
        }
        
        
    }
    
    override func draw(_ rect: CGRect) {
//        let context = UIGraphicsGetCurrentContext();
//        context?.setLineWidth(self.lineWidth);
//        //context?.setStrokeColor(UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1).cgColor)
//        context?.setStrokeColor(UIColor.red.cgColor);
//        let columnWidth = self.frame.size.width / (CGFloat(self.numberOfColumns) + 1);
//        let rowHeight = self.frame.size.height / (CGFloat(self.numberOfRows) + 1);
//        
//        // 绘制竖直线
//        for i:UInt in 1 ... self.numberOfColumns {
//            var startPoint:CGPoint = CGPoint.zero;
//            startPoint.x = columnWidth * CGFloat(i);
//            startPoint.y = 0.0;
//            
//            var endPoint:CGPoint = CGPoint.zero;
//            endPoint.x = startPoint.x;
//            endPoint.y = self.frame.size.height;
//            
//            context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y));
//            context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y));
//            context?.strokePath();
//            
//        }
//        
//        // 绘制横线
//        for i:UInt in 1 ... self.numberOfRows {
//            var startPoint:CGPoint = CGPoint.zero;
//            startPoint.x = 0.0;
//            startPoint.y = rowHeight * CGFloat(i);
//            
//            var endPoint:CGPoint = CGPoint.zero;
//            endPoint.x = self.frame.size.width;
//            endPoint.y = startPoint.y;
//            
//            context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y));
//            context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y));
//            context?.strokePath();
//            
//        }
//        
    }

}
