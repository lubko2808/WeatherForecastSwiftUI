//
//  CityModel.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 30.07.2023.
//

import Foundation

struct CityModel: Decodable {
    let data: [Data]
    
    struct Data: Decodable {
        let city: String
        let country: String
    }
}
