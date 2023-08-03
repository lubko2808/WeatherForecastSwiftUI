//
//  WeatherForecastSwiftUIApp.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import SwiftUI

@main
struct WeatherForecastSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(dataService: DataService())
        }
    }
}
