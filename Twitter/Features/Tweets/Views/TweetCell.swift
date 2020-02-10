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
            userLabel.text = tweet.user.name
            profilePicture.sd_setImage(with: URL(string: tweet.user.profile_image_url_https), completed: nil)
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
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    private func setupLayout() {
        let verticalStackView = UIStackView(arrangedSubviews: [
            userLabel,
            contentLabel
        ])
        verticalStackView.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [
            profilePicture,
            verticalStackView
        ])
        stackView.alignment = .top
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
