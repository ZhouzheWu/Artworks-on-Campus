//
//  PlacesViewController.swift
//  lab6
//
//  Created by 舟喆 吴 on 11/03/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import CoreData


var places = [Dictionary<String, String>()]
var currentPlace = -1

class PlacesViewController: UITableViewController {
    // Core Data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    var placesList = [NSManagedObject]()            // Array of NSManagedObjects
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Retrieve list of places from core data (if data exists)
        context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "name", ascending: true))
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context?.fetch(fetchRequest)
            if(results?.count)! > 0 {
                for i in 0..<(results?.count)! {            // For each result retrieved
                    let result = results?[i] as! Places
                    
                    // Get the values for this place
                    let placeTitle = result.name ?? "title"
                    let placeLat = result.lat ?? "latitude"
                    let placeLon = result.long ?? "longitude"
                    
                    // Add the place to data stored (list of places and list of NSManagedObjects)
                    let newPlace = ["name": placeTitle, "lat": placeLat, "lon": placeLon]
                    places.append(newPlace)
                    placesList.append(result)
                }
            } else {
                print("No results")                        // No results in core data
            }
        } catch {
            print("Couldn't fetch results")                // Error retrieving results from core data
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        //cell.textLabel?.text = "Row \(indexPath.row)"
        if places[indexPath.row]["name"] != nil {
            cell.textLabel?.text = places[indexPath.row]["name"]
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentPlace = indexPath.row
        performSegue(withIdentifier: "to Map", sender: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if places.count == 1 && places[0].count == 0 {        // If no elements in the 'places' list
            places.remove(at: 0)
            // Add a default value
            places.append(["name":"Ashton Building", "lat": "53.406566", "lon": "-2.966531"])
            
            // Save to core data
            self.context = self.appDelegate.persistentContainer.viewContext
            let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: self.context!) as! Places
            newPlace.setValue("Ashton Building", forKey: "name")
            newPlace.setValue("53.406566", forKey: "lat")
            newPlace.setValue("-2.966531", forKey: "long")
            do {
                try self.context?.save()
                print("saving")
            } catch {
                print("error")
            }
        }
    
        currentPlace = -1                // No current place selected
        table.reloadData()        // Reload table data

    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
