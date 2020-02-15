//
//  TweetCell.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import TinyConstraints
import SDWebImage

class TweetCell: UITableViewCell {
    var tweet: Tweet! {
        didSet {
            contentLabel.text = tweet.text
            userNameLabel.text = tweet.user.name
            screenNameLabel.text = "@\(tweet.user.screen_name)"
            profilePicture.sd_setImage(with: URL(string: tweet.user.profile_image_url_https), completed: nil)
            retweetCountLabel.text = String(tweet.retweet_count)
            favoriteCountLabel.text = String(tweet.favorite_count)
            if (tweet.favorited) {
                favoriteButton.setImage(UIImage(named: "favor-icon-red"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(named: "favor-icon"), for: .normal)
            }
            if (tweet.retweeted) {
                retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: .normal)
            } else {
                retweetButton.setImage(UIImage(named: "retweet-icon"), for: .normal)
            }
        }
    }
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    private let profilePicture: UIImageView = {
        let image = UIImageView()
        image.size(.init(width: 100, height: 100))
        image.layer.cornerRadius = 50
        image.clipsToBounds = true
        
        return image
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    private let screenNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    private let retweetButton: UIButton = {
        let button = Button(backgroundColor: .systemFill)
        
        return button
    }()
        
    private let retweetCountLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = Button(backgroundColor: .systemFill)
        
        return button
    }()
    
    private let favoriteCountLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    @objc private func toggleRetweet(_ sender: UIButton) {
        if (tweet.retweeted) {
            TwitterService.shared?.unRetweet(id: tweet.id, completion: { result in
                self.tweet.retweeted = false
                self.tweet.retweet_count -= 1
            })
        } else {
            TwitterService.shared?.retweet(id: tweet.id, completion: { result in
                self.tweet.retweeted = true
                self.tweet.retweet_count += 1
            })
        }
    }
    
    @objc private func toggleFavorite(_ sender: UIButton) {
        if (tweet.favorited) {
            TwitterService.shared?.unfavorite(id: tweet.id, completion: { result in
                self.tweet.favorite_count -= 1
                self.tweet.favorited = false
            })
        } else {
            TwitterService.shared?.favorite(id: tweet.id, completion: { result in
                self.tweet.favorite_count += 1
                self.tweet.favorited = true
            })
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        
        retweetButton.addTarget(self, action: #selector(toggleRetweet(_:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite(_:)), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let actionsButtonHorizontalStackView = UIStackView(arrangedSubviews: [
            retweetButton,
            retweetCountLabel,
            favoriteButton,
            favoriteCountLabel,
            UIView()
        ])
        actionsButtonHorizontalStackView.spacing = 8
        
        let userNameHorizontalStackView = UIStackView(arrangedSubviews: [
            userNameLabel,
            screenNameLabel
        ])
        
        let contentVerticalStackView = UIStackView(arrangedSubviews: [
            userNameHorizontalStackView,
            contentLabel,
            UIView()
        ])
        contentVerticalStackView.alignment = .fill
        contentVerticalStackView.axis = .vertical
        
        let mainVerticalStackView = UIStackView(arrangedSubviews: [
            contentVerticalStackView,
            actionsButtonHorizontalStackView
        ])
        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.alignment = .fill
        
        let profilePictureVerticalStackView = UIStackView(arrangedSubviews: [
            profilePicture,
            UIView()
        ])
        profilePictureVerticalStackView.axis = .vertical
        
        let mainHorizontalStackView = UIStackView(arrangedSubviews: [
            profilePictureVerticalStackView,
            mainVerticalStackView,
        ])
        mainHorizontalStackView.spacing = 8
        
        addSubview(mainHorizontalStackView)
        mainHorizontalStackView.edgesToSuperview(insets: .init(top: 8, left: 16, bottom: 8, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
