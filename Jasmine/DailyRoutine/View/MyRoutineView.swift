//
//  MyRoutineView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/26/25.
//

import SwiftUI


struct MyRoutineView: View {
    @EnvironmentObject var store: RoutineStore
    
    @State private var selectedDate: Date = Date()
    @State private var showAddSheet = false
    @State private var editingRoutine: Routine? = nil
    @State private var showFullCalendar = false
    
    private var todaysRoutines: [Routine] {
        store.routines(for: selectedDate)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("My Routine")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
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
            .background(
                Color.white
                    .ignoresSafeArea()
            )
            
            Button {
                showAddSheet = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.jasmineGreen)
                        .frame(width: 60, height: 60)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .bold))
                }
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
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
        .sheet(isPresented: $showFullCalendar) {
            FullRoutineCalendarView(selectedDate: $selectedDate)
                .environmentObject(store)
        }
    }
    
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack(spacing: 8) {
                Text(monthYearString(for: monthDate))
                    .font(.headline)
                    .onTapGesture {
                        showFullCalendar = true
                    }
                
                HStack(spacing: 4) {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                Text("\(store.totalPoints) points")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(
                        Capsule()
                            .fill(Color.jasmineGreen)
                            .shadow(color: Color.jasmineGreen.opacity(0.25),
                                    radius: 6, x: 0, y: 3)
                    )
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
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.jasmineGreen : Color.white)
                                .overlay(
                                    Circle().stroke(
                                        completed || isSelected
                                        ? Color.jasmineGreen
                                        : Color.jasmineGreen.opacity(0.7),
                                        lineWidth: completed ? 2.5 : 1.5
                                    )
                                )
                        )
                        .foregroundColor(isSelected ? .white : .black) // أسود لما مو محدد
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }
            }
        }
        .padding(.vertical, 26)   // كان 22
        .padding(.horizontal, 24) // كان 22
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
    
    
    
    private var monthDate: Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        return calendar.date(from: comps) ?? Date()
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
    
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: value, to: monthDate) {
            if let day = calendar.dateComponents([.day], from: selectedDate).day {
                var comps = calendar.dateComponents([.year, .month], from: newDate)
                comps.day = min(day, calendar.range(of: .day, in: .month, for: newDate)?.count ?? day)
                selectedDate = calendar.date(from: comps) ?? newDate
            } else {
                selectedDate = newDate
            }
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


struct FullRoutineCalendarView: View {
    @EnvironmentObject var store: RoutineStore
    @Binding var selectedDate: Date
    
    @Environment(\.dismiss) private var dismiss
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(monthsOfYear, id: \.self) { monthStart in
                        monthSection(for: monthStart)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    
    private func monthSection(for monthStart: Date) -> some View {
        let monthName = monthTitle(for: monthStart)
        let days = daysGrid(for: monthStart)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(monthName)
                .font(.headline)
                .padding(.horizontal, 4)
            
            HStack {
                ForEach(weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let day = days[index] {
                        dayCell(for: day)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 28)
                    }
                }
            }
        }
    }
    
    private func dayCell(for day: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
        let completed = store.isDayCompleted(day)
        
        return VStack {
            Text(dayNumberString(for: day))
                .font(.body)
                .fontWeight(.semibold)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.jasmineGreen : Color.clear)
                        .overlay(
                            Circle().stroke(
                                completed || isSelected
                                ? Color.jasmineGreen
                                : Color.jasmineGreen.opacity(0.7),
                                lineWidth: completed ? 2.2 : 1.3
                            )
                        )
                )
                .foregroundColor(isSelected ? .white : .black)
                .contentShape(Circle())
        }
        .onTapGesture {
            selectedDate = day
            dismiss()
        }
    }
    
    
    private var monthsOfYear: [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        
        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: year, month: month, day: 1))
        }
    }
    
    private func daysGrid(for monthDate: Date) -> [Date?] {
        let calendar = Calendar.current
        
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let start = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        else { return [] }
        
        let firstWeekdayOfMonth = calendar.component(.weekday, from: start)
        let firstWeekday = calendar.firstWeekday
        var leadingEmpty = firstWeekdayOfMonth - firstWeekday
        if leadingEmpty < 0 { leadingEmpty += 7 }
        
        var result: [Date?] = Array(repeating: nil, count: leadingEmpty)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: start) {
                result.append(date)
            }
        }
        return result
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayNumberString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func weekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols.map { $0.uppercased() }
    }
}

#Preview {
    MyRoutineView()
        .environmentObject(RoutineStore())
}
