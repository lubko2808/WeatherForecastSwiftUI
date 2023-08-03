//
//  WeatherDataFormatter.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import Foundation

struct WeatherDataFormatter {
    
    enum WeatherInterpretCodes {
        static let sunny = [0, 1]
        static let partlyCloudy = [2]
        static let cloudy = [3]
        static let rain = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
        static let snow = [71, 73, 75, 77, 85, 86]
        static let thunderstorm = [95, 96, 99]
    }
    
    enum WeatherIcon: String {
        case sunny = "sun.max.fill"
        case partlyCloudy = "cloud.sun.fill"
        case cloudy = "cloud.fill"
        case rain = "cloud.rain.fill"
        case snow = "cloud.snow.fill"
        case thunderstorm = "cloud.bolt.rain.fill"
    }
    
    private let degreeSing = "\u{00B0}"

    func getWeatherType(_ rawWeather: WeatherModel, for day: Int) -> WeatherIcon {
        var sunnyHoursCount = 0
        var partlyCloudyHoursCount = 0
        var cloudyHoursCount = 0
        
        for weatherCode in rawWeather.hourly.weathercode[ (day * 24 + 8)...(day * 24 + 22) ] {
            if WeatherInterpretCodes.sunny.contains(weatherCode) {
                sunnyHoursCount += 1
            }
            
            if WeatherInterpretCodes.thunderstorm.contains(weatherCode) {
                return .thunderstorm
            }
        }
        
        for weatherCode in rawWeather.hourly.weathercode[ (day * 24 + 8)...(day * 24 + 22) ] {
            if WeatherInterpretCodes.partlyCloudy.contains(weatherCode) {
                partlyCloudyHoursCount += 1
            }
            
            if WeatherInterpretCodes.snow.contains(weatherCode) {
                return .snow
            }
        }
        
        for weatherCode in rawWeather.hourly.weathercode[ (day * 24 + 8)...(day * 24 + 22) ] {
            if WeatherInterpretCodes.cloudy.contains(weatherCode) {
                cloudyHoursCount += 1
            }
            
            if WeatherInterpretCodes.rain.contains(weatherCode) {
                return .rain
            }
        }
        
        if sunnyHoursCount >= partlyCloudyHoursCount + cloudyHoursCount {
            return .sunny
        } else if partlyCloudyHoursCount > cloudyHoursCount {
            return .partlyCloudy
        } else {
            return .cloudy
        }
    }
    
    func getCurrentTemperature(_ rawWeather: WeatherModel) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentTemperature = rawWeather.hourly.temperature_2m[currentHour]
        return String(currentTemperature) + degreeSing
    }
    
    func getDayAndNightTemperature(_ rawWeather: WeatherModel, for index: Int) -> String {
        let dayAndNightTemperature = String(rawWeather.hourly.temperature_2m[index * 24 + 2]) + degreeSing + "/" +
        String(rawWeather.hourly.temperature_2m[index * 24 + 13]) + degreeSing
        return dayAndNightTemperature
    }
    
    func day(at index: Int) -> String {
        let dayDict = [0: "Sun", 1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat"]
        let currentDate = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: currentDate) - 1
        
        return dayDict[ (currentDay + index) % 7 ]!
    }
}
