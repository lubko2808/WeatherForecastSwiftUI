//
//  WeatherModel.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import Foundation

struct WeatherModel: Decodable {
    let hourly: Hourly
    
    struct Hourly: Decodable {
        let temperature_2m: [Double]
        let weathercode: [Int]
    }
}
