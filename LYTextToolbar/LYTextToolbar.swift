//
//  LYSubtitleToolbar.swift
//  LYSubtitleToolbar
//
//  Created by tony on 2016/12/21.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit

public protocol LYTextToolbarDelegate: NSObjectProtocol {
    
    // completion: 是否完成编辑
    func textToolbar(toolbar: LYTextToolbar, text: String?, completion: Bool)
    
}

protocol LYChatToolbarDelegate: NSObjectProtocol {
    
    func chatToolbarCancel(toolbar: LYChatToolbar, text: String?)
    
    func chatToolbarDone(toolbar: LYChatToolbar, text: String?)
    
    // 点击选中的选项
    func chatToolbar(toolbar: LYChatToolbar, tabIndex: Int)
    
}

// 工具栏的高度
private let ToolbarHeight: CGFloat = 88

/** 文本输入面板 */
open class LYTextToolbar: UIView {

    weak var textToolbarDelegate: LYTextToolbarDelegate?
  
    // 文本输入 --- 显示键盘输入器
    var toolbar: LYChatToolbar!
    
    // 内容面板
    var contentPanel: UIView!
    // siri语音转换
    var voicePanel: UIView!
    
    // 字体切换
    var fontPanel: UIView!
    
    // 颜色拾取面板
    var colorPickerPanel: UIView!
    
    // 字体控制面板
    var controlPanel: UIView!
    
    // 记录键盘的高度
    public var panelHeight: CGFloat = 282
    
    public convenience init() {
        let bounds = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: ToolbarHeight + 320)
    
        self.init(frame: frame)
        
        self.setup()
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    // 关联到视图控制器
    public func attachToViewController(controller: UIViewController) {
        
        controller.view.addSubview(self)
    }
    
    // 关联面板视图
    public func attachPanelView(panelView: UIView, index: Int) {
        
        if index < 0 || index > 3 {
            return
        }
        
        var destPanelView: UIView!
        switch index {
        case 0:
            destPanelView = voicePanel
            break
        case 1:
            destPanelView = fontPanel
            break
        case 2:
            destPanelView = colorPickerPanel
            break
        case 3:
            destPanelView = controlPanel
            break
        default:
            break
        }
        
        for view in destPanelView.subviews {
            view.removeFromSuperview()
        }
        
        destPanelView.addSubview(panelView)
        
        // 添加约束
        // 垂直方向居中与父视图
        self.addConstraint(NSLayoutConstraint(item: panelView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: panelView.superview!, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: panelView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: panelView.superview!, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.setup()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.removeObserver(self, forKeyPath: "toolbar.frame")
    }
    
    func setup() {
        
        let bounds = UIScreen.main.bounds
        
        // 文本输入面板
        toolbar = LYChatToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: ToolbarHeight))
        toolbar.toolbarDelegate = self
        
        self.addSubview(toolbar)
        
        self.contentPanel = UIView(frame: CGRect(x: 0, y: ToolbarHeight, width: bounds.width, height: panelHeight))
        self.addSubview(contentPanel)
        
        // 添加siri面板
        let panelFrame = CGRect(x: 0, y: 0, width: contentPanel.frame.width, height: contentPanel.frame.height)
        voicePanel = UIView(frame: panelFrame)
        contentPanel.addSubview(voicePanel)
        
        // 字体面板
        fontPanel = UIView(frame: panelFrame)
        contentPanel.addSubview(fontPanel)
        
        // 颜色拾取面板
        colorPickerPanel = UIView(frame: panelFrame)
        contentPanel.addSubview(colorPickerPanel)
        
        // 字幕控制面板
        controlPanel = UIView(frame: panelFrame)
        contentPanel.addSubview(controlPanel)
        
        let autoresizingMask: UIViewAutoresizing = [.flexibleWidth, .flexibleHeight]
        voicePanel.autoresizingMask = autoresizingMask
        fontPanel.autoresizingMask = autoresizingMask
        colorPickerPanel.autoresizingMask = autoresizingMask
        controlPanel.autoresizingMask = autoresizingMask
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.addObserver(self, forKeyPath: "toolbar.frame", options: [.new, .old], context: nil)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        
        let bounds = UIScreen.main.bounds
        let userInfo = notification.userInfo as! [String: Any]
        
        let animationDuration = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as! Double
        let frameEnd = userInfo["UIKeyboardFrameEndUserInfoKey"] as! CGRect

        if panelHeight != frameEnd.height {
            panelHeight = frameEnd.height
            contentPanel.frame = CGRect(x: 0, y: ToolbarHeight, width: bounds.width, height: panelHeight)
        }
        
        let flag = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        self.toggleToolbar(showEnabled: flag, animationDuration: animationDuration)
    }
    
