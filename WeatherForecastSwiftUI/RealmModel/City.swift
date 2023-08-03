//
//  City.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 31.07.2023.
//

import Foundation
import RealmSwift

class City: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var dateAdded: Date
    
}
