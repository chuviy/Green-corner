//
//  CustomTableViewCell.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 09.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var imageOfPlace: UIImageView! {
        didSet {
            /* 85/2 делаем круг из imageView. т.к. высота изображения = высоте строки, угол радиуса изображения = половине высоты изображения (квадрата) */
            imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.height / 2
            // обрезаем изображение по границам imageView.
            imageOfPlace?.clipsToBounds = true
        }
    }
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    

}
