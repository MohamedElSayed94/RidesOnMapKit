//
//  MapViewModelTests.swift
//  TIERMobilityTaskTests
//
//  Created by Mohamed Elsayed on 07/08/2022.
//

import XCTest
@testable import TIERMobilityTask
import CoreLocation
class MapViewModelTests: XCTestCase {
    
    var ViewModel: MapViewModel?
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        ViewModel = nil
    }

    func testGetNearestPinFromUserLocation() throws {
        ViewModel = MapViewModel()
        
        let realNearstScooter = ScooterMarker(scooter: ScooterMarkerLayoutViewModel(ScooterModel(type: "", id: "1", attributes: ScooterModel.Attribute(batteryLevel: 40, hasHelmetBox: false, lat: 52.498131, lng: 13.443343, maxSpeed: 20, vehicleType: "Scooter")))!)
        let scooter2 = ScooterMarker(scooter: ScooterMarkerLayoutViewModel(ScooterModel(type: "", id: "2", attributes: ScooterModel.Attribute(batteryLevel: 70, hasHelmetBox: false, lat: 52.498856, lng: 13.447655, maxSpeed: 20, vehicleType: "Scooter")))!)
        let scooter3 = ScooterMarker(scooter: ScooterMarkerLayoutViewModel(ScooterModel(type: "", id: "3", attributes: ScooterModel.Attribute(batteryLevel: 70, hasHelmetBox: false, lat: 52.501231, lng: 13.432566, maxSpeed: 20, vehicleType: "Scooter")))!)
        var scooterArr = [ScooterMarker]()
        scooterArr.append(realNearstScooter)
        scooterArr.append(scooter2)
        scooterArr.append(scooter3)
        let calculatedNearestMarker = ViewModel?.getNearestPinFromUserLocation(pins: scooterArr, currentLocation: CLLocation(latitude: 52.501232, longitude: 13.44))
        XCTAssertTrue(calculatedNearestMarker?.scooterlayoutVM.id == "1")
        XCTAssertFalse(calculatedNearestMarker?.scooterlayoutVM.id == "2")
        XCTAssertFalse(calculatedNearestMarker?.scooterlayoutVM.id == "3")
        
    }

    

}
