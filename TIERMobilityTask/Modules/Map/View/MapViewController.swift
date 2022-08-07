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
    
    // MARK: - Variables
    
    var topBannerErrorView: UIView = UIView()
    let emptyStateView = UIView()
    var retryButton: UIButton = UIButton()
    var bottomSheetViewController: HomeBottomSheetViewController
    var loadingViewController: UIViewController = SpinnerViewController()
    var mapView: MKMapView
    var viewModel: MapViewModelProtocol
    let locationManager = CLLocationManager()
    
    
    
    
    // MARK: - Init
    
    init(viewModel: MapViewModelProtocol = MapViewModel(), bottomSheetViewController: HomeBottomSheetViewController = HomeBottomSheetViewController()) {
        self.viewModel = viewModel
        self.bottomSheetViewController = bottomSheetViewController
        self.mapView = MKMapView()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - ViewController life cycle
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
                    self.hideEmptyStateBanner()
                    self.addScootersToMap(scooters: scooters)
                    self.selectNearestScooter()
                case .empty:
                    print("Empty")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showEmptyStateBanner()
                    }
                    
                case .error(let error):
                    self.showError(error: error)
                }
            }
        }
        viewModel.getNearScooters()
        
        NetworkMonitor.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name(rawValue: "connectionType"), object: nil)
        retryButton.addTarget(self, action: #selector(retryButtonAction), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NetworkMonitor.shared.stopMonitoring()
    }
    // MARK: - Location Methods
    
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
            if loadingViewController.isBeingDismissed {
                selectNearestScooter()
            }
        @unknown default:
            print("Unknown")
        }
    }
    
    // MARK: - Map methods
    
    func initMapView() {
        self.view.addSubview(mapView)
        mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        guard let initialLocation = locationManager.location else { return }
        let center = initialLocation
        let region = MKCoordinateRegion(
            center: center.coordinate,
            latitudinalMeters: 50000,
            longitudinalMeters: 60000)
        mapView.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 50000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
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
        let nearestPin = viewModel.getNearestPinFromUserLocation(pins: pins, currentLocation: currentLocation)
        completion(nearestPin)
    }
    func selectNearestScooter() {
        self.selectNearestScooterMarker { [weak self] scooterMarker in
            guard let self = self, let scooterMarker = scooterMarker else {
                self?.viewModel.currentState?(.empty)
                return
            }
            self.drawRoute(distenation: scooterMarker.coordinate)
            self.showBottomSheet()
            self.bottomSheetViewController.loadScooterData(scooterMarker.scooterlayoutVM)
            
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
                let mapRect = route.polyline.boundingMapRect
                self.mapView.setVisibleMapRect(mapRect, animated: true)
            }
            
        }
    }
    
    func addScootersToMap(scooters: [ScooterMarkerLayoutViewModel]) {
        let markers: [ScooterMarker] = scooters.compactMap {ScooterMarker(scooter: $0)}
        mapView.addAnnotations(markers)
        
    }
    
    // MARK: - Reachability Method
    
    @objc func appBecomeActive() {
        if NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { [self] in
                hideError()
            }
        } else {
            DispatchQueue.main.async {
                self.showError(error: .network)
            }
        }
    }
    // MARK: - showEmptyStateBanner
    func showEmptyStateBanner() {
        let label = createLabelWith("No vehicle around here", alignment: .center, textColor: .black)
        emptyStateView.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -8).isActive = true
        label.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: -8).isActive = true
        
        self.view.addSubview(emptyStateView)
        emptyStateView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        emptyStateView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emptyStateView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        emptyStateView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func hideEmptyStateBanner() {
        if emptyStateView.superview != nil {
            emptyStateView.removeFromSuperview()
        }
        
    }
    
    // MARK: - retryButtonAction Method
    
    @objc func retryButtonAction() {
        mapView.annotations.forEach { mapView.removeAnnotation($0) }
        mapView.overlays.forEach { mapView.removeOverlay($0) }
        viewModel.getNearScooters()
    }
}

// MARK: - FailableProtocol

extension MapViewController: FailableProtocol {
    
    
    // There's a defualt implementation for different Error views, but If we need a custom ones for this viewController we could override them by building func showGeneralError(), func showNetworkError() here
    
    
    
}

// MARK: - LoadableProtocol

extension MapViewController: LoadableProtocol  {
    // There's a defualt implementation for loading view, but If we need a custom one for this viewController we could override it by building func showLoadingView() here
}

// MARK: - Bottom Sheet Methods
extension MapViewController {
    
    func showBottomSheet() {
        hideBottomSheet()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.addChild(self.bottomSheetViewController)
            self.view.addSubview(self.bottomSheetViewController.view)
            self.bottomSheetViewController.didMove(toParent: self)
            let height = self.view.frame.height
            let width  = self.view.frame.width
            self.bottomSheetViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                let frame = self.bottomSheetViewController.view.frame
                let yComponent = self.view.frame.height * 0.7 - 30
                let newHeight = height - yComponent
                self.bottomSheetViewController.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: newHeight)
                
                self.mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.7)
            }
        }
        
    }
    
    func hideBottomSheet() {
        if !bottomSheetViewController.isBeingDismissed {
            bottomSheetViewController.willMove(toParent: nil)
            bottomSheetViewController.view.removeFromSuperview()
            bottomSheetViewController.removeFromParent()
        }
        
    }
    
    
    
}


// MARK: - Map delegate Methods

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
        showLoadingView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.mapView.removeOverlays(self.mapView.overlays)
            self.drawRoute(distenation: scooter.coordinate)
            print(scooter)
            self.bottomSheetViewController.loadScooterData(scooter.scooterlayoutVM)
            self.hideLoadingView()
        }
        
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

// MARK: - Location manager method

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuth()
    }
}
