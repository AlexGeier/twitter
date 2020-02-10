//
//  SignInViewController.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import TinyConstraints

class SignInViewController: UIViewController {
    let signInButton: UIButton = {
        let button = Button(backgroundColor: .systemBlue)
        button.setTitle("Sign in with Twitter", for: .normal)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        button.addTarget(self, action: #selector(onSignInPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func onSignInPressed() {
        TwitterService.shared?.signIn(controller: self, url: "https://api.twitter.com/oauth/request_token", success: {
            UserDefaults.standard.set(true, forKey: "userSignedIn")
            self.navigationController?.pushViewController(TweetTableViewController(), animated: true)
        }, failure: { error in
            // TODO: Alert that there was an error signing in
            print(error)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Sign In"
        view.backgroundColor = .systemBackground
        
        setupLayout()
        
        if UserDefaults.standard.bool(forKey: "userSignedIn") {
            print("true")
            self.navigationController?.pushViewController(TweetTableViewController(), animated: true)
        } else {
            print("false")
        }
        
    }
    
    private func setupLayout() {
        view.addSubview(signInButton)
        signInButton.centerInSuperview()
    }
}
