//
//  StorageManager.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 10.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import RealmSwift

let realm = try! Realm()  // точка входа в БД

class StorageManager {
    
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
