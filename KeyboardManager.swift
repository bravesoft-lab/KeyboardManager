//
//  KeyboardManager.swift
//  keyboard
//
//  Created by 藤本 達男 on 2018/11/28.
//  Copyright © 2018 藤本 達男. All rights reserved.
//

import UIKit

class KeyboardManager {
    
    private enum Margin: CGFloat {
        case Default = 20.0
    }
    
    static let shared = KeyboardManager()
    
    private init() {}
    
    lazy private var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    private var margin: CGFloat = Margin.Default.rawValue
    
    func enable() {
        disable()
        
        addObservers()
    }
    
    func setMargin(_ margin: CGFloat) {
        self.margin = margin
    }
    
    func resetMargin() {
        self.margin = Margin.Default.rawValue
    }
    
    func disable() {
        dismissKeyboard()
        removeObservers()
    }
    
    private func addDismissTapGestureRecognizer() {
        guard UIApplication.shared.keyWindow?.gestureRecognizers?.contains(tapGestureRecognizer) == false else {
            return
        }
        
        UIApplication.shared.keyWindow?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func removeDismissTapGestureRecognizer() {
        UIApplication.shared.keyWindow?.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    private var keyboardFrame: CGRect?
    
    private func adjustWindowPoint(keyboardFrame: CGRect) {
        addDismissTapGestureRecognizer()
        
        self.keyboardFrame = keyboardFrame
        
        if let window = UIApplication.shared.keyWindow, let firstResponder = window.firstResponder {
            let y = firstResponder.frame.origin.y + firstResponder.frame.size.height + margin
            if y > keyboardFrame.origin.y {
                let adjustY = max(-keyboardFrame.size.height, keyboardFrame.origin.y - y)
                window.frame = CGRect(origin: CGPoint(x: 0.0, y: adjustY), size: window.frame.size)
            }
        }
    }
    
    private func resetWindowPoint() {
        if let window = UIApplication.shared.keyWindow {
            window.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: window.frame.size)
        }
        
        removeDismissTapGestureRecognizer()
    }
    
    @objc private func dismissKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
}

extension KeyboardManager {
    
    private func addObservers() {
        removeObservers()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillShow(notification:)),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillHide(notification:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardDidHide(notification:)),
                                               name: UIWindow.keyboardDidHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onTextDidBeginEditing(notification:)),
                                               name: UITextField.textDidBeginEditingNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onTextDidBeginEditing(notification:)),
                                               name: UITextView.textDidBeginEditingNotification,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func onTextDidBeginEditing(notification: Notification) {
        if let keyboardFrame = keyboardFrame {
            UIView.animate(withDuration: 0.25) {
                self.adjustWindowPoint(keyboardFrame: keyboardFrame)
            }
        }
    }
    
    @objc private func onKeyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            adjustWindowPoint(keyboardFrame: keyboardFrame)
        }
    }
    
    @objc private func onKeyboardWillHide(notification: Notification) {
        resetWindowPoint()
    }
    
    @objc private func onKeyboardDidHide(notification: Notification) {
        
    }
    
}

extension UIView {
    
    fileprivate var firstResponder: UIView? {
        for subView in self.subviews {
            if subView.isFirstResponder {
                return subView
            } else if let firstResponder = subView.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
    
}
