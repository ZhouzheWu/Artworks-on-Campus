//
//  ViewController.swift
//  lab6
//
//  Created by 舟喆 吴 on 11/03/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    // Core Data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            print("===\nLong Press\n===")
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            print(newCoordinate)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark = placemarks?[0] {
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                        }
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare!
                        }
                    } }
                if title == "" {
                    title = "Added \(NSDate())"
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.map.addAnnotation(annotation)
                
                
                places.append(["name":title, "lat": String(newCoordinate.latitude), "lon":
                    String(newCoordinate.longitude)])
                
               
                
                // Save to core data
                self.context = self.appDelegate.persistentContainer.viewContext
                let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: self.context!) as! Places
                newPlace.setValue(title, forKey: "name")
                newPlace.setValue(String(newCoordinate.latitude), forKey: "lat")
                newPlace.setValue(String(newCoordinate.longitude), forKey: "long")
                do {
                    try self.context?.save()            // Save context
                    print("saved")
                } catch {
                    print("Error saving")
                }
            }) }
    }
    




@IBOutlet weak var map: MKMapView!


override func viewDidLoad() {
    super.viewDidLoad()
    guard currentPlace != -1 else { return }
    guard places.count > currentPlace else { return }
    guard let name = places[currentPlace]["name"] else { return }
    guard let lat = places[currentPlace]["lat"] else { return }; guard let lon = places[currentPlace]["lon"] else { return }
    guard let latitude = Double(lat) else { return }
    guard let longitude = Double(lon) else { return }
    let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    self.map.setRegion(region, animated: true)
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = name
    self.map.addAnnotation(annotation)
    print(currentPlace)
    // Do any additional setup after loading the view, typically from a nib.
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
    lpgr.minimumPressDuration = 2
    map.addGestureRecognizer(lpgr)
}
   


}

