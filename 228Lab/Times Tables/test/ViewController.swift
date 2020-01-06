//
//  ViewController.swift
//  Time table
//
//  Created by 舟喆 吴 on 28/02/2019.
//  Copyright © 2019 舟喆 吴. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource{
   
    
    
    
    @IBOutlet weak var mySlider: UISlider!
 
  
    @IBOutlet weak var myTableView: UITableView!
    var tableViewLines = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mySlider.value != 0{
            tableViewLines = 20
        }
        return tableViewLines
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = myTableView.dequeueReusableCell(withIdentifier: "prototype1", for: indexPath)
        if mySlider.value != 0{
            myCell.textLabel?.text = "\(Int(mySlider.value)) * \(indexPath.row+1) = \( Int(mySlider.value)*(indexPath.row + 1))"}
        return myCell
    }
    
    
    @IBAction func moveSlider(_ sender: Any) {
        let sliderValue = Int(mySlider.value)
        
        //print(sliderValue)
        myTableView.reloadData()
        valueShow.text = String(sliderValue)
    }
    
    
    @IBOutlet weak var valueShow: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
}
