//
//  WeatherForecastSwiftUI_UnitTests.swift
//  WeatherForecastSwiftUI_UnitTests
//
//  Created by Любомир  Чорняк on 09.08.2023.
//

import XCTest
@testable import WeatherForecastSwiftUI

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct or class]_[variable or function]_[expected result]
// Testing Structure: Given, When, Then

final class WeatherDataFormatter_Tests: XCTestCase {
    
    
    let weatherDataFormatter = WeatherDataFormatter()
    
    var weatherCodes = [0, 1, 2, 3, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 71, 73, 75, 77, 85, 86, 95, 96, 99]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnNil() {
        // Given
        let day = Int.random(in: 0..<10)
        
        // When
        var weatherCodes: [Int] = []
        
        for _ in 0..<(day * 24 + 22) {
            weatherCodes.append(weatherCodes.randomElement() ?? 0)
        }
        let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
        let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
        
        // Then
        XCTAssertNil(returnedResult)
    }
    
    func test_WeatherDataFormatter_getDayAndNightTemperature_shouldReturnCorrectTemp() {
        // Given
        let day = Int.random(in: 0..<10)
        var correctDayAndNightTemp = String()
        
        var temperature_2m: [Double] = []
        for index in 0...(day * 24 + 13) {
            if index == (day * 24 + 2) {
                let nightTemp = Double.random(in: -30...30)
                temperature_2m.append(nightTemp)
                correctDayAndNightTemp += nightTemp.description + weatherDataFormatter.degreeSing + "/"
            } else if index == (day * 24 + 13) {
                let dayTemp = Double.random(in: -30...30)
                temperature_2m.append(dayTemp)
                correctDayAndNightTemp += dayTemp.description + weatherDataFormatter.degreeSing
            } else {
                temperature_2m.append(Double.random(in: -30...30))
            }
        }
        let weatherModel = WeatherModel(hourly: .init(temperature_2m: temperature_2m, weathercode: []))
        
        // When
        let returnedResult = weatherDataFormatter.getDayAndNightTemperature(weatherModel, for: day)
        
        // Then
        XCTAssertEqual(returnedResult, correctDayAndNightTemp)
    }
    
    func test_WeatherDataFormatter_getDayAndNightTemperature_shouldReturnNil() {
        // Given
        let day = Int.random(in: 0..<10)

        // When
        var temperature_2m: [Double] = []
        
        for _ in 0..<(day * 24 + 13) {
            temperature_2m.append(Double.random(in: -30...30))
        }
        let weatherModel = WeatherModel(hourly: .init(temperature_2m: temperature_2m, weathercode: []))
        let returnedResult = weatherDataFormatter.getDayAndNightTemperature(weatherModel, for: day)
        
        // Then
        XCTAssertNil(returnedResult)
    }

    func test_WeatherDataFormatter_getCurrentTemperature_shouldReturnCorrectTemp() {
        // Given
        //let currentHour = Int.random(in: 0...23)
        let currentHour = Calendar.current.component(.hour, from: Date())

        var currentTemp = Double()
        
        var temperature_2m: [Double] = []
        for index in 0..<24 {
            if index == currentHour {
                currentTemp = Double.random(in: -30...30)
                temperature_2m.append(currentTemp)
            } else {
                temperature_2m.append(Double.random(in: -30...30))
            }
        }
        let weatherModel = WeatherModel(hourly: .init(temperature_2m: temperature_2m, weathercode: []))
        
        // When
        let returnedResult = weatherDataFormatter.getCurrentTemperature(weatherModel)
        
        // Then
        XCTAssertEqual(returnedResult, currentTemp.description + weatherDataFormatter.degreeSing)
    }
    
    func test_WeatherDataFormatter_getCurrentTemperature_shouldReturnNil() {
        // Given
        let currentHour = Int.random(in: 0...23)
        //let currentHour = Calendar.current.component(.hour, from: Date())
        
        // When
        var temperature_2m: [Double] = []
        for _ in 0..<currentHour {
            temperature_2m.append(Double.random(in: -30...30))
        }
        let weatherModel = WeatherModel(hourly: .init(temperature_2m: temperature_2m, weathercode: []))
        
        let returnedResult = weatherDataFormatter.getCurrentTemperature(weatherModel)
        
        // Then
        XCTAssertNil(returnedResult)
    }
    
