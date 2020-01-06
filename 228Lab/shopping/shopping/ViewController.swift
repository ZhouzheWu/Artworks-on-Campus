//
//  ViewController.swift
//  shopping
//
//  Created by 舟喆 吴 on 01/05/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var shopTable: UITableView!
    
    
    @IBAction func clearList(_ sender: Any) {
        // Add alert to check user wants to complete this action
        let alert = UIAlertController(title: "Clear List", message: "Are you sure you want to delete all items in the list?", preferredStyle: .alert)
        // Add 'clear' option to alert - list is then deleted
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                self.itemsShop.removeAll();            // Remove all elements from list
                //self.deleteList()                // Method call (Clears todo list from core data)
                self.shopTable.reloadData()        // Reload table
            }}))
        // Add 'cancel' option to alert - list remains the same
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func deleteList(){
        context = appDelegate.persistentContainer.viewContext
        let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "shopList")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchRequest)
        do {
            try context?.execute(deleteRequest)            // Execute delete request
            try context!.save()                            // Save
        } catch {
            print("Oops! There was an error")
        }
       
        
    }
    
    var itemsShop = [String]();
    var todo_list = [NSManagedObject]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shopTable.dataSource = self
        
        //textField.clearButtonMode = .always  //一直显示清除按钮
        // textField.clearsOnBeginEditing = true;
        // Do any additional setup after loading the view, typically from a nib.
        
        context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ShopItem")
        
        request.predicate = NSPredicate(format: "shopList <> %@", "") //look for username=a string, where the string is not empty.
        
        request.sortDescriptors?.append(NSSortDescriptor(key: "shopList", ascending: true))
        
        request.returnsObjectsAsFaults = false
        
        
        do {
            let results = try context?.fetch(request)
            
            if (results?.count)! > 0 { //if there is one...
                for i in 0..<(results?.count)! {
                    let result = results?[i] as! ShopItem //was NSManagedObject
                    if let toBuy = result.shopList{
                        // old style Core Data access:
                        // if let theUsername = result.value(forKey: "username") as? String {
                        itemsShop.append(toBuy)
                        todo_list.append(result)
                    }
                }
            } else {
                print("No results")
                
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    
   
    @IBAction func addBtn(_ sender: Any) {
        
        guard let buyItem = textField.text else {return}        // To do item is value entered by user
        itemsShop.append(buyItem)                                    // Add to do item to list
        let newToDo = NSEntityDescription.insertNewObject(forEntityName: "ShopItem", into: context!) as! ShopItem
        newToDo.setValue(buyItem, forKey: "shopList")                // Save to do item to core data
        do {
            try context?.save()
            
            print("Saved")
           
            
        } catch {
            print("there was an error")
        }
        textField.resignFirstResponder()
        shopTable.reloadData();                            // Reload table data
    
     }
    // Function to determine number of rows for table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsShop.count        // Number of rows is number of items in list
    }
    
    // Function to return the cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "tableCell")
//        let item = itemsShop[indexPath.item]            // String to store 'to do item'
        let myCell = shopTable.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
         myCell.textLabel?.text = itemsShop[indexPath.row]               // Set text of cell to the 'to do item'
        return myCell                                    // Return the cell
    }
    
    


}


