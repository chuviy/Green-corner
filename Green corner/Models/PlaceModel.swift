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
   @objc dynamic var coordinates: String?
   @objc dynamic var imageData: Data?
   @objc dynamic var date = Date() // инициализируестя текущей датой для внутренего использования. Для сортировки по дате добавления.
   @objc dynamic var rating = 0.0
    
   /* вспомогательный инициализатор для всех св-тв класса */
    convenience init(name: String, location: String?, coordinates: String?, imageData: Data?, rating: Double) {
        self.init() // в вспомогательном инициализаторе вызываем инициализатор суперкласса
        self.name = name
        self.location = location
        self.coordinates = coordinates
        self.imageData = imageData
        self.rating = rating
        
    }
    
}
