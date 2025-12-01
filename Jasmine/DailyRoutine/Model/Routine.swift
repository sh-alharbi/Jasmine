//
//  Routine.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/26/25.
//
import Foundation
import SwiftUI


struct Routine: Identifiable, Codable{
    let id: UUID
    var routineName: String
    var time: Date
    var type: RoutineType
    var isDone: Bool
    var date: Date
    
    init(
        id: UUID = UUID(),
        routineName: String,
        time: Date,
        type: RoutineType,
        isDone: Bool = false,
        date: Date
    ){
        self.id = id
        self.routineName = routineName
        self.time = time
        self.type = type
        self.isDone = isDone
        self.date = date
    }
}

enum RoutineType : String, Codable , CaseIterable , Identifiable{
    case morning
    case night
    
    var id: String{
        return self.rawValue
    }
    
    
    var displayTypeOfRoutine: String{
        switch self {
        case .morning:
            return "Morning"
        case .night:
            return "Night"
        }
    }
    
}
extension RoutineType {
    var iconName: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .night:   return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning: return Color.yellow.opacity(0.9)
        case .night:   return Color.blue.opacity(0.8)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .morning:
            return Color.yellow.opacity(0.20)
        case .night:
            return Color.blue.opacity(0.20)
        }
    }
}





