//
//  ScooterMarker.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 04/08/2022.
//

import Foundation
import MapKit



class ScooterMarker: NSObject, MKAnnotation {
    let title: String?
    let subTitle: String?
    let coordinate: CLLocationCoordinate2D
    let scooterlayoutVM: ScooterMarkerLayoutViewModel
    init?(scooter: ScooterMarkerLayoutViewModel) {
        
        guard let lat = scooter.lat, let lng = scooter.lng else {
            return nil
        }
        self.title = scooter.vehicleType
        self.subTitle = "\(scooter.batteryLevel), \(scooter.maxSpeed)"
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.scooterlayoutVM = scooter
        super.init()
    }
    var subtitle: String? {
        return subTitle
      }
}

