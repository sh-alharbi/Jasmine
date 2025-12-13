import SwiftUI

struct MyRoutineView: View {
    @EnvironmentObject var store: RoutineStore
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss


    @State private var selectedDate: Date = Date()
    @State private var showAddSheet = false
    @State private var editingRoutine: Routine? = nil
    @State private var showFullCalendar = false
    @State private var showMonthPicker = false

    @State private var showPointsAlert = false

    @State private var showGuestAlert = false
    @State private var goToLogin = false
    @State private var path: [Route] = []
    @State private var showProfile = false


    @State private var didTryShowAlertForCurrentUser = false

    enum Route: Hashable {
        case profile
    }

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var todaysRoutines: [Routine] {
        store.routines(for: selectedDate)
    }

    private func handleToggle(_ routine: Routine) {
        if session.isGuest {
            showGuestAlert = true
            return
        }
        guard session.userID != nil else { return }
        store.toggleDone(id: routine.id)
    }

    private func handleEditTap(_ routine: Routine) {
        if session.isGuest {
            showGuestAlert = true
        } else {
            editingRoutine = routine
        }
    }

    private func rewardsAlertKey(for userId: UUID) -> String {
        "didShowRewardsActivationAlert.\(userId.uuidString)"
    }

    private func hasShownRewardsAlertEver(for userId: UUID) -> Bool {
        UserDefaults.standard.bool(forKey: rewardsAlertKey(for: userId))
    }

    private func markRewardsAlertShown(for userId: UUID) {
        UserDefaults.standard.set(true, forKey: rewardsAlertKey(for: userId))
    }

    private func maybeShowRewardsAlertOnceEver() async {
        guard !session.isGuest else { return }
        guard let userId = session.userID else { return }
        guard !didTryShowAlertForCurrentUser else { return }
        didTryShowAlertForCurrentUser = true

        await store.loadRewardPoints()

        guard !store.isRewardEnabled else { return }
        guard !hasShownRewardsAlertEver(for: userId) else { return }

        markRewardsAlertShown(for: userId)
        showPointsAlert = true
    }


    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection

