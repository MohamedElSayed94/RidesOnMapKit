//
//  ErrorTypes.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 04/08/2022.
//

import Foundation


enum Errortypes: Error, Equatable {
    case network
    case APIError(String?)
    case DecodeError(String?)
    case GeneralError(String?)
}
