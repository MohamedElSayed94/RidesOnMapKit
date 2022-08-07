//
//  MapRepositoryTests.swift
//  TIERMobilityTaskTests
//
//  Created by Mohamed Elsayed on 06/08/2022.
//

import XCTest
@testable import TIERMobilityTask

class MapRepositoryTests: XCTestCase {
    
    var mapRepository: MapDataRepositoryProtocol?
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mapRepository = nil
    }

    func testMapDataRepositoryFail() throws {
        let failMockMapService: MapServiceProtocol = MockMapServiceFail()
        
        mapRepository = MapDataRepository(service: failMockMapService)
        mapRepository?.getNearScooters(completion: { result in
            switch result {
            case .success:
                XCTFail("This should not happen.")
            case .failure(let error):
                XCTAssert(error == .APIError("API Error"))
            }
        })
        
    }
    
    func testMapDataRepositorySuccess() throws {
        let successMockMapService: MapServiceProtocol = MockMapServiceSuccess()
        
        mapRepository = MapDataRepository(service: successMockMapService)
        mapRepository?.getNearScooters(completion: { result in
            switch result {
            case .success(let scooters):
                XCTAssert(scooters[0].id == "1")
                XCTAssert(scooters[0].type == "Scooter")
            case .failure:
                
                XCTFail("This should not happen.")
            }
        })
        
    }
    
    

}

// MARK: - Mocks
extension MapRepositoryTests {
    struct MockMapServiceFail: MapServiceProtocol {
        func getNearScooters(completion: @escaping (Result<[ScooterModel], Errortypes>) -> Void) {
            completion(.failure(.APIError("API Error")))
        }
        
        
    }
    struct MockMapServiceSuccess: MapServiceProtocol {
        func getNearScooters(completion: @escaping (Result<[ScooterModel], Errortypes>) -> Void) {
            completion(.success([ScooterModel(type: "Scooter", id: "1", attributes: nil)]))
        }
        
        
    }
}
