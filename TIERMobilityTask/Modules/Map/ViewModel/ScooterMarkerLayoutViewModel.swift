//
//  ScooterMarkerLayoutViewModel.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 06/08/2022.
//

import Foundation



struct ScooterMarkerLayoutViewModel {
    
    let type: String?
    let id: String
    let batteryLevel: String
    let hasHelmetBox: String
    let lat: Double
    let lng: Double
    let maxSpeed: String
    let vehicleType: String
    
    
    init?(_ scooter: ScooterModel) {
        guard let id = scooter.id, let lat = scooter.attributes?.lat, let lng = scooter.attributes?.lng else {
            return nil
        }
        
        self.id = id
        self.type = scooter.type
        self.batteryLevel = "Battary Level: \(scooter.attributes?.batteryLevel ?? 0) %"
        self.hasHelmetBox = (scooter.attributes?.hasHelmetBox ?? false) ? "helmet Box is available" : "helmet Box is unavailable"
        self.lat = lat
        self.lng = lng
        self.maxSpeed = (scooter.attributes?.maxSpeed == nil) ? "Max Speed: - km/h" : "Max Speed: \(scooter.attributes?.maxSpeed ?? 0) km/h"
        self.vehicleType = scooter.attributes?.vehicleType ?? ""
    }
}
