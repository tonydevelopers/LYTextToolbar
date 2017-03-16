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
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var colors: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setup()
    }
    
    fileprivate func setup() {
        
        subtitleToolbar = LYTextToolbar()
        subtitleToolbar.textToolbarDelegate = self
        
        subtitleToolbar.attachToViewController(controller: self)
        
        let width = self.view.frame.width
        let panelHeight = subtitleToolbar.panelHeight
        let fontPanel = FontPanel(frame: CGRect(x: 0, y: 0, width: width, height: panelHeight))
        let colorPanel = ColorPanel(frame: CGRect(x: 0, y: 0, width: width, height: panelHeight))
        let controlPanel = UIView(frame: CGRect(x: 0, y: 0, width: width, height: panelHeight))
        
        fontPanel.defaultMaker = "默认"
        fontPanel.labelName = "字体ABC"
        fontPanel.fontDelegate = self

        colorPanel.colorDelegate = self
        colorPanel.segmentItems = ["颜色", "背景"]
        
        subtitleToolbar.attachPanelView(panelView: fontPanel, index: 0)
        subtitleToolbar.attachPanelView(panelView: colorPanel, index: 1)
        subtitleToolbar.attachPanelView(panelView: controlPanel, index: 2)
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

extension ViewController: LYTextToolbarDelegate {
    
    // completion: 是否完成编辑
    func textToolbar(toolbar: LYTextToolbar, text: String?, completion: Bool){
        
        print("text: \(text)   \(completion)")
    }
    
}

extension ViewController: FontPanelDelegate {
    
    func fontPanel(_ fontPanel: FontPanel, fontName: String) {
        
        if let preFont = self.titleLabel.font {
            self.titleLabel.font = UIFont(name: fontName, size: preFont.pointSize)
        } else {
            self.titleLabel.font = UIFont(name: fontName, size: 18)
        }
        
    }
    
}

extension ViewController: ColorPanelDelegate {
    
    func colorPanel(_ colorPanel: ColorPanel, rgbColor: String, tag: Int) {
        
        if  tag == 0 {
            self.titleLabel.textColor = UIColor(rgba: rgbColor)
        } else {
            self.titleLabel.backgroundColor = UIColor(rgba: rgbColor)
        }
        
    }
    
}
