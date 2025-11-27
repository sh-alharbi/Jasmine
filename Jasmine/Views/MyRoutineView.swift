//
//  MyRoutineView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/26/25.
//

// MyRoutineView.swift
import SwiftUI

struct MyRoutineView: View {
    @EnvironmentObject var store: RoutineStore
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonthOffset: Int = 0
    
    @State private var showAddSheet = false
    @State private var editingRoutine: Routine? = nil
    
    private var todaysRoutines: [Routine] {
        store.routines(for: selectedDate)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                
                headerSection
                
                Text("Routine")
                    .font(.headline)
                    .padding(.horizontal, 24)
                
                if todaysRoutines.isEmpty {
                    Text("No routines for this day yet.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(todaysRoutines) { routine in
                                RoutineRowView(
                                    routine: routine,
                                    onToggleDone: {
                                        store.toggleDone(id: routine.id)
                                    }
                                )
                                .padding(.horizontal, 24)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingRoutine = routine
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer(minLength: 20)
            }
            
            Button {
                showAddSheet = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 60, height: 60)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .bold))
                }
                .shadow(radius: 4)
            }
            .padding(24)
        }
        .sheet(isPresented: $showAddSheet) {
            RoutineSheetView(
                viewModel: RoutineFormViewModel(),
                selectedDate: selectedDate,
                onSaved: { _ in },
                onDelete: nil
            )
            .environmentObject(store)
        }
        .sheet(item: $editingRoutine) { item in
            RoutineSheetView(
                viewModel: RoutineFormViewModel(existing: item),
                selectedDate: selectedDate,
                onSaved: { updated in
                    store.update(updated)
                },
                onDelete: { id in
                    store.delete(id)
                }
            )
            .environmentObject(store)
        }
    }
    
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button {
                    currentMonthOffset -= 1
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString(for: monthDate))
                    .font(.headline)
                
                Spacer()
                
                Button {
                    currentMonthOffset += 1
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            
            if store.isRewardEnabled {
                HStack {
                    Spacer()
                    Text("\(store.totalPoints) points")
                        .font(.subheadline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(daysInMonth, id: \.self) { day in
                        let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                        let completed = store.isDayCompleted(day)
                        
                        VStack(spacing: 4) {
                            Text(weekdayShort(for: day))
                                .font(.caption2)
                            Text(dayNumberString(for: day))
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                        .padding(8)
                        .background(
                            Circle()
                                .stroke(completed ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.green.opacity(0.15) : Color.clear)
                                )
                        )
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    
    private var monthDate: Date {
        Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }
    
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let start = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        else { return [] }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func weekdayShort(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private func dayNumberString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
}
#Preview {
    MyRoutineView()
        .environmentObject(RoutineStore())
}
