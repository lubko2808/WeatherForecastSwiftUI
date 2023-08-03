//
//  APIClient.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import Foundation
import Combine

extension DataService {
    
    func fetch<Response: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<Response, Error>  {
        var urlRequest = URLRequest(url: endpoint.url)
        
        if let headers = endpoint.headers {
            for header in headers {
                urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse,
                        response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }

                return data
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
