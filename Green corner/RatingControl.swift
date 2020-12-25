//
//  RatingControl.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 25.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

class RatingControl: UIStackView {

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Private Methods
    private func setupButtons() {
        
        // Create the button
        let button = UIButton()
        button.backgroundColor = .red
        
        // Add constraints
        button.translatesAutoresizingMaskIntoConstraints = false // отключает авто сгенерированные constraints для button
        button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        // Add the button to the stack
        addArrangedSubview(button)
        
    }
}
