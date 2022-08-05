//
//  ScooterModel.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 04/08/2022.
//

import Foundation



struct ScooterResponse: Codable {
    let data: [ScooterModel]?
}


struct ScooterModel: Codable {
    let type: String?
    let id: String?
    let attributes: Attribute?
    
    
    
    struct Attribute: Codable {
        let batteryLevel: Int?
        let hasHelmetBox: Bool?
        let lat: Double?
        let lng: Double?
        let maxSpeed: Int?
        let vehicleType: String?
    }
}

