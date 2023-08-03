//
//  CitiesListViewModel.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 02.08.2023.
//

import Combine
import RealmSwift
import Foundation

class CitiesListViewModel: ObservableObject {
    
    private var realmManager = RealmManager()
    
    private(set) var errorMessage: String? = nil
    @Published var isError = false
    @Published var cities: [String] = []
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    init() {
        do {
            try realmManager.openRealm()
        } catch let error as RealmManager.RealmError {
            handleError(errorMessage: error.errorDescription ?? "")
        } catch {}
        addSubscribers()
        getCities()
    }
    
    private func handleError(errorMessage: String) {
        self.errorMessage = errorMessage
        isError.toggle()
    }

    private func addSubscribers() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterCities(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterCities(searchText: String) {
        guard !searchText.isEmpty else {
            getCities()
            return
        }
        
        realmManager.getCities(searchText: searchText)
        cities = realmManager.cities.map { city in
            city.name
        }
    }
    
    private func getCities() {
        realmManager.getCities()
        cities = realmManager.cities.map { city in
            city.name
        }
    }
    
    func addNewCity(name: String) {
        do {
            try realmManager.addCity(cityName: name)
        } catch let error as RealmManager.RealmError {
            handleError(errorMessage: error.errorDescription ?? "")
        } catch {}
        getCities()
    }
    
    func deleteCity(at index: Int) {
        do {
            try realmManager.deleteCity(at: index)
        } catch let error as RealmManager.RealmError {
            handleError(errorMessage: error.errorDescription ?? "")
        } catch {}
        getCities()
    }
    
}
