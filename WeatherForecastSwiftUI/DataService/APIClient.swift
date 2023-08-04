//
//  APIClient.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import Foundation

extension DataService {
    
    func fetch<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        var urlRequest = URLRequest(url: endpoint.url)
        
        if let headers = endpoint.headers {
            for header in headers {
                urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        
         return result
    }

}
