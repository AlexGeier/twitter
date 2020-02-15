//
//  CreateTweetViewController.swift
//  Twitter
//
//  Created by Alex Geier on 2/12/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import TinyConstraints

// Code to get textview to stick to top of keyboard from https://stackoverflow.com/questions/45399178/extend-ios-11-safe-area-to-include-the-keyboard
public extension UIViewController
{
    func startAvoidingKeyboard() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onKeyboardFrameWillChangeNotificationReceived(_:)),
                         name: UIResponder.keyboardWillChangeFrameNotification,
                         object: nil)
    }
    
    func stopAvoidingKeyboard() {
        NotificationCenter.default
            .removeObserver(self,
                            name: UIResponder.keyboardWillChangeFrameNotification,
                            object: nil)
    }
    
    @objc private func onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
                        self.additionalSafeAreaInsets.bottom = intersection.height
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

class CreateTweetViewController: UIViewController, UITextViewDelegate {
    private let placeholder = "Say something:"
    
    private lazy var tweetContentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .placeholderText
        textView.text = placeholder
        
        return textView
    }()
    
    private let charactersRemainingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.text = "140 characters remaining"
        
        return label
    }()
    
    override func viewDidLoad() {
        setupLayout()
        
        navigationItem.title = "Tweet"
        navigationItem.rightBarButtonItem = .init(title: "Post", style: .plain, target: self, action: #selector(onTweetPressed))
        
        tweetContentTextView.layer.borderWidth = 1
        tweetContentTextView.layer.borderColor = UIColor.separator.cgColor
        
        view.backgroundColor = .systemBackground
        
        tweetContentTextView.delegate = self
        tweetContentTextView.becomeFirstResponder()
        
        startAvoidingKeyboard()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = tweetContentTextView.text {
            if text.count > 140 {
                tweetContentTextView.text = String(text.prefix(140))
                charactersRemainingLabel.text = "0 characters remaining"
            } else {
                charactersRemainingLabel.text = "\(140 - text.count) characters remaining"
            }
        } else {
            charactersRemainingLabel.text = "140 characters remaining"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText
        }
    }
    
    @objc private func onTweetPressed() {
        postTweet() {}
    }
    
    private func postTweet(completion: @escaping () -> ()) {
        TwitterService.shared?.postTweet(content: tweetContentTextView.text, completion: { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .failure:
                let alert = UIAlertController(title: "Uh oh!", message: "Failed to post tweet. Try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    private func setupLayout() {
        let bottomContentStackView = UIStackView(arrangedSubviews: [
            charactersRemainingLabel,
        ])
        bottomContentStackView.axis = .vertical
        bottomContentStackView.alignment = .center
        // TODO: Look into adding spacing after charactersRemainingLabel
        
        let mainVerticalStackView = UIStackView(arrangedSubviews: [
            tweetContentTextView,
            bottomContentStackView,
        ])
        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.spacing = 8
        
        view.addSubview(mainVerticalStackView)
        mainVerticalStackView.edgesToSuperview(excluding: .bottom)
        mainVerticalStackView.edgesToSuperview(excluding: [.top, .left, .right], usingSafeArea: true)
    }
}
