//
//  PlaceModel.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 09.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import RealmSwift

class Place: Object {
    
   @objc dynamic var name = ""
   @objc dynamic var location: String?
   @objc dynamic var type: String?
   @objc dynamic var imageData: Data?
    
    
    let plaсesNames = [
             "Бор", "река Ока", "река Угра", "Заповедник", "Калужские засеки", "Национальный парк Угра"
             ]
    
    func savePlaces() {
           
        for place in plaсesNames {
            
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else { return } // конвертируем изображение в Data
            
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "г. Калуга"
            newPlace.type = "Лесной массив"
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
        }
    }
    
}
