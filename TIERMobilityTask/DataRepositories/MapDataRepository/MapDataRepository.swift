//
//  MapDataRepository.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 04/08/2022.
//

import Foundation



protocol MapDataRepositoryProtocol {
    func getNearScooters( completion: @escaping (Result<[ScooterModel], Errortypes>) -> Void)
    
}


class MapDataRepository: MapDataRepositoryProtocol {
    
    let service = MapService()
    func getNearScooters(completion: @escaping (Result<[ScooterModel], Errortypes>) -> Void) {
        service.getNearScooters { result in
            completion(result)
        }
    }
    
    
}