    /**
     * 是否显示面板
     * flag 是否强制关闭
     */
    func toggleToolbar(showEnabled: Bool, animationDuration: Double) {
        
        let bounds = UIScreen.main.bounds
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] in
            
            if showEnabled  {// 弹出
                
                // 判断显示哪个面板
                let frame = CGRect(x: 0, y: bounds.height - (ToolbarHeight + self!.panelHeight), width: bounds.width, height: ToolbarHeight + self!.panelHeight)
                self?.frame = frame
            } else {// 隐藏
                
                if self!.toolbar.closeEnabled() {
                    self?.hide()
                }
                
            }
            
        }) { (success: Bool) in
            
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let obj = object as? LYTextToolbar
        if obj == nil {
            return
        }
        // 重新调节高度
        if keyPath == "toolbar.frame" {
            
        }
        
    }
    
    // 显示输入面板
    public func show() {
        
        self.toolbar.show()
    }
    
    // 隐藏编辑面板
    public func hide() {
        
        self.toolbar.hideKeyboard()
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] in
            
            let frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: ToolbarHeight + self!.panelHeight)
            self?.frame = frame
            
        }) { (success: Bool) in
            
        }
        
    }

}

extension LYTextToolbar: LYChatToolbarDelegate {
    
    internal func chatToolbar(toolbar: LYChatToolbar, tabIndex: Int) {
        
        voicePanel.isHidden = true
        fontPanel.isHidden = true
        colorPickerPanel.isHidden = true
        controlPanel.isHidden = true
        
        switch tabIndex {
        case 0:
            voicePanel.isHidden = false
            break
        case 1:
            fontPanel.isHidden = false
            break
        case 2:
            colorPickerPanel.isHidden = false
            break
        case 3:
            controlPanel.isHidden = false
            break
        default:
            break
        }
        
    }
    
    internal func chatToolbarDone(toolbar: LYChatToolbar, text: String?) {
        
        self.hide()
        
        self.textToolbarDelegate?.textToolbar(toolbar: self, text: text, completion: true)
    }
    
    internal func chatToolbarCancel(toolbar: LYChatToolbar, text: String?) {
        
        self.hide()
        
        self.textToolbarDelegate?.textToolbar(toolbar: self, text: text, completion: false)
    }
    
}

// 文本输入栏, 操作工具栏
class LYChatToolbar: UIView, UITextViewDelegate {
    
    weak var toolbarDelegate: LYChatToolbarDelegate?
    
    // 当前文本
    var currentText: String!
    
    // 分隔线
    var splitLine: UIImageView!
    // siri入口
    var btVoice: UIButton!
    // 字体切换
    var btFont: UIButton!
    // 调色板
    var btColor: UIButton!
    // 设置
    var btControl: UIButton!
    
    // 文本输入框
    var subtitleTextView: LYSubtitleTextView!
    var btDismiss: UIButton!
    var btDone: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {
        
        //self.removeObserver(self, forKeyPath: "self.textView.contentSize")
    }
    
