//
//  UIViewControllerExtension.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 06/08/2022.
//

import Foundation
import UIKit



extension UIViewController {
    
    func createLabelWith(_ text: String, font: UIFont = .systemFont(ofSize: 12, weight: .regular), alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.textAlignment = alignment
        label.font = font
        label.text = text
        return label
        
    }
}
