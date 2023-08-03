//
//  API.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import Foundation

class DataService {
    
    enum Endpoint {
        case forecast(latitude: Double, longitude: Double)
        case city(prefix: String)
        
        var headers: [(key: String, value: String)]? {
            switch self {
            case .forecast:
                return nil
            case .city:
                return [(key: "X-RapidAPI-Key", value: "9a79c4044dmsh8b389b0bc50c7d1p18e755jsn08c7c63170a8")]
            }
        }
        
        var url: URL {
            var components = URLComponents()
            
            switch self {
            case .forecast(let latitude, let longitude):
                components.scheme = "https"
                components.host = "api.open-meteo.com"
                components.path = "/v1/forecast"
                components.queryItems = [
                    URLQueryItem(name: "latitude", value: String(latitude)),
                    URLQueryItem(name: "longitude", value: String(longitude)),
                    URLQueryItem(name: "hourly", value: "temperature_2m"),
                    URLQueryItem(name: "hourly", value: "weathercode"),
                ]
            case .city(let prefix):
                components.scheme = "https"
                components.host = "wft-geo-db.p.rapidapi.com"
                components.path = "/v1/geo/cities"
                components.queryItems = [
                    URLQueryItem(name: "namePrefix", value: prefix),
                    URLQueryItem(name: "minPopulation", value: "100000"),
                    URLQueryItem(name: "limit", value: "10")
                ]
            }
            
            return components.url!
        }
    }
    
}
