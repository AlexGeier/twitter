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
    private var numberOfTweets = 0
    
    private let refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Twitter"
        let backButton = UIBarButtonItem(
            title: "Sign Out",
            style: .done,
            target: nil,
            action: nil
        )
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        tableView.register(TweetCell.self, forCellReuseIdentifier: cellId)
        
        fetchData() {}
        
        refreshControl = refreshController
    }
    
    @objc private func onRefresh() {
        fetchData {
            self.refreshController.endRefreshing()
        }
    }
    
    private func fetchData(completion: @escaping () -> ()) {
        let urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let parameters = [
            "count": 20
        ]
        
        TwitterService.shared?.getDictionariesRequest(url: urlString, parameters: parameters, success: { (tweets: [NSDictionary]) in
            self.tweets.removeAll()
            self.numberOfTweets = 20
            for tweet in tweets {
                let userDict: NSDictionary = tweet.value(forKey: "user") as! NSDictionary
                let userObject = User(name: userDict.value(forKey: "name") as! String, profile_image_url_https: userDict.value(forKey: "profile_image_url_https") as! String)
                let tweetObject = Tweet(text: tweet.value(forKey: "text") as! String, user: userObject)
                self.tweets.append(tweetObject)
            }
            self.tableView.reloadData()
            completion()
        }, failure: { (error: Error) in
            print("fetch tweets error")
            completion()
        })
    }
    
    private func fetchMoreData(completion: @escaping () -> ()) {
        numberOfTweets += 20

        let urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let parameters = [
            "count": numberOfTweets
        ]
        
        TwitterService.shared?.getDictionariesRequest(url: urlString, parameters: parameters, success: { (tweets: [NSDictionary]) in
            self.tweets.removeAll()
            for tweet in tweets {
                let userDict: NSDictionary = tweet.value(forKey: "user") as! NSDictionary
                let userObject = User(name: userDict.value(forKey: "name") as! String, profile_image_url_https: userDict.value(forKey: "profile_image_url_https") as! String)
                let tweetObject = Tweet(text: tweet.value(forKey: "text") as! String, user: userObject)
                self.tweets.append(tweetObject)
            }
            self.tableView.reloadData()
            completion()
        }, failure: { (error: Error) in
            print("fetch tweets error")
            completion()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            TwitterService.shared?.signOut()
        }
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
            fetchMoreData() {}
        }
    }
}
