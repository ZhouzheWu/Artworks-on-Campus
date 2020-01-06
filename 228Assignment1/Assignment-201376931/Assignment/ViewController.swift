//
//  ViewController.swift
//  Assignment
//
//  Created by 舟喆 吴 on 14/03/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import CoreData

var section = 1
var row = 1

class ViewController: UIViewController {

    @IBOutlet weak var inputTitle: UILabel!//link title label with viewController.Type is outlet
    
    @IBOutlet weak var Email: UIButton!//link email button with viewController.Type is outlet
    
    @IBOutlet weak var inputAuthor: UILabel!//link author label with viewController.Type is outlet
    
    @IBOutlet weak var inputField: UILabel!//link abstract label with viewController.Type is outlet
    
    @IBOutlet weak var emailText: UILabel! //link email address label with viewController.Type is outlet
    
    @IBOutlet weak var switchOn: UISwitch!//link switch with viewController.Type is outlet
    

   //  var context: NSManagedObjectContext?
    
    @IBAction func switchBtn(_ sender: Any) {//turn switch on/off action
         section = currentSection//acquire switched report
        row = currentRow
        
      }
    
//    @IBAction func switchBtn(_ sender: Any) {
//       let newUser = NSEntityDescription.insertNewObject(forEntityName: "Logins", into: context!)
//
//        do {
//            try context?.save()
//
//            print("Saved")
//
//
//        } catch {
//            print("there was an error")
//        }

    
    @IBAction func viewFullText(_ sender: Any) {
       
        let url = myReports[currentSection].1[currentRow].pdf
            UIApplication.shared.open(url!)//open url
            
        
    }
    
    @IBAction func emailBtn(_ sender: Any) {
        Email.isHidden = true//hide email button if it is clicked
        emailText.text = myReports[currentSection].1[currentRow].email ?? "Sorry, there is no email adress"
        //show email address if email button is clicked
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTitle.text = myReports[currentSection].1[currentRow].title//show title of checked report
       inputAuthor.text = myReports[currentSection].1[currentRow].authors//show author of checked report
     inputField.text = myReports[currentSection].1[currentRow].abstract ?? "No abstract"//show abstact of checked report. If this report don't have abstract, show "No abstact"
        if currentSection==section&&currentRow==row{
            switchOn.isOn = true//open switch if this report is saved as favourite
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
}

