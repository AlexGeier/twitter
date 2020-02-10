//
//  Tweet.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation

struct Tweet: Decodable {
    let text: String
    let user: User
}

struct User: Decodable {
    let name: String
    let profile_image_url_https: String
}
