//
//  PlaceModel.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 09.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var stringPlacesImage: String?
    
    
   static let plaсesNames = [
             "Бор", "река Ока", "река Угра", "Заповедник", "Калужские засеки", "Национальный парк Угра"
             ]
    
   static func getPlaces() -> [Place] {
       
    var places = [Place]()
    
        for place in plaсesNames {
            places.append(Place(name: place, location: "г. Калуга", type: "Лесной массив", image: nil, stringPlacesImage: place))
        }
        return places
    }
}
