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
    
    init?(scooter: ScooterModel) {
        
        guard let vehicleType = scooter.attributes?.vehicleType, let lat = scooter.attributes?.lat, let lng = scooter.attributes?.lng, let batteryLevel = scooter.attributes?.batteryLevel, let maxSpeed = scooter.attributes?.maxSpeed else {
            return nil
        }
        self.title = vehicleType
        self.subTitle = "Battary: \(batteryLevel) %, Max Speed: \(maxSpeed)"
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        super.init()
    }
    var subtitle: String? {
        return subTitle
      }
}
class UserMarker: NSObject, MKAnnotation {
    let title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(lat: Double, lng: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.title = "My Location"
        super.init()
    }
    let image = #imageLiteral(resourceName: "currentLocationPin")
}
//class UserLocationMarkerView: MKMarkerAnnotationView {
//    
//    override var annotation: MKAnnotation? {
//      willSet {
//        guard let userMarker = newValue as? UserMarker else {
//          return
//        }
//        canShowCallout = false
//        image = userMarker.image
//      }
//    }
//}
