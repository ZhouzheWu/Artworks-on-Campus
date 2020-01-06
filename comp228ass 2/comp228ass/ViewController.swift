//
//  ViewController.swift
//  COMP228ASS2
//
//  Created by 舟喆 吴 on 07/05/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Foundation
//build unit artwork stucture
struct artworkOne: Decodable {
    let id: String
    let title: String
    let artist: String
    let yearOfWork: String
    let Information: String
    let lat: String
    let long: String
    let location: String
    let locationNotes: String
    let fileName: String
    let lastModified: String
    let enabled: String
}
//build to decode
struct artworksAll: Decodable {
    let campus_artworks: [artworkOne]?
}



// Main page of app
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate{
    
    var sections = [(heading: String, artworks: [artworkOne])]() // an array used to implement table headings
    
    var searchResults = [String]() // an array contains search results
    
    var retrieve = false//initialize retrieve is false at beginning
    
    var artworkNames = [String]() // an array to store names of artworks
    
    var pins = [pinsCollection]() // an array to store map pins
    
    var pinsLoc: String?//pin to check
    
    var pinsNo: String?//special id for pins
    
    // coredata variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artworks")
    var results: [Any]?
    
    var artworkArray = [artworkOne]()
    var orderArtworks = [artworkOne]()
    var locationManager = CLLocationManager() //manage user's location
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var searchTool: UISearchBar!
    
    @IBOutlet weak var myTable: UITableView!
    
    var pin: MKAnnotation?
    
    // calculate and sort buildings by distance
    var buildings = [(location: String, coordinate: CLLocationCoordinate2D)]()
    var buildLocInfo = [(location: String, distance: Double)]()
    var orderLoc = [(location: String, distance: Double)]()
    
    var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        context = appDelegate.persistentContainer.viewContext
        
        // ask user to allow location info to be used
        locationManager.delegate = self as CLLocationManagerDelegate //we want messages about location
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization() //ask the user for permission to get their location
        locationManager.startUpdatingLocation() //and start receiving those messages (if we’re allowed to)
        
        let urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campus_artworks&lastUpdate=2017-11-01"
        guard let url = URL(string: urlString) else {return}
        
        //  decode url to artworks task created
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    do {
                        // use json decoder to get data
                        let data = Data(urlContent)
                        let decoder = JSONDecoder()
                        let artworkList = try decoder.decode(artworksAll.self, from: data)
                        self.artworkArray = artworkList.campus_artworks!
                        for artwork in self.artworkArray {
                            let id = artwork.id
                            let predicate = NSPredicate(format: "id == %@", id)
                            self.request.predicate = predicate
                            do {
                                let results = try self.context!.fetch(self.request)
                                
                                if results.count == 0 {
                                    let imageString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/" + artwork.fileName.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                                    // create background task with the url and download the image at the url.
                                    let url = URL(string: imageString)
                                    let session = URLSession(configuration: .default)
                                    let task = session.dataTask(with: url!) {
                                        (data, response, error) in
                                        if error != nil {
                                            print(error!)
                                        } else {
                                            if (response as? HTTPURLResponse) != nil {
                                                if let imageData = data {
                                                    let image = NSData(data: imageData)
                                                    DispatchQueue.main.async {
                                                        // wait for image to download then save image and artwork info to core data
                                                        let coreArtwork = NSEntityDescription.insertNewObject(forEntityName: "Artworks", into: self.context!) as! Artworks
                                                        coreArtwork.setValue(artwork.id, forKey: "id")
                                                        coreArtwork.setValue(image, forKey: "image")
                                                        coreArtwork.setValue(artwork.title, forKey: "title")
                                                        coreArtwork.setValue(artwork.artist, forKey: "artist")
                                                        coreArtwork.setValue(artwork.yearOfWork, forKey: "yearOfWork")
                                                        coreArtwork.setValue(artwork.Information, forKey: "information")
                                                        coreArtwork.setValue(artwork.lat, forKey: "lat")
                                                        coreArtwork.setValue(artwork.long, forKey: "long")
                                                        coreArtwork.setValue(artwork.location, forKey: "location")
                                                        coreArtwork.setValue(artwork.locationNotes, forKey: "locationNotes")
                                                        coreArtwork.setValue(artwork.fileName, forKey: "fileName")
                                                        coreArtwork.setValue(artwork.lastModified, forKey: "lastModified")
                                                        coreArtwork.setValue(artwork.enabled, forKey: "enabled")
                                                        do {
                                                            try self.context?.save()
                                                            print("saved")
                                                        } catch {
                                                            print("error")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    task.resume()
                                }
                            } catch {
                                print("error")
                            }
                        }
                        
                        // sort artworks in alphabetic order according to location
                        self.orderArtworks = self.artworkArray.sorted {
                            return $1.location > $1.location
                        }
                        
                        self.sortArtworks()
                        
                    } catch let jsonErr {
                        print("error", jsonErr)
                    }
                }
            }
        }
        task.resume()
        
        
    }
    
    // returns the number of sections, if retrieve is true, return 1
    func numberOfSections(in tableView: UITableView) -> Int {
        if retrieve {
            return 1
        } else {
            return sections.count
        }
    }
    
    // returns name of each section, if retrieve is true, set the name "Artworks"
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if retrieve {
            return "Artworks"
        } else {
            return orderLoc[section].location
        }
    }
    
    //returns the number of rows in a section, if retrieve is true, return the number of restults
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if retrieve {
            return searchResults.count
        } else {
            return sections[section].artworks.count
        }
    }
    
    // let artwork and artist show in cell in order
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        if retrieve {
            cell.textLabel?.text = searchResults[indexPath.row]
        } else {
            cell.textLabel?.text = sections[indexPath.section].artworks[indexPath.row].title
            cell.detailTextLabel?.text = sections[indexPath.section].artworks[indexPath.row].artist
        }
        return cell
    }
    
    // if cell is clicked, jumped into Details page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the title of the tapped cell and use this to search core data for that piece of art
        let selectedCell = myTable.cellForRow(at: indexPath)
        let title = selectedCell?.textLabel?.text
        let predicate = NSPredicate(format: "title == %@", title!)
        self.request.predicate = predicate
        do {
            
            results = try self.context!.fetch(self.request)
            
            for result in results as! [NSManagedObject] {
                pinsNo = (result.value(forKey: "id") as! String)
                performSegue(withIdentifier: "to Details", sender: self)
            }
            
            
        } catch {
            print("error")
        }
    }
    
    
    // if cancel button is clicked, do below
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTool.text = ""
        retrieve = false
        self.searchTool.resignFirstResponder()
        myTable.reloadData()
    }
    
    // manage text in search field
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // if no text then end searching
        if searchTool.text == "" {
            retrieve = false
        } else {
            // if text changed to not empty filter the titles of the artworks to see if they have a prefix matching the searched term
            retrieve = true
            let searchText = searchTool.text
            searchResults = artworkNames.filter({$0.hasPrefix(searchText!)})
        }
        myTable.reloadData()
    }
    
    // create pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Artwork"
        
        // use artwork annotation class and search for an image related to the building the annotation is of
        // use the first result as the image for the annotation
        if annotation is pinsCollection {
            
            // make the annotation a marker
            // (could be a pin with MKPinAnnotationView, I thought marker looked better as you could see the location name below)
            let annotationView = MKMarkerAnnotationView(annotation:annotation, reuseIdentifier: identifier)
            annotationView.isEnabled = true
            annotationView.canShowCallout = true // allow marker to show more info when tapped
            
            // add i button on the right of the callout
            let i = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = i
            annotationView.glyphText = "🥰"
            annotationView.markerTintColor = UIColor.white
            
            return annotationView
        }
        
        return nil
    }
    
    // if pin is clicked, do below actions
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        // search core data for the location. If there is a single result then go to the info screen, if not go to the table.
        guard let pin = view.annotation as? pinsCollection else {return}
        pinsLoc = pin.location
        let predicate = NSPredicate(format: "location == %@", pinsLoc!)
        self.request.predicate = predicate
        do {
            results = try self.context!.fetch(self.request)
            
            for result in results as! [NSManagedObject] {
                pinsNo = (result.value(forKey: "id") as! String)
                performSegue(withIdentifier: "to Details", sender: self)
            }
            
        } catch {
            print("error")
        }
    }
    
    // segues after transfer variables
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailsViewController = segue.destination as! detailsViewController
        detailsViewController.imageID = pinsNo
        
        
    }
    
    // get user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationOfUser = locations[0] // this didnt work
        // get latitude and longitude of user
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        userLocation = CLLocation(latitude: latitude, longitude: longitude)
        // set visible size
        let latDelta: CLLocationDegrees = 0.001
        let lonDelta: CLLocationDegrees = 0.001
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // set centre and visible area
        let region = MKCoordinateRegion(center: location, span: span)
        self.myMap.setRegion(region, animated: true)
        //create annotation for user location
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = "Current Location"
        self.myMap.addAnnotation(pin)
        
        
    }
    //function to sort artworks
    func sortArtworks(){
        // wait for background task to finish
        DispatchQueue.main.async {
            var artworksLoc = [artworkOne]()
            var previousLocation = "non"
            // create array of unique locations and artwork annotations
            for i in 0 ..< self.orderArtworks.count {
                if self.orderArtworks[i].location != previousLocation {
                    if i != 0 {
                        guard let latitude = Double(self.orderArtworks[i-1].lat) else { return }
                        guard let longitude = Double(self.orderArtworks[i-1].long) else { return }
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let artworkAnnotation = pinsCollection(location: self.orderArtworks[i-1].location, coordinate: coordinate, artworks: artworksLoc)
                        self.buildings.append((location: self.orderArtworks[i-1].location, coordinate: coordinate))
                        self.pins.append(artworkAnnotation)
                    }
                    artworksLoc = []
                    
                    artworksLoc.append(self.orderArtworks[i])
                    previousLocation = self.orderArtworks[i].location
                } else {
                    artworksLoc.append(self.orderArtworks[i])
                }
            }
            guard let latitude = Double(self.orderArtworks[self.orderArtworks.count-1].lat) else { return }
            guard let longitude = Double(self.orderArtworks[self.orderArtworks.count-1].long) else { return }
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let artworkPin = pinsCollection(location: self.orderArtworks[self.orderArtworks.count-1].location, coordinate: coordinate, artworks: artworksLoc)
            self.buildings.append((location: self.orderArtworks[self.orderArtworks.count-1].location, coordinate: coordinate))
            self.pins.append(artworkPin)
            self.myMap.addAnnotations(self.pins)
            
            self.calDistance()
            
            
            // add all names of artworks to an array to retrieve later
            for artwork in self.artworkArray {
                self.artworkNames.append(artwork.title)
            }
            
        }
    }
    
    //function to calculate distance
    func calDistance(){
        
        // calculate the distances of the locations from the user
        for location in self.buildings {
            let coordinates = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            let distance = coordinates.distance(from: self.userLocation!)
            self.buildLocInfo.append((location: location.location, distance: distance))
        }
        
        // sort the distances of the locations from the user
        self.orderLoc = self.buildLocInfo.sorted {
            return $0.distance < $1.distance
        }
        
        // create a dictionary containing locations and an array of corresponding artworks
        // this is in order of distance from the user as they have already been sorted
        for location in self.orderLoc {
            var store = [artworkOne]()
            for artwork in self.artworkArray {
                if artwork.location == location.location {
                    store.append(artwork)
                }
            }
            self.sections.append((heading: location.location, artworks: store))
        }
        
        self.myTable.reloadData()
    }
    
    
}



