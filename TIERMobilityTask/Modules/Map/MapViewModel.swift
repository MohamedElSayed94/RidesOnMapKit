//
//  MapViewModel.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 03/08/2022.
//

import Foundation

enum State {
    case loading(Bool)
    case recievedData([ScooterModel])
    case empty
    case error(Errortypes)
}

protocol MapViewModelProtocol {
    var onLoading: ((_ isLoading: Bool) -> Void)? { get set }
    var onEmptyState: (() -> Void)? { get set }
    var onError: ((Errortypes) -> Void)? {get set }
    var onRecieveData: (([ScooterModel]) -> Void)? { get set }
    var currentState: ((State)->Void)? {get set}
    func getNearScooters()
}

class MapViewModel: MapViewModelProtocol {
    var onRecieveData: (([ScooterModel]) -> Void)?

    var onLoading: ((Bool) -> Void)?
    var onEmptyState: (() -> Void)?
    var onError: ((Errortypes) -> Void)?
    
    var repository: MapDataRepositoryProtocol
    
    var currentState: ((State) -> Void)?
    
    init(repository: MapDataRepositoryProtocol = MapDataRepository()) {
        self.repository = repository
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
                        self.currentState?(.recievedData(scooters))
                    }
                    
                    
                case .failure(let error):
                    self.currentState?(.error(error))
                    
                }
                
                self.currentState?(.loading(false))
            }
            
        }
        
    }
    
}
