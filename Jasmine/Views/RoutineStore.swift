//
//  RoutineStore.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/26/25.
//

import Foundation
import Combine
import SwiftUI


@MainActor
final class RoutineStore: ObservableObject {
    @Published var routines: [Routine] = []
    
    @Published var isRewardEnabled: Bool = false
    @Published var totalPoints: Int = 0
    
    func routines(for date: Date) -> [Routine] {
        routines.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func isDayCompleted(_ date: Date) -> Bool {
        let todayRoutines = routines(for: date)
        return !todayRoutines.isEmpty && todayRoutines.allSatisfy { $0.isDone }
    }
    
    func add(_ routine: Routine) {
        routines.append(routine)
    }
    
    func update(_ updated: Routine) {
        if let index = routines.firstIndex(where: { $0.id == updated.id }) {
            routines[index] = updated
        }
    }
    
    func delete(_ id: UUID) {
        if let index = routines.firstIndex(where: { $0.id == id }) {
            routines.remove(at: index)
        }
    }
    
    func toggleDone(id: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        routines[index].isDone.toggle()
        
        guard isRewardEnabled else { return }
        
        if routines[index].isDone {
            totalPoints += 5
        } else {
            totalPoints = max(totalPoints - 5, 0)
        }
    }
}
