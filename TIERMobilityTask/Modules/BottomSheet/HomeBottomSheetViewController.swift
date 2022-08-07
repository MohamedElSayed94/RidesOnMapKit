//
//  HomeBottomSheetViewController.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 06/08/2022.
//

import UIKit

class HomeBottomSheetViewController: UIViewController {
    
    
    var mainstackview: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 40, right: 10)
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    override func loadView() {
        view = UIView()
        view.addSubview(mainstackview)
        mainstackview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainstackview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mainstackview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainstackview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    
    
    func loadScooterData(_ scooter: ScooterMarkerLayoutViewModel) {
        mainstackview.arrangedSubviews.forEach {$0.removeFromSuperview()}
        let titleLabel = createLabelWith(scooter.vehicleType, font: .systemFont(ofSize: 14, weight: .semibold), alignment: .center)
        let battaryLevelLabel = createLabelWith(scooter.batteryLevel)
        let maxSpeedLabel = createLabelWith(scooter.maxSpeed)
        let helmetLabel = createLabelWith(scooter.hasHelmetBox)
        mainstackview.addArrangedSubview(titleLabel)
        mainstackview.addArrangedSubview(battaryLevelLabel)
        mainstackview.addArrangedSubview(maxSpeedLabel)
        mainstackview.addArrangedSubview(helmetLabel)
        self.view.layoutIfNeeded()
        
    }
    
    
    
}
