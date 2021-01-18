//
//  RatingControl.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 25.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

/* @IBDesignable Позволяет отобразить контент наполенный в stackView в interfeceBuilder
 Любые изменения в коде будут отображатся в raealTime в interfeceBuilder */

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: Propetries
    
    var rating = 0 {
        didSet {
            updateButtunSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    
    // MARK: Private Methods
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button) // удаляем элементы массива(кнопки) из Subview
            button.removeFromSuperview() // удаляем кнопки из stackView
        }
        ratingButtons.removeAll() // перед заполнением (установка кол-ва новых кнопок через interfaceBuilder) массива кнопок очищаем его
        
        // Load button image
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle, compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle, compatibleWith: self.traitCollection)
        
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle, compatibleWith: self.traitCollection)
        
        
        for _ in 0..<starCount {
            
            // Create the button
            let button = UIButton()
           // button.backgroundColor = .red
            
            // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false // отключает авто сгенерированные constraints для button
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button on the rating button array
            ratingButtons.append(button)
        }
        
        updateButtunSelectionState()
        
    }
    
    private func updateButtunSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
