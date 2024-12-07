//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Sharandeep Singh on 21/11/24.
//

import UIKit

class ToDoTableViewController: UITableViewController {

    //MARK: - Properties
    var toDoList: [ToDoModel] = []
    let defaults = UserDefaults.standard
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Code to print path for user defaults file
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last)

        if let list = defaults.object(forKey: "ToDoList") as? Data {
            let decodedData = decodeData(using: list)
            
            if let data = decodedData {
                toDoList = data
            }
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 211/255, green: 57/255, blue: 81/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: - TableView DataSource and Delegate Overriden Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        
        cell.textLabel?.text = toDoList[indexPath.row].toDo
        cell.accessoryType = toDoList[indexPath.row].isChecked ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedCell = tableView.cellForRow(at: indexPath)
        
        if tappedCell?.accessoryType == .checkmark {
            tappedCell?.accessoryType = .none
            toDoList[indexPath.row].isChecked = false
        } else {
            tappedCell?.accessoryType = .checkmark
            toDoList[indexPath.row].isChecked = true
        }
        
        let encodedData = encodeData(using: toDoList)
        
        self.defaults.set(encodedData, forKey: "ToDoList")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - IBOutlets
    @IBAction func addNewToDoButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Enter ToDo", message: nil, preferredStyle: .alert)
        
        alert.addTextField { localTextField in
            localTextField.placeholder = "Enter Task..."
            textField = localTextField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            let toDo = ToDoModel(toDo: textField.text ?? "", isChecked: false)
            self.toDoList.append(toDo)
            let encodedData = encodeData(using: self.toDoList)
            self.defaults.set(encodedData, forKey: "ToDoList")
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}


//MARK: - Encoder and decoder
private func encodeData(using data: [ToDoModel]) -> Data? {
    let encoder = PropertyListEncoder()
    
    do {
        let encodedData = try encoder.encode(data)
        return encodedData
    } catch {
        print("Encountered error while encoding data reason: \(error.localizedDescription)")
        return nil
    }
}

private func decodeData(using data: Data?) -> [ToDoModel]? {
    let decoder = PropertyListDecoder()
    
    do {
        if let d = data {
            let decodedData = try decoder.decode([ToDoModel].self, from: d)
            return decodedData
        }
    } catch {
        print("Encountered error while decoding data reason: \(error.localizedDescription)")
        return nil
    }
    return nil
}

