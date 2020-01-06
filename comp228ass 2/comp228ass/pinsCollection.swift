//
//  pinsCollection.swift
//  comp228ass
//
//  Created by 舟喆 吴 on 07/05/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class pinsCollection: NSObject,MKAnnotation{
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let location: String
    let subtitle: String?
    var artworks = [artworkOne]()
    
    init( location: String, coordinate: CLLocationCoordinate2D, artworks: [artworkOne]) {
        
        self.title = location
        self.location = location
        self.coordinate = coordinate
        self.subtitle = "Click here to glance over artworks inside"
        self.artworks = artworks
        super.init()
    }
}
