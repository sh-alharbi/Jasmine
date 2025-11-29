//
//  RoutineFormViewModel.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/27/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class RoutineFormViewModel: ObservableObject {
    @Published var productName: String = ""
    @Published var selectedType: RoutineType = .morning
    @Published var selectedTime: Date = Date()
    
    private(set) var existingRoutine: Routine? = nil
    
    init(existing: Routine? = nil) {
        if let routine = existing {
            self.existingRoutine = routine
            self.productName = routine.routineName
            self.selectedType = routine.type
            self.selectedTime = routine.time
        }
    }
    
    @discardableResult
    func save(in store: RoutineStore, for date: Date) -> Routine {
        let trimmed = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Routine" : trimmed
        
        if var existing = existingRoutine {
            existing.routineName = finalName
            existing.type = selectedType
            existing.time = selectedTime
            existing.date = date
            store.update(existing)
            existingRoutine = existing
            return existing
        } else {
            let newRoutine = Routine(
                routineName: finalName,
                time: selectedTime,
                type: selectedType,
                date: date
            )
            store.add(newRoutine)
            existingRoutine = newRoutine
            return newRoutine
        }
    }
}
