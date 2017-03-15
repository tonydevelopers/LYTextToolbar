//
//  ColorExtension.swift
//  LYTextToolbar
//
//  Created by tony on 2017/3/12.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

extension UIColor {
    
    /** 使用16进制字符串创建颜色 以#开头
     声明便利构造器,必须调用指定构造器
     - parameter rgba: rgba description
     - returns: return value description
     */
    public convenience init(rgba:String) {
        var red:CGFloat = 0.0;
        var green:CGFloat = 0.0;
        var blue:CGFloat = 0.0;
        var alpha: CGFloat = 1.0;
        if(rgba.hasPrefix("#")){
            let index = rgba.characters.index(rgba.startIndex, offsetBy: 1);
            
            let hex = rgba.substring(from: index);
            let scanner = Scanner(string: hex);
            var hexValue:CUnsignedLongLong = 0;
            if(scanner.scanHexInt64(&hexValue)){
                switch(hex.characters.count){
                case 3:
                    red = CGFloat((hexValue & 0xF00) >> 8)/15.0;
                    green = CGFloat((hexValue & 0x0F0) >> 4)/15.0;
                    blue = CGFloat(hexValue & 0x00F) / 15.0;
                case 4:
                    red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
                    blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
                    alpha = CGFloat(hexValue & 0x000F) / 15.0
                case 6:
                    red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                    blue = CGFloat(hexValue & 0x0000FF) / 255.0
                case 8:
                    red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF) / 255.0
                default:
                    NSLog("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8");
                }
            }else{
                NSLog("Scan hex error")
            }
        }else{
            NSLog("Invalid RGB string, missing '#' as prefix")
        }
        //调用指定构造器,如果不调用指定构造器是无法通过编译的
        self.init(red:red, green:green, blue:blue, alpha:alpha);
    }
    
}
