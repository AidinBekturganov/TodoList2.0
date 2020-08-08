//
//  TodoDetailTableViewController.swift
//  TodoList2.0
//
//  Created by User on 8/6/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

class TodoDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var remainderDateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminderSwithc: UISwitch!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var doneButtonBar: UIBarButtonItem!
    
    var toDoItem: ToDoItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        
        let tap = UIGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if toDoItem == nil {
            toDoItem = ToDoItem(name: "", date: Date().addingTimeInterval(24*60*60), notes: "", remainderSet: false, completed: false, notificationID: nil)
            titleTextField.becomeFirstResponder()
        }
        
        updateUserInterface()
        
    }
    
    func updateUserInterface() {
        titleTextField.text = toDoItem.name
        datePicker.date = toDoItem.date
        descriptionTextView.text = toDoItem.notes
        reminderSwithc.isOn = toDoItem.remainderSet
        remainderDateLabel.textColor = (reminderSwithc.isOn ? .black : .gray)
        remainderDateLabel.text = dateFormatter.string(from: toDoItem.date)
        enableDisableButton(text: titleTextField.text!)
    }
    
    func updateRemainderSwitch() {
        ViewController.isAuthorized { (authorized) in
            DispatchQueue.main.async {
                if !authorized && self.reminderSwithc.isOn {
                    self.reminderSwithc.isOn = false
                    
                    let alertController = UIAlertController(title: "User didn't allow notifications", message: "Go to the settings and let notifications to ToDoListApp", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                self.view.endEditing(true)
                self.remainderDateLabel.textColor = (self.reminderSwithc.isOn ? .black : .gray)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            
        }
        
    }
    
    func enableDisableButton(text: String) {
        if text.count > 0 {
            doneButtonBar.isEnabled = true
        } else {
            doneButtonBar.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toDoItem = ToDoItem(name: titleTextField.text!, date: datePicker.date, notes: descriptionTextView.text, remainderSet: reminderSwithc.isOn, completed: toDoItem.completed, notificationID: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func remainderSwitchChanged(_ sender: Any) {
        updateRemainderSwitch()
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        self.view.endEditing(true)
        remainderDateLabel.text = dateFormatter.string(from: (sender as AnyObject).date)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        enableDisableButton(text: sender.text!)
    }
}

extension TodoDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case IndexPath(row: 1, section: 1):
            return reminderSwithc.isOn ? datePicker.frame.height : 0
        case IndexPath(row: 0, section: 2):
            return 200
        default:
            return 44
        }
    }
}

extension TodoDetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
}