    func test_WeatherDataFormatter_day_ShouldReturnCorrectDay() {
        let dayDict = [0: "Sun", 1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat"]
        let currentDay = Calendar.current.component(.weekday, from: Date() ) - 1
        
        for _ in 0..<100 {
            // Given
            let index = Int.random(in: 0..<100)
            
            let correctDay = dayDict[ (currentDay + index) % 7 ]!
            
            // When
            let returnedDay = weatherDataFormatter.day(at: index)
            
            // Then
            XCTAssertEqual(returnedDay, correctDay)
        }
    }
    
    func test_WeatherDataFormatter_day_ShouldReturnNil() {
        for _ in 0...10 {
            // Given
            let index = Int.random(in: -100..<0)
            
            // When
            let result = weatherDataFormatter.day(at: index)
            
            // Then
            XCTAssertNil(result)
        }
    }
    
    private func generateThreeSetOfRandomPositions(lowerBound: Int, upperBound: Int, fraction1: Int, fraction2: Int) -> ([Int], [Int], [Int]) {
        let count = upperBound - lowerBound + 1
        let fraction3 = count - fraction2 - fraction1
        
        var positions1: [Int] = []
        var positions2: [Int] = []
        var positions3: [Int] = []
        
        var AvailablePositions: [Int] = []
        for position in lowerBound...upperBound {
            AvailablePositions.append(position)
        }
        
        for _ in lowerBound...upperBound {
            let randomPosition = AvailablePositions.randomElement()!
            if positions1.count != fraction1 {
                positions1.append(randomPosition)
            } else if positions2.count != fraction2 {
                positions2.append(randomPosition)
            } else {
                positions3.append(randomPosition)
            }
            
            AvailablePositions.removeAll(where: {$0 == randomPosition})
        }
        
        return (positions1, positions2, positions3)
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnCloudy() {
        for _ in 0...100 {
            // Given
            let day = Int.random(in: 0..<10)
            let _8am = (day * 24 + 8), _10pm = (day * 24 + 22)
            let sunnyCodes = [0, 1]
            let partlyCloudyCodes = [2]
            let cloudyCodes = [3]
            var weatherCodes: [Int] = []
            
            let DayHours = 15
            let sunnyDaysRandomCount = DayHours / 2 - Int.random(in: 0...7)
            let remainingHours = DayHours - sunnyDaysRandomCount
            let partlyCloudyDaysRandomCount = (remainingHours / 2) - Int.random(in: 0...(remainingHours / 2) )
            
            let randomPositions: (sunny: [Int], partlyCloudy: [Int], cloudy: [Int]) = generateThreeSetOfRandomPositions(lowerBound: _8am, upperBound: _10pm, fraction1: sunnyDaysRandomCount, fraction2: partlyCloudyDaysRandomCount)
            
            // When
            for index in 0..._10pm {
                if randomPositions.sunny.contains(index) {
                    weatherCodes.append(sunnyCodes.randomElement()!)
                } else if randomPositions.partlyCloudy.contains(index) {
                    weatherCodes.append(partlyCloudyCodes.randomElement()!)
                } else if randomPositions.cloudy.contains(index) {
                    weatherCodes.append(cloudyCodes.randomElement()!)
                } else {
                    weatherCodes.append(self.weatherCodes.randomElement()!)
                }
            }
            let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
            let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
            
            // Then
            XCTAssertEqual(returnedResult, WeatherDataFormatter.WeatherIcon.cloudy)
        }
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnPartlyCloudy() {
        for _ in 0...100 {
            // Given
            let day = Int.random(in: 0..<10)
            let _8am = (day * 24 + 8), _10pm = (day * 24 + 22)
            let sunnyCodes = [0, 1]
            let partlyCloudyCodes = [2]
            let cloudyCodes = [3]
            var weatherCodes: [Int] = []
            
            let DayHours = 15
            let sunnyDaysRandomCount = DayHours / 2 - Int.random(in: 0...7)
            let remainingHours = DayHours - sunnyDaysRandomCount
            let partlyCloudyDaysRandomCount = ((remainingHours % 2 == 0) ? remainingHours / 2 : remainingHours / 2 + 1) + Int.random(in: 1...((remainingHours % 2 == 0) ? remainingHours / 2 : remainingHours / 2 + 1))
            
            let randomPositions: (sunny: [Int], partlyCloudy: [Int], cloudy: [Int]) = generateThreeSetOfRandomPositions(lowerBound: _8am, upperBound: _10pm, fraction1: sunnyDaysRandomCount, fraction2: partlyCloudyDaysRandomCount)
            
            // When
            for index in 0..._10pm {
                if randomPositions.sunny.contains(index) {
                    weatherCodes.append(sunnyCodes.randomElement()!)
                } else if randomPositions.partlyCloudy.contains(index) {
                    weatherCodes.append(partlyCloudyCodes.randomElement()!)
                } else if randomPositions.cloudy.contains(index) {
                    weatherCodes.append(cloudyCodes.randomElement()!)
                } else {
                    weatherCodes.append(self.weatherCodes.randomElement()!)
                }
            }
            let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
            let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
            
            // Then
            XCTAssertEqual(returnedResult, WeatherDataFormatter.WeatherIcon.partlyCloudy)
        }
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnSunny() {
        for _ in 0...100 {
            // Given
            let day = Int.random(in: 0..<10)
            let _8am = (day * 24 + 8), _10pm = (day * 24 + 22)
            let thunderstormSnowRainCodes = [71, 73, 75, 77, 85, 86, 95, 96, 99, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
            let sunnyCodes = [0, 1]
            var weatherCodes: [Int] = []
            
            let DayHours = 15
            let sunnyDaysRandomCount = DayHours / 2 + Int.random(in: 1...8)
            
            let randomPositions: (sunny: [Int], CloudyAndPartlyCloudy: [Int], _: [Int]) = generateThreeSetOfRandomPositions(lowerBound: _8am, upperBound: _10pm, fraction1: sunnyDaysRandomCount, fraction2: DayHours - sunnyDaysRandomCount)
            
            // When
            for index in 0..._10pm {
                if randomPositions.sunny.contains(index) {
                    weatherCodes.append(sunnyCodes.randomElement()!)
                } else if randomPositions.CloudyAndPartlyCloudy.contains(index) {
                    weatherCodes.append(self.weatherCodes.filter( {!thunderstormSnowRainCodes.contains($0)} ).randomElement()!)
                } else {
                    weatherCodes.append(self.weatherCodes.randomElement()!)
                }
            }
            let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
            let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
            
            // Then
            XCTAssertEqual(returnedResult, WeatherDataFormatter.WeatherIcon.sunny)
        }
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnRain() {
        for _ in 0...100 {
            // Given
            let day = Int.random(in: 0..<10)
            let _8am = (day * 24 + 8), _10pm = (day * 24 + 22)
            let thunderstormSnowCodes = [71, 73, 75, 77, 85, 86, 95, 96, 99]
            let rainCodes = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
            var weatherCodes: [Int] = []
            let randomPosition = Int.random(in: _8am..._10pm)
            
            // When
            for index in 0..._10pm {
                if index == randomPosition {
                    weatherCodes.append(rainCodes.randomElement()!)
                } else if index >= _8am && index <= _10pm {
                    weatherCodes.append(self.weatherCodes.filter( {!thunderstormSnowCodes.contains($0)} ).randomElement()!)
                } else {
                    weatherCodes.append(self.weatherCodes.randomElement()!)
                }
            }
            let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
            let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
            
            // Then
            XCTAssertEqual(returnedResult, WeatherDataFormatter.WeatherIcon.rain)
        }
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnSnow() {
        for _ in 0...100 {
            // Given
            let day = Int.random(in: 0..<10)
            let _8am = (day * 24 + 8), _10pm = (day * 24 + 22)
            let thunderstormCodes = [95, 96, 99]
            let snowCodes = [71, 73, 75, 77, 85, 86]
            var weatherCodes: [Int] = []
            let randomPosition = Int.random(in: _8am..._10pm)
            
            // When
            for index in 0..._10pm {
                if index == randomPosition {
                    weatherCodes.append(snowCodes.randomElement()!)
                } else if index >= _8am && index <= _10pm {
                    weatherCodes.append(self.weatherCodes.filter( {!thunderstormCodes.contains($0)} ).randomElement()!)
                } else {
                    weatherCodes.append(self.weatherCodes.randomElement()!)
                }
            }
            let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
            let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
            
            // Then
            XCTAssertEqual(returnedResult, WeatherDataFormatter.WeatherIcon.snow)
        }
    }
    
    func test_WeatherDataFormatter_getWeatherType_shouldReturnThunderstorm() {
        for _ in 0...100 {
            // Given
            let day = Int.random(in: 0..<10)
            let _8am = (day * 24 + 8), _10pm = (day * 24 + 22)
            let thunderstormCodes = [95, 96, 99]
            var weatherCodes: [Int] = []
            let randomPosition = Int.random(in: _8am..._10pm)
            
            // When
            for index in 0...(day * 24 + 22) {
                if index == randomPosition {
                    weatherCodes.append(thunderstormCodes.randomElement()!)
                } else {
                    weatherCodes.append(self.weatherCodes.randomElement()!)
                }
            }
            let weatherModel = WeatherModel(hourly: .init(temperature_2m: [], weathercode: weatherCodes))
            let returnedResult = weatherDataFormatter.getWeatherType(weatherModel, for: day)
            
            // Then
            XCTAssertEqual(returnedResult, WeatherDataFormatter.WeatherIcon.thunderstorm)
        }
    }

}
