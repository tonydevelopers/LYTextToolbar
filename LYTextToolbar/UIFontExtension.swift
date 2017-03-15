//
//  UIFontExtension.swift
//  LYTextToolbar
//
//  Created by tony on 2017/3/13.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

public extension UIFont {
    
    /// 获取字体文件的字体名
    public class func name(path: String) -> String? {
        
        guard let url = URL(string: path) else {
            return nil
        }
        
        return UIFont.name(url: url)
    }
    
    /// 获取字体文件的字体名
    public class func name(url: URL) -> String? {
        
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            
            return nil
        }
        
        let cgFont = CGFont(fontDataProvider)
        
        let fontName = cgFont.fullName as? String
        
        return fontName
    }
    
    /// 动态注册字体
    public class func register(path: String) ->(String?, Bool) {
        
        let url = URL(fileURLWithPath: path)

        return UIFont.register(url: url)
    }
    
    /// 动态注册字体
    public class func register(url: URL) ->(String?, Bool) {
        
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            
            return (nil, false)
        }
        
        let cgFont = CGFont(fontDataProvider)
        let fontName = cgFont.postScriptName as! String
        
        var error: Unmanaged<CFError>?
        let flag = CTFontManagerRegisterGraphicsFont(cgFont, &error)
        
        if !flag {
            if error != nil {
                NSLog("register font: \(error!.takeRetainedValue())")
            }
            return (fontName, false)
        }
        
        return (fontName, true)
    }
    
}
