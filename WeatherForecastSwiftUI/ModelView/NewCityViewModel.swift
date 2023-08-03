//
//  NewCityViewModel.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 02.08.2023.
//

import Combine
import Foundation

class NewCityViewModel: ObservableObject {
    
    private(set) var errorMessage: String? = nil
    @Published var isError = false
    
    @Published var textFieldText = ""
    
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    private var cityModel: CityModel?
    
    @Published var cities: [String] = []
    @Published var countries: [String] = []
    
    init(dataService: DataService) {
        self.dataService = dataService
        addTextFieldSubscriber()
    }
    
    private func addTextFieldSubscriber() {
        $textFieldText
            .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                if !text.isEmpty {
                    self?.cities = []
                    self?.fetchCities(beginningWith: text)
                } else {
                    self?.cities = []
                    self?.countries = []
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchCities(beginningWith prefix: String) {
        
        dataService.fetch(.city(prefix: prefix))
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isError.toggle()
                }
            } receiveValue: { citiesData in
                self.cityModel = citiesData
                self.handleData()
                
            }
            .store(in: &cancellables)
        
    }
    
    private func handleData() {
        guard let cityModel = cityModel else {
            self.errorMessage = "The data is missing"
            self.isError.toggle()
            return
        }
        
        var tempCites: [String] = []
        var tempCountries: [String] = []
        for cityData in cityModel.data {
            tempCites.append(cityData.city)
            tempCountries.append(cityData.country)
        }
        cities = tempCites
        countries = tempCountries
        
        print("everything was good")
    }
    
}
