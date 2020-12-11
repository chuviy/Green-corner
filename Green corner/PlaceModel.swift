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
   @objc dynamic var date = Date()
   
   /* вспомогательный инициализатор для всех св-тв класса */
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        self.init() // в вспомогательном инициализаторе вызываем инициализатор суперкласса
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        
    }
    
}
