//
//  TwitterService.swift
//  Twitter
//
//  Created by Dan on 1/3/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SafariServices

class TwitterService: BDBOAuth1SessionManager {    
    static let shared = TwitterService(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "uFTmFW66AAMEUwx3rZlZDMSCf", consumerSecret: "LtlxIoQpBvHcqjpSMIA9Gs2E9wCJbr7xkx9EpSdBYoNedaZUgh")
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    var controller: UIViewController?
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        TwitterService.shared?.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            self.loginSuccess?()
        }, failure: { (error: Error!) in
            self.loginFailure?(error)
        })
        controller?.dismiss(animated: true, completion: nil)
    }
    
    func signIn(controller: UIViewController, url: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        self.controller = controller
        TwitterService.shared?.deauthorize()
        TwitterService.shared?.fetchRequestToken(withPath: url, method: "GET", callbackURL: URL(string: "alamoTwitter://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)")!
            
            let svc = SFSafariViewController(url: url)
            controller.present(svc, animated: true, completion: nil)
        }, failure: { (error: Error!) -> Void in
            print("Error: \(error.localizedDescription)")
            self.loginFailure?(error)
        })
    }
    
    func signOut() {
        deauthorize()
        UserDefaults.standard.set(false, forKey: "userSignedIn")
    }
    
    func getTweets(count: Int, completion: @escaping (Result<[Tweet], Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let parameters = [
            "count": 20
        ]
        TwitterService.shared?.get(urlString, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            var tweets = [Tweet]()
            
            let tweetDictionary = response as! [NSDictionary]
            for tweet in tweetDictionary {
                let userDict: NSDictionary = tweet.value(forKey: "user") as! NSDictionary
                let userObject = User(name: userDict.value(forKey: "name") as! String, screen_name: userDict.value(forKey: "screen_name") as! String, profile_image_url_https: userDict.value(forKey: "profile_image_url_https") as! String)
                let tweetObject = Tweet(
                    id: tweet.value(forKey: "id") as! Int,
                    text: tweet.value(forKey: "text") as! String,
                    user: userObject,
                    retweet_count: tweet.value(forKey: "retweet_count") as! Int,
                    favorite_count: tweet.value(forKey: "favorite_count") as! Int,
                    favorited: tweet.value(forKey: "favorited") as! Bool,
                    retweeted: tweet.value(forKey: "retweeted") as! Bool
                )
                tweets.append(tweetObject)
            }
            
            completion(.success(tweets))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
    
    func getTweet(id: Int, completion: @escaping (Result<Tweet, Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/statuses/home_timeline/\(id).json"
        
        TwitterService.shared?.get(urlString, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweetDictionary = response as! NSDictionary
            let userDict: NSDictionary = tweetDictionary.value(forKey: "user") as! NSDictionary
            let userObject = User(name: userDict.value(forKey: "name") as! String, screen_name: userDict.value(forKey: "screen_name") as! String, profile_image_url_https: userDict.value(forKey: "profile_image_url_https") as! String)
            let tweetObject = Tweet(
                id: tweetDictionary.value(forKey: "id") as! Int,
                text: tweetDictionary.value(forKey: "text") as! String,
                user: userObject,
                retweet_count: tweetDictionary.value(forKey: "retweet_count") as! Int,
                favorite_count: tweetDictionary.value(forKey: "favorite_count") as! Int,
                favorited: tweetDictionary.value(forKey: "favorited") as! Bool,
                retweeted: tweetDictionary.value(forKey: "retweeted") as! Bool
            )
            
            completion(.success(tweetObject))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
    
    func favorite(id: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/favorites/create.json"
        
        let parameters = [
            "id": id
        ]
        
        TwitterService.shared?.post(urlString, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let responseDictionary = response as! NSDictionary
            completion(.success(true))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
    
    func unfavorite(id: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/favorites/destroy.json"
        
        let parameters = [
            "id": id
        ]
        
        TwitterService.shared?.post(urlString, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let responseDictionary = response as! NSDictionary
            
            completion(.success(false))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
    
    func retweet(id: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/statuses/retweet/\(id).json"
        
        TwitterService.shared?.post(urlString, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let responseDictionary = response as! NSDictionary
            
            completion(.success(true))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
    
    func unRetweet(id: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/statuses/unretweet/\(id).json"
        
        TwitterService.shared?.post(urlString, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let responseDictionary = response as! NSDictionary
            
            completion(.success(false))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
    
    func postTweet(content: String, completion: @escaping (Result<Void, Error>) -> ()) {
        let urlString = "https://api.twitter.com/1.1/statuses/update.json"
        let parameters = [
            "status": content
        ]
        
        TwitterService.shared?.post(urlString, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(.success(()))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            completion(.failure(error))
        })
    }
}
