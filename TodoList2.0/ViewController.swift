//
//  ViewController.swift
//  TodoList2.0
//
//  Created by User on 8/6/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift


class ViewController: UIViewController {
    
    var todoItems = TodoItems()
    var toDoItem: ToDoItem!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var notificationToken: NotificationToken?
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = RealmService.shared.realm
        todoItems.itemsArray = realm.objects(ToDoItem.self)
        tableView.delegate = self
        tableView.dataSource = self
        autherizeNotifications()
        
        realm.observe { (notification, realm) in
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken?.invalidate()
    }
    
    func saveNotification() {
        guard todoItems.itemsArray.count > 0 else {
            return
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for index in 0..<todoItems.itemsArray.count {
            if todoItems.itemsArray[index].remainderSet {
                let todoItem = todoItems.itemsArray[index]
                
                let notificationID = setCalendarNotification(title: todoItem.name, subtitle: "", body: todoItem.notes, badgeNumber: nil, sound: .default, date: todoItem.date)
                let dict: [String: Any?] = ["name": todoItem.name,
                                            "date": todoItem.date,
                                            "completed": todoItem.completed,
                                            "notes": todoItem.notes,
                                            "remainderSet": todoItem.remainderSet,
                                            "notificationID": notificationID]
                RealmService.shared.upadate(todoItem, with: dict)
                
            }
        }
    }
    
    func autherizeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard error == nil else {
                return
            }
            if granted {
                print("Notifications are granted")
            } else {
                print("Notificatons are denied")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "User didn't allow notifications", message: "Go to the settings and let notifications to ToDoListApp", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    static func isAuthorized(completed: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard error == nil else {
                completed(false)
                return
            }
            if granted {
                print("Notifications are granted")
                completed(true)
            } else {
                print("Notificatons are denied")
                completed(false)
            }
        }
    }
    
    func setCalendarNotification(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound?, date: Date) -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = badgeNumber
        content.sound = sound
        content.subtitle = subtitle
        
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let notificationID = UUID().uuidString
        
        
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("GOT IT, and put notification: \(notificationID), title: \(content.title)")
            }
        }
        return notificationID
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! TodoDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = todoItems.itemsArray[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! TodoDetailTableViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let item = todoItems.itemsArray[selectedIndexPath.row]
            let dict: [String: Any?] = ["name": source.toDoItem.name,
                                        "date": source.toDoItem.date,
                                        "completed": source.toDoItem.completed,
                                        "notes": source.toDoItem.notes,
                                        "remainderSet": source.toDoItem.remainderSet]
            RealmService.shared.upadate(item, with: dict)
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: todoItems.itemsArray.count, section: 0)
            let notificationID = setCalendarNotification(title: source.toDoItem.name, subtitle: "", body: source.toDoItem.notes, badgeNumber: nil, sound: .default, date: source.toDoItem.date)
            let newItem = ToDoItem(name: source.toDoItem.name, date: source.toDoItem.date, notes: source.toDoItem.notes, remainderSet: source.toDoItem.remainderSet, completed: source.toDoItem.completed, notificationID: notificationID)
            RealmService.shared.create(newItem)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        saveNotification()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, ListTableViewCellDelegate {
    func checkBoxToggle(sender: ListTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            let item = todoItems.itemsArray[selectedIndexPath.row]
            let completed = !item.completed
            let dict: [String: Any?] = ["name": item.name,
                                        "date": item.date,
                                        "completed": completed,
                                        "notes": item.notes,
                                        "remainderSet": item.remainderSet,
                                        "notificationID": item.notificationID]
            RealmService.shared.upadate(item, with: dict)
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        cell.delegate = self
        cell.toDoItem = todoItems.itemsArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = todoItems.itemsArray[indexPath.row]
            RealmService.shared.delete(item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveNotification()
        }
    }
}
