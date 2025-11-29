//
//  RoutineSheetView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/27/25.
//

import SwiftUI

struct RoutineSheetView: View {
    @EnvironmentObject var store: RoutineStore
    @ObservedObject var viewModel: RoutineFormViewModel
    
    let selectedDate: Date
    var onSaved: (Routine) -> Void
    var onDelete: ((UUID) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
               
                Section {
                           LabeledContent("Product Name") {
                               TextField("e.g. Serum", text: $viewModel.productName)
                           }
                       }

                
                Section {
                    Picker("Morning or night", selection: $viewModel.selectedType) {
                        ForEach(RoutineType.allCases) { type in
                            Text(type.displayTypeOfRoutine).tag(type)
                        }
                    }
                    
                    DatePicker(
                        "Time",
                        selection: $viewModel.selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                }
                
                if viewModel.existingRoutine != nil, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            if let id = viewModel.existingRoutine?.id {
                                onDelete(id)
                                dismiss()
                            }
                        } label: {
                            Text("Delete Routine")
                        }
                    }
                }
            }
            .navigationTitle("Set Routine")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let saved = viewModel.save(in: store, for: selectedDate)
                        onSaved(saved)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
