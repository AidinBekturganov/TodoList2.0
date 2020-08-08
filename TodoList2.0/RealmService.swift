//
//  RealmService.swift
//  TodoList2.0
//
//  Created by User on 8/7/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    private init() {}
    static let shared = RealmService()
    var todoItems = TodoItems()
    var view = ViewController()
    
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
        
    }
    
    func upadate<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value ,forKey: key)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    
    
}
