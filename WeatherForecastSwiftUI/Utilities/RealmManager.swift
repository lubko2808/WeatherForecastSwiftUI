//
//  RealmManager.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 31.07.2023.
//

import Foundation
import RealmSwift

class RealmManager {
    
    enum RealmError: LocalizedError {
        case openingError
        case addingError
        case deletingError

        var errorDescription: String? {
            switch self {
            case .openingError:
                return NSLocalizedString("Couldn't open the database.", comment: "")
            case .addingError:
                return NSLocalizedString("Couldn't add city.", comment: "")
            case .deletingError:
                return NSLocalizedString("Could't delete city.", comment: "")
            }
        }
    }
    
    private(set) var localRealm: Realm?
    private(set) var cities: [City] = []

    func openRealm() throws {
        do {
            let config = Realm.Configuration(schemaVersion: 2) { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: City.className()) { oldObject, newObject in
                        newObject!["dateAdded"] = Date()
                    }
                }
            }
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            throw RealmError.openingError
        }
    }
    
    func addCity(cityName : String) throws {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    let newCity = City(value: ["name": cityName, "dateAdded": Date()])
                    localRealm.add(newCity)
                    print("Added new task to Realm \(newCity)")
                }
            } catch {
                throw RealmError.addingError
            }
        }
    }
    
    func getCities(searchText: String = "") {
        if let localRealm = localRealm {
            var allCities = localRealm.objects(City.self).sorted(byKeyPath: "dateAdded", ascending: false)
            
            if !searchText.isEmpty {
                allCities = allCities.filter(NSPredicate(format: "name CONTAINS[c] %@", searchText))
            }
            
            cities = []
            allCities.forEach { city in
                cities.append(city)
            }
        }
    }
 
    func deleteCity(at index: Int) throws {
        if let localRealm = localRealm {
            do {
                let cityToDelete = localRealm.objects(City.self)[index]

                try localRealm.write {
                    localRealm.delete(cityToDelete)
                }
            } catch {
                throw RealmError.deletingError
            }
        }
    }
    
}

