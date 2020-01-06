//
//  detailsViewController.swift
//  comp228ass
//
//  Created by 舟喆 吴 on 07/05/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import CoreData

class detailsViewController: UIViewController {
    
    
    // declare variables and constants for core data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artworks")
    var results: [Any]?
    var imageID: String?
    

    
    @IBOutlet weak var titleName: UILabel!
    
    @IBOutlet weak var imagePlace: UIImageView!
    
    
    @IBOutlet weak var artistName: UILabel!
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var yearInfo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = appDelegate.persistentContainer.viewContext
        
        // compare given id with is in coredata and fetch
        let predicate = NSPredicate(format: "id == %@", imageID!)
        self.request.predicate = predicate
        var image: UIImage?
        do {
            let results = try self.context!.fetch(self.request)
            
            if results.count > 0 {
                //display some infos of artworks
                titleName.text? = (results[0] as! NSManagedObject).value(forKey: "title") as! String
                yearInfo.text? = (results[0] as! NSManagedObject).value(forKey: "yearOfWork") as! String
                artistName.text? = (results[0] as! NSManagedObject).value(forKey: "artist") as! String
                infoLabel.text? = (results[0] as! NSManagedObject).value(forKey: "information") as! String
                
               
                let imageData = (results[0] as AnyObject).value(forKey: "image") as! NSData
                image = (UIImage(data: imageData as Data)!)
               
                    imagePlace.image = image!
                    
                
            }
        } catch {
            print("error")
        }
        // Do any additional setup after loading the view.

        
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
