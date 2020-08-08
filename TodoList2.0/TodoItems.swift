//
//  TodoItems.swift
//  TodoList2.0
//
//  Created by User on 8/7/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItems: Object {
    var itemsArray: Results<ToDoItem>!
}