                    Text(Calendar.current.isDate(selectedDate, inSameDayAs: today) ? "Routines for today" : "Routines for selected day")
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
                                        onToggleDone: { handleToggle(routine) }
                                    )
                                    .padding(.horizontal, 24)
                                    .contentShape(Rectangle())
                                    .onTapGesture { handleEditTap(routine) }
                                }
                            }

                            Spacer()
                                .frame(height: 10)
                                .padding(.top, 8)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .background(Color.white.ignoresSafeArea())
                .navigationTitle("My Routine")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showFullCalendar = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .frame(width: 38, height: 38)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                }

                Button {
                    if session.isGuest {
                        showGuestAlert = true
                    } else {
                        showAddSheet = true
                    }
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
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .profile:
                    ProfileView()
                        .environmentObject(session)
                        .environmentObject(store)
                }
            }
            .onAppear {
                selectedDate = today
                Task { await maybeShowRewardsAlertOnceEver() }
            }
            .onChange(of: session.userID) { _ in
                didTryShowAlertForCurrentUser = false
                Task { await maybeShowRewardsAlertOnceEver() }
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
            .sheet(isPresented: $showMonthPicker) {
                MonthPickerView(selectedDate: $selectedDate)
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
            }
            .alert("Sign up required", isPresented: $showGuestAlert) {
                Button("Sign up") { goToLogin = true }
                Button("Skip", role: .cancel) {}
            } message: {
                Text("You need to sign up to use this feature.")
            }
            .fullScreenCover(isPresented: $goToLogin) {
                LoginView()
                    .environmentObject(session)
                    .environmentObject(store)
            }
            .overlay {
                if showPointsAlert {
                    ZStack {
                        Color.black.opacity(0.25).ignoresSafeArea()
                        pointsActivationAlert
                    }
                }
            }
        }
    }

    private var pointsActivationAlert: some View {
        VStack(spacing: 16) {
            Text("Enjoy Extra Motivation ✨")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Want a small boost while completing your routines? You can turn on motivational rewards from your profile whenever you’re ready.")
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.leading)

            HStack(spacing: 12) {
                Button {
                    withAnimation { showPointsAlert = false }
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                }

                Button {
                    showPointsAlert = false
                    showProfile = true
                } label: {
                    Text("Profile")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.20), radius: 18, x: 0, y: 10)
        )
        .padding(.horizontal, 32)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(monthYearString(for: monthDate))
                    .font(.system(size: 20, weight: .bold))
                    .onTapGesture { showMonthPicker = true }

                HStack(spacing: 4) {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }

                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .disabled(isAtCurrentMonth)
                    .opacity(isAtCurrentMonth ? 0.3 : 1)
                }

                Spacer()

                Text("\(store.totalPoints) points")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(Color.jasmineGreen)
                            .shadow(color: Color.jasmineGreen.opacity(0.25), radius: 8, x: 0, y: 4)
                    )
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(daysInMonth, id: \.self) { day in
                            let calendar = Calendar.current
                            let startOfDay = calendar.startOfDay(for: day)
                            let isToday = calendar.isDate(startOfDay, inSameDayAs: today)
                            let completed = store.isDayCompleted(day)

                            let backgroundColor: Color = {
                                if completed {
                                    return Color(red: 1.0, green: 0.98, blue: 0.85)
                                } else if isToday {
                                    return Color.jasmineGreen
                                } else {
                                    return .white
                                }
                            }()

                            VStack(spacing: 4) {
                                Text(weekdayShort(for: day))
                                    .font(.caption2)

                                Text(dayNumberString(for: day))
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(backgroundColor))
                            .foregroundColor((isToday && !completed) ? .white : .black)
                            .id(startOfDay)
                            .onTapGesture {
                                if startOfDay <= today {
                                    selectedDate = startOfDay
                                }
                            }
                            .opacity(startOfDay <= today ? 1 : 0.35)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(Calendar.current.startOfDay(for: selectedDate), anchor: .center)
                    }
                }
                .onChange(of: selectedDate) { newValue in
                    DispatchQueue.main.async {
                        proxy.scrollTo(Calendar.current.startOfDay(for: newValue), anchor: .center)
                    }
                }
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.8)
                )
                .sheet(isPresented: $showProfile) {
                    NavigationStack {
                        ProfileView()
                            .environmentObject(session)
                            .environmentObject(store)
                    }
                }


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

    private var isAtCurrentMonth: Bool {
        let calendar = Calendar.current
        let thisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        return monthDate == thisMonth
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
        guard let newDate = calendar.date(byAdding: .month, value: value, to: monthDate) else { return }

        let thisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let newMonth  = calendar.date(from: calendar.dateComponents([.year, .month], from: newDate))!

        if newMonth > thisMonth { return }

        var comps = calendar.dateComponents([.year, .month], from: newDate)
        comps.day = 1
        selectedDate = calendar.date(from: comps) ?? newDate
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

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(monthsToShow, id: \.self) { monthStart in
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
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }

    private var monthsToShow: [Date] {
        let calendar = Calendar.current
        let startYear = 2025
        let endYear = 2026

        var months: [Date] = []
        for year in startYear...endYear {
            for month in 1...12 {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
                    months.append(date)
                }
            }
        }
        return months
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
                        Rectangle().fill(Color.clear).frame(height: 28)
                    }
                }
            }
        }
    }

    private func dayCell(for day: Date) -> some View {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let isToday = calendar.isDate(startOfDay, inSameDayAs: today)
        let completed = store.isDayCompleted(day)
        let isFuture = startOfDay > today

        let backgroundColor: Color = {
            if completed {
                return Color(red: 1.0, green: 0.98, blue: 0.85)
            } else if isToday {
                return Color.jasmineGreen
            } else {
                return .clear
            }
        }()

        return VStack {
            Text(dayNumberString(for: day))
                .font(.body)
                .fontWeight(.semibold)
                .frame(width: 44, height: 44)
                .background(Circle().fill(backgroundColor))
                .foregroundColor(isToday && !completed ? .white : .black)
                .contentShape(Circle())
                .opacity(isFuture ? 0.35 : 1)
                .onTapGesture {
                    guard !isFuture else { return }
                    selectedDate = startOfDay
                    dismiss()
                }
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

struct MonthPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    @State private var tempDate: Date

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        _tempDate = State(initialValue: selectedDate.wrappedValue)
    }

    private var minDate: Date {
        Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
    }

    private var maxDate: Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31)) ?? Date()
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $tempDate,
                    in: minDate...maxDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 300)

                Spacer()
            }
            .padding()
            .navigationTitle("Select date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let calendar = Calendar.current
                        var comps = calendar.dateComponents([.year, .month], from: tempDate)
                        comps.day = 1
                        selectedDate = calendar.date(from: comps) ?? tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MyRoutineView()
        .environmentObject(RoutineStore())
        .environmentObject(SessionStore())
}
