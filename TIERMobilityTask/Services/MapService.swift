//
//  MapService.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 04/08/2022.
//

import Foundation
import UIKit



class MapService {
    
    func getNearScooters( completion: @escaping (Result<[ScooterModel], Errortypes>) -> Void) {
        let baseUrl = Constants.URL.baseUrl
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.path.append(NetworkConfiguration.userID)
        urlComponents.queryItems = [URLQueryItem(name: "apiKey", value: NetworkConfiguration.apiKey)]
        
        let request = URLRequest(url: urlComponents.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil
            else {
                completion(.failure(Errortypes.APIError))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(ScooterResponse.self, from: data)
                completion(.success(decodedData.data ?? []))
            } catch let err {
                print("Failed to decode JSON \(err)")
                completion(.failure(Errortypes.DecodeError))
            }
            
        }
        task.resume()
    }
}
