//
//  Tweet.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation

struct Tweet: Decodable {
    let id: Int
    let text: String
    let user: User
    var retweet_count: Int
    var favorite_count: Int
    var favorited: Bool
    var retweeted: Bool
}

struct User: Decodable {
    let name: String
    let screen_name: String
    let profile_image_url_https: String
}
