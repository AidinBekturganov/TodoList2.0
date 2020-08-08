//
//  ToDoItem.swift
//  TodoList2.0
//
//  Created by User on 8/6/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var date: Date = Date().addingTimeInterval(24*60*60)
    @objc dynamic var notes: String = ""
    @objc dynamic var remainderSet: Bool = false
    @objc dynamic var completed: Bool = false
    @objc dynamic var notificationID: String? = nil
    
    
    convenience init(name: String, date: Date, notes: String, remainderSet: Bool, completed: Bool, notificationID: String?) {
        self.init()
        self.name = name
        self.date = date
        self.notes = notes
        self.remainderSet = remainderSet
        self.completed = completed
        self.notificationID = notificationID
    }
}
