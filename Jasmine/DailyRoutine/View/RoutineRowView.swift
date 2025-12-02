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
                    HStack(spacing: 6) {
                        Image(systemName: routine.type.iconName)
                            .font(.system(size: 13))
                            .foregroundColor(routine.type.color)
                        
                        Text(routine.type.displayTypeOfRoutine)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(routine.type.backgroundColor)
                    )
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        Text(timeString)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
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
