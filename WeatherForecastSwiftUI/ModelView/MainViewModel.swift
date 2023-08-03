//
//  MainViewModel.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 02.08.2023.
//

import Combine
import CoreLocation
import MapKit

class MainViewModel: NSObject, ObservableObject {
    private let dataService: DataService
    
    var errorMessage: String? = nil
    @Published var isError = false
    
    @Published var isDataReady = false
    @Published var isCityReady = false

    @Published var currentCity = ""
    @Published var currentTemp = ""
    @Published var weatherTypes: [WeatherDataFormatter.WeatherIcon] = []
    @Published var days: [String] = []
    @Published var dayAndNightTemp: [String] = []
    
    private var weatherModel: WeatherModel?
    private var weatherFormatter = WeatherDataFormatter()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentLatitude: CLLocationDegrees?
    private var currentLongitude: CLLocationDegrees?
    private let locationManager = CLLocationManager()
   
    
    init(dataService: DataService) {
        self.dataService = dataService
        super.init()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    private func handleError(errorMessage: String) {
        self.errorMessage = errorMessage
        self.isError.toggle()
        self.currentTemp = ""
        self.dayAndNightTemp = []
    }
    
    private func handleData() {
        
        guard let weatherModel else {
            self.handleError(errorMessage: "The data is missing")
            return
        }
        
        currentTemp = weatherFormatter.getCurrentTemperature(weatherModel)
        
        var tempDayAndNightTemp: [String] = []
        for index in 0...4 {
            tempDayAndNightTemp.append(weatherFormatter.getDayAndNightTemperature(weatherModel, for: index))
        }
        dayAndNightTemp = tempDayAndNightTemp
        
        var tempDays: [String] = []
        for index in 0...4 {
            tempDays.append(weatherFormatter.day(at: index))
        }
        days = tempDays
        
        var tempWeatherTypes: [WeatherDataFormatter.WeatherIcon] = []
        for index in 0...4 {
            tempWeatherTypes.append(weatherFormatter.getWeatherType(weatherModel, for: index))
        }
        weatherTypes = tempWeatherTypes

        isDataReady = true
        
    }
    
    private func geocoder(city: String, completion: @escaping(Double, Double) -> Void) {
        let geocoder = CLGeocoder()
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        geocoder.geocodeAddressString(city, completionHandler: { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(errorMessage: error.localizedDescription)
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                completion(latitude, longitude)
            }
        })
    }
    
    func fetchWeatherForCity(cityName: String) {
        
        geocoder(city: cityName) { [weak self] latitude, longitude in
            guard let self = self else { return }
            
            self.dataService.fetch(.forecast(latitude: latitude, longitude: longitude))
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        self.handleError(errorMessage: error.localizedDescription)
                    }
                } receiveValue: { weather in
                    self.weatherModel = weather
                    self.handleData()
                }
                .store(in: &self.cancellables)
        }
    }
}

extension MainViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locationManager.location else {
            self.handleError(errorMessage: "Can't obtain current location")
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(currentLocation, preferredLocale: Locale(identifier: "en")) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error {
                self.handleError(errorMessage: error.localizedDescription)
                return
            }

            guard let city = placemarks?.first?.locality else {
                self.handleError(errorMessage: "Can't obtain current city")
                return
            }
            self.currentCity = city
            self.isCityReady = true
            
        }
        
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        
        dataService.fetch(.forecast(latitude: currentLatitude!, longitude: currentLongitude!))
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    self.handleError(errorMessage: error.localizedDescription)
                }
            } receiveValue: { weather in
                self.weatherModel = weather
                self.handleData()
            }
            .store(in: &cancellables)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
        self.handleError(errorMessage:"Location update failed: \(error.localizedDescription)")
    }
    
}
