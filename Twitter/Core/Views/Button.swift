//
//  Button.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class Button: UIButton {
    var _backgroundColor: UIColor
    
    init(backgroundColor: UIColor) {
        _backgroundColor = backgroundColor
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? _backgroundColor.withAlphaComponent(0.8) : _backgroundColor
        }
    }
}
