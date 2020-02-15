//
//  TweetTableViewController.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController {
    private let cellId = "cellId"
    private var tweets = [Tweet]()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    private let refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Twitter"
        navigationItem.leftBarButtonItem = .init(title: "Sign Out", style: .plain, target: self, action: #selector(onSignOutPressed))
        navigationItem.rightBarButtonItem = .init(title: "Tweet", style: .plain, target: self, action: #selector(onCreateTweetPressed))
        
        tableView.register(TweetCell.self, forCellReuseIdentifier: cellId)
        
        tableView.addSubview(loadingIndicator)
        loadingIndicator.centerInSuperview()
        
        refreshControl = refreshController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadingIndicator.startAnimating()

        fetchData() {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    @objc private func onCreateTweetPressed() {
        navigationController?.pushViewController(CreateTweetViewController(), animated: true)
    }
    
    @objc private func onSignOutPressed() {
        TwitterService.shared?.signOut()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onRefresh() {
        fetchData {
            self.refreshController.endRefreshing()
        }
    }
    
    private func fetchData(completion: @escaping () -> ()) {
        TwitterService.shared?.getTweets(count: tweets.count + 20, completion: { result in
            completion()
            
            switch result {
            case .success(let tweets):
                self.tweets = tweets
                self.tableView.reloadData()
            case .failure:
                let alert = UIAlertController(title: "Uh oh!", message: "Failed to load tweets. Try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == tweets.count - 1) {
            fetchData() {}
        }
    }
}
