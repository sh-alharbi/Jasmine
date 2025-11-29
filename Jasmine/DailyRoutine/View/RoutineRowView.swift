//
//  RoutineRowView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/27/25.
//

import SwiftUI

struct RoutineRowView: View {
    let routine: Routine
    let onToggleDone: () -> Void
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: routine.time)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleDone) {
                Image(systemName: routine.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(
                        routine.isDone
                        ? .jasmineGreen
                        : .gray.opacity(0.5)
                    )
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(routine.routineName)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text("\(routine.type.emoji) \(routine.type.displayTypeOfRoutine)")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(routine.type == .morning
                                      ? Color.yellow.opacity(0.2)
                                      : Color.blue.opacity(0.2))
                        )
                    
                    Text(timeString)
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                        )
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
