//


//  ViewController.swift


//


//  Created by Zhouzhe Wu on 13/03/2019.

//

//


import UIKit
var myReports = [(String,[techReport])]() //create a new variable to store [year,[reports]] informations
var year = [String]()//create a new variable to store year information to create index list
var currentSection = 0 //set a global variable to transform current section to viewController
var currentRow = 0 //set a global variable to transform current row to viewController

struct techReport: Decodable {//struct a structure for techReport
    
    let year: String
    
    let id: String
    
    let owner: String?
    
    let email: String?
    
    let authors: String
    
    let title: String
    
    let abstract: String?
    
    let pdf: URL?
    
    let comment: String?
    
    let lastModified: String
    
}

class TableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    var storeReports = [techReport]()//create a variable to store reports that decoded
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        decodeData()//execute decodeData method
        
    }
    
    @IBOutlet var tableView: UITableView! //link table on storyboard with tableViewController
    
    func decodeData(){       //decode json data
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/techreports/data.php?class=techreports2") {
            
            let session = URLSession.shared
            
            session.dataTask(with: url) { (data, response, err) in
                
                guard let jsonData = data else {
                    
                    return
                    
                }
                
                do{
                    
                    
                    let decoder = JSONDecoder()
                    
                    let reportList = try decoder.decode(technicalReports.self, from: jsonData)
                    
                    self.storeReports = reportList.techreports2//storeReports acquire decoded data
                    
                    var count = 0
                    
                    for aReport in reportList.techreports2 {//loop
                        
                        count += 1
                        
                        print("\(count) " + aReport.title)
                        
                    }
                    
                    
                    for aReport in self.storeReports{//traverse each report in storeReport
                        
                        if(self.ArrayTraverse(a: myReports, b: aReport)>=0){//execute ArrayTraverse method, check if this year section existed
                            
                            myReports[self.ArrayTraverse(a: myReports, b: aReport)].1.append(aReport)//if this year section existed, append this report to corresponding section
                            
                        }else{// if not,
                            year.append(aReport.year)//append new year section to year array
                            var tmpArray=[techReport]()//create a temporary array that type is [techReport] to store this report
                            
                            tmpArray.append(aReport)
                            
                            let temp=(aReport.year,tmpArray)//add this report to another temporary array that type is [aReport.year,tmpArray]
                            
                            myReports.append(temp)//add this array to myReports
                            
                        }
                        
                    }
                    
                    myReports=myReports.sorted(by: { (s1:(String, [techReport]), s2:(String, [techReport])) -> Bool in//sort section
                        
                        return s1.0>s2.0
                        
                    })
                    year=year.sorted(by: { (s1:(String), s2:(String) )-> Bool in//sort year section
                        
                        return s1>s2
                        
                    })
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()//reload data
                        
                    }
                    
                } catch let jsonErr {
                    
                    print("Error decoding JSON", jsonErr)
                    
                    
                }
                
                }.resume()
            
        }
        
    }
    
    func ArrayTraverse(a:[(String,[techReport])],b:techReport)->Int{//a method to traverse reports
        
        var count=0//create a varible to calculate the position of year section
        
        for item in a {
            
            if(item.0==b.year){//check if this year section exists
                
                return count
                
            }
            
            
            count = count+1//Check one more time, count add 1
            
        }
        
        return -1//if there are no year section can be matched,return -1
        
        
    }
    
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 20//set height
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return myReports.count//  return the number of sections
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myReports[section].1.count//return the nuber of rows
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell=UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")//set subtitle
        
        cell.textLabel?.text=myReports[indexPath.section].1[indexPath.row].title//show title on table
        
        cell.detailTextLabel?.text=myReports[indexPath.section].1[indexPath.row].authors//show subtitble on table
        
        if section==currentSection&&row==currentRow{
            
            cell.accessoryType = .checkmark//checkmark if this report is saved as favourite
            
        }
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentSection = indexPath.section
        currentRow = indexPath.row
        performSegue(withIdentifier: "to aReport", sender: nil)//link table page with aRepot page
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?//set section ui
        
    {
        
        let view = UIView()
        
        view.backgroundColor=UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        
        let viewLabel=UILabel(frame: CGRect(x:20,y:10,width:UIScreen.main.bounds.size.width,height:14))
        
        viewLabel.text=myReports[section].0
        
        view.addSubview(viewLabel)
        
        return view
        
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return year
        
    }
    
    struct technicalReports: Decodable {
        
        let techreports2: [techReport]
        
    }
}
