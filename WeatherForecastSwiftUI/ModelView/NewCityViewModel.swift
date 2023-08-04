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
    
    private var tasks: [Task<Void, Never>] = []
    
    @Published var cities: [String] = []
    @Published var countries: [String] = []
    
    init(dataService: DataService) {
        self.dataService = dataService
        addTextFieldSubscriber()
    }
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
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
        
        let task = Task {
            do {
                cityModel = try await dataService.fetch(.city(prefix: prefix))
                await handleData()
            } catch {
                errorMessage = error.localizedDescription
                isError.toggle()
            }
        }
        tasks.append(task)
    }
    
    @MainActor
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
    }
    
}
