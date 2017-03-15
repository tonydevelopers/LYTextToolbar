//
//  FontViewController.swift
//  LYTextToolbar
//
//  Created by tony on 2017/3/14.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

class FontViewController: UIViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    
    var fontNames: [String]! = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        let fontFileNames = ["zcool_gaoduanhei.ttf", "zcool_kuaileti.ttf", "zcool_kuhei.ttf", "zcool_yidali.ttf", "droidsansfallback.ttf"]
        
        for fontFileName in fontFileNames {
            
            if let path = Bundle.main.path(forResource: fontFileName, ofType: "") {
                
                let (fontName, _) = UIFont.register(path: path)
                
                if fontName != nil {
                    fontNames.append(fontName!)
                }
            }
        }
        
    }
    
    func systemFonts() {
        
        for str in UIFont.familyNames {
            let names = UIFont.fontNames(forFamilyName: str)
            for name in names {
                
                //NSLog("name: \(name)")
                fontNames.append(name)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }

}

extension FontViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fontNames.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell", for: indexPath) as! FontCell
        
        let name = fontNames[indexPath.row]
        cell.fontLabel.text = name
        cell.titleLabel.font = UIFont(name: name, size: 15)
        cell.titleLabel.text = "字体ABC"
        
        return cell
    }
    
    
}

