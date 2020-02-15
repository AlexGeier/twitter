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
            
            // Setting the leftBarButtonItem before pushing the viewController so that it doesn't quickly change from "< Sign In" to "Sign Out"
            let tweetTableViewController = TweetTableViewController()
            tweetTableViewController.navigationItem.leftBarButtonItem = .init(title: "Sign Out", style: .plain, target: self, action: nil)
            self.navigationController?.pushViewController(tweetTableViewController, animated: true)
            
        }, failure: { error in
            let alert = UIAlertController(title: "Uh oh!", message: "Failed to sign in. Try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Sign In"
        view.backgroundColor = .systemBackground
        
        setupLayout()
        
        if UserDefaults.standard.bool(forKey: "userSignedIn") {
            // Setting the leftBarButtonItem before pushing the viewController so that it doesn't quickly change from "< Sign In" to "Sign Out"
            let tweetTableViewController = TweetTableViewController()
            tweetTableViewController.navigationItem.leftBarButtonItem = .init(title: "Sign Out", style: .plain, target: self, action: nil)
            self.navigationController?.pushViewController(tweetTableViewController, animated: true)
        }
    }
    
    private func setupLayout() {
        view.addSubview(signInButton)
        signInButton.centerInSuperview()
    }
}
