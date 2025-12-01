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
                    Picker(
                        selection: $viewModel.selectedType
                    ) {
                        ForEach(RoutineType.allCases) { type in
                            HStack(spacing: 8) {
                                Image(systemName: type.iconName)
                                                .font(.system(size: 18))
                                                .foregroundColor(type.color)
                                
                                Text(type.displayTypeOfRoutine)
                                    .foregroundColor(type.color)
                              
                            }
                            .tag(type)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("Morning or night")
                        }
                    }
                    
                    DatePicker(
                        selection: $viewModel.selectedTime,
                        displayedComponents: .hourAndMinute
                    ) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("Time")
                        }
                    }
                }
                
                if viewModel.existingRoutine != nil, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            if let id = viewModel.existingRoutine?.id {
                                onDelete(id)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Reminder")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    Text("Set Routine")
                        .font(.system(size: 20, weight: .semibold))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }

                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let saved = viewModel.save(in: store, for: selectedDate)
                        onSaved(saved)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }

            }
        }
    }
}