    private func setup() {
        
        self.isUserInteractionEnabled = true
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        
        let bounds = UIScreen.main.bounds
        
        let doneButtonWidth: CGFloat = 50
        
        let topHeight: CGFloat = 44
        let topbar = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: topHeight))
        self.addSubview(topbar)
        
        self.btDismiss = self.createButton(selector: #selector(toolbarCancelClick(_:)), tag: -1)
        self.btDismiss.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        topbar.addSubview(self.btDismiss)
        self.btDismiss.frame = CGRect(x: 0, y: 0, width: doneButtonWidth, height: topHeight)
        self.btDismiss.setTitle("", for: .normal)
        
        self.btDismiss.setBackgroundImage(UIImage(named: "bt_text_toolbar_cancel"), for: UIControlState())
        self.btDismiss.setBackgroundImage(UIImage(named: "bt_text_toolbar_cancel_p"), for: UIControlState.highlighted)
        
        self.subtitleTextView = LYSubtitleTextView(frame: CGRect(x: doneButtonWidth, y: 0, width: bounds.width - doneButtonWidth * 2, height: topHeight))
        self.subtitleTextView.returnKeyType = .done
        self.subtitleTextView.delegate = self
        topbar.addSubview(subtitleTextView)
        
        self.btDone = self.createButton(selector: #selector(toolbarDoneClick(_:)), tag: -1)
        topbar.addSubview(self.btDone)
        self.btDone.frame = CGRect(x: bounds.width - doneButtonWidth, y: 0, width: doneButtonWidth, height: topHeight)
        self.btDone.setTitle("Done", for: .normal)

        btDone.backgroundColor = UIColor.orange
        btDone.layer.cornerRadius = 5
        btDone.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btDone.setTitleColor(UIColor.white, for: UIControlState())
        
        
        let view = UIView(frame: CGRect(x: 0, y: topbar.frame.height, width: bounds.width, height: self.frame.height - topHeight))
        self.addSubview(view)
        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        
        self.btVoice = self.createButton(selector: #selector(toolbarButtonClick(_:)), tag: 0)
        self.btFont = self.createButton(selector: #selector(toolbarButtonClick(_:)), tag: 1)
        self.btColor = self.createButton(selector: #selector(toolbarButtonClick(_:)), tag: 2)
        self.btControl = self.createButton(selector: #selector(toolbarButtonClick(_:)), tag: 3)
        
        view.addSubview(self.btVoice)
        view.addSubview(self.btFont)
        view.addSubview(self.btColor)
        view.addSubview(self.btControl)
        
        splitLine = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1))
        splitLine.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        view.addSubview(self.splitLine)
        splitLine.autoresizingMask = [.flexibleWidth]
        
        btVoice.setImage(UIImage(named: "bt_text_toolbar_siri"), for: .normal)
        btVoice.setImage(UIImage(named: "bt_text_toolbar_siri_p"), for: .selected)
        btFont.setImage(UIImage(named: "bt_text_toolbar_font"), for: .normal)
        btFont.setImage(UIImage(named: "bt_text_toolbar_font_p"), for: .selected)
        btColor.setImage(UIImage(named: "bt_text_toolbar_color"), for: .normal)
        btColor.setImage(UIImage(named: "bt_text_toolbar_color_p"), for: .selected)
        btControl.setImage(UIImage(named: "bt_text_toolbar_control"), for: .normal)
        btControl.setImage(UIImage(named: "bt_text_toolbar_control_p"), for: .selected)
        
        let buttonWidth: CGFloat = bounds.width / 4
        
        self.btVoice.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: view.frame.height)
        self.btFont.frame = CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: view.frame.height)
        self.btColor.frame = CGRect(x: buttonWidth * 2, y: 0, width: buttonWidth, height: view.frame.height)
        self.btControl.frame = CGRect(x: buttonWidth * 3, y: 0, width: buttonWidth, height: view.frame.height)

        // 动态改变文本高度
        //self.addObserver(self, forKeyPath: "self.textView.contentSize", options: [.new], context: nil)
        
        self.addConstraintForSubviewsWithCode()
    }
    
    /** 代码添加约束 */
    func addConstraintForSubviewsWithCode() {
        btDismiss.translatesAutoresizingMaskIntoConstraints = false
        subtitleTextView.translatesAutoresizingMaskIntoConstraints = false
        btDone.translatesAutoresizingMaskIntoConstraints = false
        
        //================取消按钮设置
        // 设置宽高
        self.addConstraint(NSLayoutConstraint(item: btDismiss, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 32))
        self.addConstraint(NSLayoutConstraint(item: btDismiss, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 32))
        // 左边距为8
        self.addConstraint(NSLayoutConstraint(item: btDismiss, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 8))
        
        // 垂直方向居中与父视图
        self.addConstraint(NSLayoutConstraint(item: btDismiss, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: btDismiss.superview!, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        //=================OK按钮
        self.addConstraint(NSLayoutConstraint(item: btDone, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50))
        self.addConstraint(NSLayoutConstraint(item: btDone, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 32))
        
        // 左边距为8
        self.addConstraint(NSLayoutConstraint(item: btDone, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -8))
        
        // 垂直方向居中与父视图
        self.addConstraint(NSLayoutConstraint(item: btDone, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: btDone.superview!, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        //===================输入框设置
        self.addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 32))
        
        // 垂直方向居中与父视图
        self.addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: subtitleTextView.superview!, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: btDismiss, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: btDone, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -8))
    }
    
    private func createButton(selector: Selector, tag: Int) ->UIButton {
        
        let button = UIButton(type: .custom)
        button.tag = tag
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        button.autoresizingMask = [.flexibleTopMargin]
        
        return button
    }
    
    // 点击完成按钮
    @objc func toolbarDoneClick(_ button: UIButton) {
        
        let text = self.subtitleTextView.text
        self.clearTabStatus()
        self.currentText = ""
        self.subtitleTextView.text = ""
        self.subtitleTextView.resignFirstResponder()
        
        self.toolbarDelegate?.chatToolbarDone(toolbar: self, text: text)
    }
    
    // 点击完成按钮
    @objc func toolbarCancelClick(_ button: UIButton) {
        
        let text = self.subtitleTextView.text
        self.clearTabStatus()
        
        self.currentText = ""
        self.subtitleTextView.text = ""
        // 键盘隐藏的情况下此处无法隐藏
        self.subtitleTextView.resignFirstResponder()
        
        self.toolbarDelegate?.chatToolbarCancel(toolbar: self, text: text)
    }
    
    @objc func toolbarButtonClick(_ button: UIButton) {
        
        if button.isSelected {
            
            button.isSelected = false
            self.show()
            return
        }
        
        self.clearTabStatus()
        
        button.isSelected = true
        
        self.subtitleTextView.text = self.currentText
        self.hideKeyboard()
        
        self.toolbarDelegate?.chatToolbar(toolbar: self, tabIndex: button.tag)
    }
    
    private func clearTabStatus() {
        self.btVoice.isSelected = false
        self.btFont.isSelected = false
        self.btColor.isSelected = false
        self.btControl.isSelected = false
    }
    
    // 是否关闭
    func closeEnabled() -> Bool {
        
        if tabIndex() >= 0 {// 有面板选中的情况
            
            if self.subtitleTextView.isFirstResponder == false {
                return true
            }
        } else {
            return true
        }
        
        return false
    }
    
    // 显示哪一个选项卡
    func tabIndex() ->Int {
        
        if self.btVoice.isSelected {
            return 0
        } else if self.btFont.isSelected {
            return 1
        } else if self.btColor.isSelected {
            return 2
        } else if self.btControl.isSelected {
            return 3
        }
        
        return -1
    }
    
    func show() {
        self.subtitleTextView.becomeFirstResponder()
    }
    
    // 隐藏键盘
    func hideKeyboard() {
        self.subtitleTextView.resignFirstResponder()
    }
    
    // MARK -- UITextViewDelegate
    internal func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        
        
        return true
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        
        // 执行委托
    }
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            self.currentText = ""
            textView.text = ""
            return false
        }
        
        return true
    }
    
    internal func textViewDidChange(_ textView: UITextView) {
        
        self.currentText = textView.text
        // 回调
    }
    
}

