//
//  FailableProtocol.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 04/08/2022.
//

import Foundation
import UIKit


protocol FailableProtocol {
    var topBannerErrorView: UIView {get set}
    var retryButton: UIButton {get set}
    func showError(error: Errortypes)
    func showGeneralError(_ error: String?)
    func showNetworkError()
    func hideError()
}

extension FailableProtocol where Self : UIViewController {

    func showError(error: Errortypes) {
        
        switch error {
        case .network:
            showNetworkError()
        case .APIError(let error):
            showErrorWithRetry(error)
        case .DecodeError(let error):
            showGeneralError(error)
        case .GeneralError(let error):
            showGeneralError(error)
        }
    }
    
    
    func showGeneralError(_ error: String?) {
        hideError()
        topBannerErrorView.backgroundColor = .blue
        let label = createLabelWith(error, alignment: .center, textColor: .white)
        createTopBannerErrorViewWith(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.hideError()
            self.showNetworkError()
        }
    }
    
    func showErrorWithRetry(_ error: String?) {
        hideError()
        topBannerErrorView.backgroundColor = .blue
        let label = createLabelWith(error, alignment: .center, textColor: .white)
        createTopBannerErrorViewWith(label)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 10)
        retryButton.layer.cornerRadius = 5
        retryButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        retryButton.tintColor = .white
        retryButton.backgroundColor = .blue
        self.view.addSubview(retryButton)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.topAnchor.constraint(equalTo: topBannerErrorView.bottomAnchor, constant: 10).isActive = true
        retryButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        retryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        retryButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
    }
    
    func showNetworkError() {
        hideError()
        topBannerErrorView.backgroundColor = .red
        let label = createLabelWith("You are not connected to the Internet", alignment: .center, textColor: .white)
        createTopBannerErrorViewWith(label)
        
    }
    
    func createTopBannerErrorViewWith(_ label: UILabel) {
        topBannerErrorView.subviews.forEach { $0.removeFromSuperview() }
        topBannerErrorView.layer.cornerRadius = 5
        self.view.addSubview(topBannerErrorView)
        topBannerErrorView.translatesAutoresizingMaskIntoConstraints = false
        
        topBannerErrorView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        topBannerErrorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        topBannerErrorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        topBannerErrorView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        topBannerErrorView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topBannerErrorView.topAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: topBannerErrorView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: topBannerErrorView.trailingAnchor, constant: -8).isActive = true
        label.bottomAnchor.constraint(equalTo: topBannerErrorView.bottomAnchor, constant: -8).isActive = true
    }

    func hideError() {
        if topBannerErrorView.superview != nil {
            topBannerErrorView.removeFromSuperview()
        }
    }
}
