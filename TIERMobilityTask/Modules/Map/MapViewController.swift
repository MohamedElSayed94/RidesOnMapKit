//
//  MapViewController.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 03/08/2022.
//

import Foundation

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    
    var topBannerErrorView: UIView = UIView()
    var loadingViewController: UIViewController = SpinnerViewController()
    var mapView: MKMapView
    
    var viewModel: MapViewModelProtocol
    let locationManager = CLLocationManager()
    
    init(viewModel: MapViewModelProtocol = MapViewModel()) {
        self.viewModel = viewModel
        self.mapView = MKMapView()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        initMapView()
        checkLocationServices()
        
        viewModel.currentState = {  [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch state {
                case .loading(let loading):
                    print("loading \(loading)")
                    if loading {
                        self.showLoadingView()
                    } else {
                        self.hideLoadingView()
                    }
                case .recievedData(let scooters):
                    print(scooters.count)
                    self.addScootersToMap(scooters: scooters)
                    self.selectNearestScooter()
                    
                case .empty:
                    print("Empty")
                case .error(let error):
                    self.showError(error: error)
                }
            }
        }
        viewModel.getNearScooters()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
           setupLocationManager()
            checkLocationAuth()
        } else {
            print("Alert To let user know that they have to turn this on")
        }
    }
    
    func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
            print("Alert To let user know that they have to turn this on")
        case .denied:
            print("denied")
            print("Alert To let user know that they have to turn this on")
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            
            mapView.showsUserLocation = true
            centerMapToUserLocation()
            selectNearestScooter()
        @unknown default:
            print("Unknown")
        }
    }
    func centerMapToUserLocation() {
        if let userLocation = locationManager.location {
            mapView.centerToLocation(userLocation)
        } else {
            mapView.centerToLocation(CLLocation(latitude: Constants.userLocationlat, longitude: Constants.userLocationlng))
        }
    }
    func selectNearestScooterMarker(completion: @escaping (ScooterMarker?) -> Void) {
        
        guard let currentLocation = locationManager.location else { return }
        let pins = mapView.annotations.compactMap { $0 as? ScooterMarker }

        let nearestPin: ScooterMarker? = pins.reduce((CLLocationDistanceMax, nil)) { (nearest, pin) in
            let coord = pin.coordinate
            let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = currentLocation.distance(from: loc)
            return distance < nearest.0 ? (distance, pin) : nearest
        }.1
        completion(nearestPin)
    }
    func selectNearestScooter() {
        self.selectNearestScooterMarker { [weak self] scooterMarker in
            guard let self = self, let coordinate = scooterMarker?.coordinate else { return }
            self.drawRoute(distenation: coordinate)
        }
    }
    
    func drawRoute(distenation: CLLocationCoordinate2D) {
        if let currentLocation = self.locationManager.location?.coordinate {
            
            let userPlaceMark = MKPlacemark(coordinate: currentLocation)
            let scooterPlaceMark = MKPlacemark(coordinate: distenation)
            let userItem = MKMapItem(placemark: userPlaceMark)
            let scooterItem = MKMapItem(placemark: scooterPlaceMark)
            
            let distenationReq = MKDirections.Request()
            distenationReq.source = userItem
            distenationReq.destination = scooterItem
            distenationReq.transportType = .walking
            
            let directions = MKDirections(request: distenationReq)
            directions.calculate { [weak self] (response, error) in
                guard let self = self else { return }
                guard let response = response else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
            }
            
        }
    }
    func initMapView() {

        let initialLocation = CLLocation(latitude: Constants.userLocationlat, longitude: Constants.userLocationlng)
        let oahuCenter = initialLocation
        let region = MKCoordinateRegion(
            center: oahuCenter.coordinate,
            latitudinalMeters: 50000,
            longitudinalMeters: 60000)
        mapView.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 50000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7).isActive = true
    }
    
    func addScootersToMap(scooters: [ScooterModel]) {
        let markers: [ScooterMarker] = scooters.compactMap {ScooterMarker(scooter: $0)}
        mapView.addAnnotations(markers)
        
    }
    
}

extension MapViewController: FailableProtocol {
    // There's a defualt implementation for different Error views, but If we need a custom ones for this viewController we could override them by building func showGeneralError(), func showNetworkError() here
    

    
}

extension MapViewController: LoadableProtocol  {
    // There's a defualt implementation for loading view, but If we need a custom one for this viewController we could override it by building func showLoadingView() here
}






extension MapViewController: MKMapViewDelegate {
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? ScooterMarker else {
            return nil
        }
        
        let identifier = "UserLocationMarkerView"
        var view: MKMarkerAnnotationView
        
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let scooter = view.annotation as? ScooterMarker else {
            return
          }
        mapView.removeOverlays(mapView.overlays)
        drawRoute(distenation: scooter.coordinate)
          print(scooter)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay.isKind(of: MKPolyline.self) {
            // draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineDashPattern = [0, 6]
            polyLineRenderer.lineWidth = 2.0

            return polyLineRenderer
        }



        return MKPolylineRenderer()
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuth()
    }
}
