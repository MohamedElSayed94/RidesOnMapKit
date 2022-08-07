//
//  MapViewModel.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 03/08/2022.
//

import Foundation
import CoreLocation

enum State {
    case loading(Bool)
    case recievedData([ScooterMarkerLayoutViewModel])
    case empty
    case error(Errortypes)
    
    
}

protocol MapViewModelProtocol {
    var currentState: ((State)->Void)? {get set}
    func getNearScooters()
    func getNearestPinFromUserLocation(pins: [ScooterMarker], currentLocation: CLLocation) -> ScooterMarker?
}

class MapViewModel: MapViewModelProtocol {
    
    var repository: MapDataRepositoryProtocol
    
    var currentState: ((State) -> Void)?
    
    init(repository: MapDataRepositoryProtocol = MapDataRepository()) {
        self.repository = repository
    }
    
    func getNearestPinFromUserLocation(pins: [ScooterMarker], currentLocation: CLLocation) -> ScooterMarker? {
        var nearestDistance = Int.max
        let nearestPin: ScooterMarker? = pins.reduce((CLLocationDistanceMax, nil)) { (nearest, pin) in
            let coord = pin.coordinate
            let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = currentLocation.distance(from: loc)
            if Int(distance) < nearestDistance {
                nearestDistance = Int(distance)
            }
            return distance < nearest.0 ? (distance, pin) : nearest
        }.1
        
        if nearestDistance > 20000 {
            return nil
        } else {
            return nearestPin
        }
    }
    
    func getNearScooters() {
        
        self.currentState?(.loading(true))
        repository.getNearScooters { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let scooters):
                    if scooters.isEmpty {
                        self.currentState?(.empty)
                    } else {
                        let layoutViewModel = scooters.compactMap { ScooterMarkerLayoutViewModel($0) }
                        self.currentState?(.recievedData(layoutViewModel))
                    }
                case .failure(let error):
                    self.currentState?(.error(error))
                    
                }
                
                self.currentState?(.loading(false))
            }
            
        }
        
    }
    
}