class LYSubtitleTextView: UITextView {
    
    public var placeholder: String!
    
    public var placeholderTextColor: UIColor! = UIColor.lightGray
    
    public var numberOfLineOfText: UInt!

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {
        self.removeTextViewObservers()
    }
    
    fileprivate func placeholderTextAttributes() ->[String: Any]? {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = self.textAlignment
        
        var attrs = [String: Any]()
        
        attrs[NSFontAttributeName] = self.font
        attrs[NSForegroundColorAttributeName] = self.placeholderTextColor
        attrs[NSParagraphStyleAttributeName] = paragraphStyle
        
        return attrs
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        if self.text.characters.count == 0 && self.placeholder != nil {
            self.placeholderTextColor.set()

            (self.placeholder as NSString).draw(in: CGRect(x: 7, y: 7.5, width: 100 - 7 * 2, height: 100 - 7.5 * 2), withAttributes: self.placeholderTextAttributes())
        }
        
    }
    
    func setup() {
        
        self.font = UIFont.systemFont(ofSize: 16.0)
        self.textColor = UIColor.black
        self.layer.borderColor = UIColor(white: 0.6, alpha: 1.0).cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.65
        self.contentMode = .redraw
        self.dataDetectorTypes = .all
        self.returnKeyType = .send
        self.enablesReturnKeyAutomatically = true
        
        self.addTextViewObservers()
    }
    
    public override var attributedText: NSAttributedString! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var font: UIFont? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var text: String! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    func addTextViewObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTextView(_ :)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTextView(_ :)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTextView(_ :)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
        
    }
    
    func removeTextViewObservers() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
        
    }
    
    @objc func didReceiveTextView(_ notification: Notification) {
        
        self.setNeedsDisplay()
    }
    
}


