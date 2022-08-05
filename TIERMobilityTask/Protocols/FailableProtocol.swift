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
    func showError(error: Errortypes)
    func showGeneralError()
    func showNetworkError()
    func hideError()
}

extension FailableProtocol where Self : UIViewController {

    func showError(error: Errortypes) {
        
        switch error {
        case .network:
            showNetworkError()
        case .APIError:
            showGeneralError()
        case .DecodeError:
            showGeneralError()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.hideError()
        }
    }
    
    
    func showGeneralError() {
        // topbanner with reloadable button
    }
    func showNetworkError() {
        hideError()
        topBannerErrorView.backgroundColor = .red
        self.view.addSubview(topBannerErrorView)
        topBannerErrorView.translatesAutoresizingMaskIntoConstraints = false
        
        topBannerErrorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topBannerErrorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        topBannerErrorView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        topBannerErrorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    func hideError() {
        if topBannerErrorView.superview != nil {
            topBannerErrorView.removeFromSuperview()
        }
    }
}
