//
//  ProfileView.swift
//  Jasmine
//
//
//import SwiftUI
//
//struct ProfileView: View {
//    @EnvironmentObject var session: SessionStore
//    @EnvironmentObject var routineStore: RoutineStore
//    @StateObject var vm = ProfileViewModel()
//    
//    @State private var showingEditNameSheet = false
//    
//    private let rowHeight: CGFloat = 52
//    @State private var showGuestAlert = false
//    @State private var goToLogin = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                
//                ZStack(alignment: .top) {
//                    Color.lightJasmine
//                        .frame(height: 240)
//                        .edgesIgnoringSafeArea(.top)
//                    
//                    VStack(spacing: 12) {
//                        VStack(spacing: 6) {
//                            Image(systemName: "person.crop.circle")
//                                .font(.system(size: 70))
//                                .foregroundColor(.black)
//                                .shadow(radius: 4)
//                            
//                            Text(vm.fullName.isEmpty ? "Guest" : vm.fullName)
//                                .font(.title3.bold())
//                                .foregroundColor(.black)
//                        }
//                    }
//                }
//                
//                VStack(alignment: .leading, spacing: 24) {
//                    
//                    Text("personal information")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundColor(.black.opacity(0.6))
//                        .padding(.horizontal)
//                    
//                    infoCard {
//                        Button {   if session.isGuest {          // ⭐
//                            showGuestAlert = true     // ⭐
//                        } else {
//                            showingEditNameSheet = true
//                        } }label: {
//                            editableRow(
//                                icon: "person.fill",
//                                title: "Name",
//                                value: vm.fullName.isEmpty ? "-" : vm.fullName
//                            )
//                        }
//                        .buttonStyle(.plain)
//                        
//                        divider
//                        
//                        row(
//                            icon: "envelope.fill",
//                            title: "Email",
//                            value: vm.email.isEmpty ? "-" : vm.email
//                        )
//                    }
//                    
//                    Text("preferences")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundColor(.black.opacity(0.6))
//                        .padding(.horizontal)
//                    
//                    infoCard {
//                        prefRow(
//                            icon: "star.fill",
//                            title: "Motivational Rewards",
//                            isOn: Binding(
//                                get: { vm.isRewardOn },
//                                set: { newValue in
//                                    if session.isGuest {              // ⭐
//                                        showGuestAlert = true         // ⭐
//                                    } else {
//                                        Task {
//                                            if let uid = session.userID {
//                                                await vm.updateRewardPreference(userId: uid, isOn: newValue)
//                                                routineStore.isRewardEnabled = newValue
//                                            }
//                                        }
//                                    }
//                                }
//                            ),
//                            isStar: true
//                        )
//                        
//                        divider
//                        
//                        prefRow(
//                            icon: "bell.fill",
//                            title: "Push Notifications",
//                            isOn: Binding(
//                                get: { vm.isNotificationOn },
//                                set: { newValue in
//                                    if session.isGuest {              // ⭐
//                                        showGuestAlert = true         // ⭐
//                                    } else {
//                                        Task {
//                                            if let uid = session.userID {
//                                                await vm.updateNotificationPreference(userId: uid, isOn: newValue)
//                                            }
//                                        }
//                                    }
//                                }
//                            ),
//                            isStar: false
//                        )
//                    }
//                    Button(role: .destructive) {
//                        if session.isGuest {              // ⭐
//                            showGuestAlert = true         // ⭐
//                        } else {
//                            Task { await session.signOut() }
//                        }
//
//                    } label: {
//                        Text("Log out")
//                            .font(.system(size: 16, weight: .semibold))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 12)
//                            .background(Color.white)
//                            .cornerRadius(16)
//                    }
//                    .padding(.horizontal)
//                    
//                    Spacer(minLength: 20)
//                }
//                .padding(.top, -40)
//            }
//            .background(Color.white.ignoresSafeArea())
//            .sheet(isPresented: $showingEditNameSheet) {
//                EditNameView(
//                    vm: vm,
//                    userId: session.userID ?? ""
//                )
//                .presentationDetents([.medium])
//            }
//        }
//        .alert("Sign in required", isPresented: $showGuestAlert) {
//            Button("Sign in") {
//             goToLogin = true
//            }
//            Button("Skip", role: .cancel) {}
//        } message: {
//            Text("You need to sign in to use this feature.")
//        }
//        .fullScreenCover(isPresented: $goToLogin) {
//            LoginView()                   // ⭐⭐ صفحة تسجيل الدخول
//                .environmentObject(session)
//        }
//        .task {
//            if let uid = session.userID {
//                await vm.loadUser(userId: uid)
//                routineStore.isRewardEnabled = vm.isRewardOn
//            }
//        }
//    }
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore
    @StateObject var vm = ProfileViewModel()
    
    @State private var showingEditNameSheet = false
    @State private var showGuestAlert = false
    @State private var goToLogin = false
    
    private let rowHeight: CGFloat = 52
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // 🌿 خلفية Gradient — التصميم المطلوب
                LinearGradient(
                    colors: [
                        Color(red: 153/255, green: 188/255, blue: 148/255),
                        Color(red: 238/255, green: 246/255, blue: 236/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // MARK: - Header
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 90))
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                            
                            Text(vm.fullName.isEmpty ? "Guest" : vm.fullName)
                                .font(.title2.bold())
                                .foregroundColor(.black)
                            
                            if !session.isGuest {
                                Text(vm.email)
                                    .foregroundColor(.black.opacity(0.85))
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, 50)
                        
                        
                        // MARK: - Personal Information
                        sectionTitle("personal information")
                        
                        infoCard {
                            Button {
                                if session.isGuest { showGuestAlert = true }
                                else { showingEditNameSheet = true }
                            } label: {
                                editableRow(
                                    icon: "person.fill",
                                    title: "Name",
                                    value: vm.fullName.isEmpty ? "-" : vm.fullName
                                )
                            }
                            .buttonStyle(.plain)
                            
                            divider
                            
                            row(
                                icon: "envelope.fill",
                                title: "Email",
                                value: vm.email.isEmpty ? "-" : vm.email
                            )
                        }
                        
                        
                        // MARK: - Preferences
                        sectionTitle("preferences")
                        
                        infoCard {
                            prefRow(
                                icon: "star.fill",
                                title: "Motivational Rewards ",
                                isOn: Binding(
                                    get: { vm.isRewardOn },
                                    set: { newValue in
                                        if session.isGuest { showGuestAlert = true }
                                        else {
                                            Task {
                                                if let uid = session.userID {
                                                    await vm.updateRewardPreference(userId: uid, isOn: newValue)
                                                    routineStore.isRewardEnabled = newValue
                                                }
                                            }
                                        }
                                    }
                                ),
                                isStar: true
                            )
                            
                            divider
                            
                            prefRow(
                                icon: "bell.fill",
                                title: "Push Notifications",
                                isOn: Binding(
                                    get: { vm.isNotificationOn },
                                    set: { newValue in
                                        if session.isGuest { showGuestAlert = true }
                                        else {
                                            Task {
                                                if let uid = session.userID {
                                                    await vm.updateNotificationPreference(userId: uid, isOn: newValue)
                                                }
                                            }
                                        }
                                    }
                                ),
                                isStar: false
                            )
                        }
                        
                        
                        // MARK: Logout Button (بستايل Apple)
                        Button(role: .destructive) {
                            if session.isGuest { showGuestAlert = true }
                            else {
                                Task { await session.signOut() }
                            }
                        } label: {
                            Text("Log out")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(22)
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            
            // MARK: - Alerts
            .alert("Sign in required", isPresented: $showGuestAlert) {
                Button("Sign in") { goToLogin = true }
                Button("Skip", role: .cancel) {}
            } message: {
                Text("You need to sign in to use this feature.")
            }
            
            // MARK: - Login Redirect
            .fullScreenCover(isPresented: $goToLogin) {
                LoginView().environmentObject(session)
            }
            
            // MARK: - Edit Name Sheet
            .sheet(isPresented: $showingEditNameSheet) {
                EditNameView(vm: vm, userId: session.userID ?? "")
                    .presentationDetents([.fraction(0.4)])
            }
            
            // MARK: - Load profile info
            .task {
                if let uid = session.userID {
                    await vm.loadUser(userId: uid)
                    routineStore.isRewardEnabled = vm.isRewardOn
                }
            }
        }.navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)

    }

    func sectionTitle(_ text: String) -> some View {
        Text(text.capitalized)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.black.opacity(0.8))   // ← اسود بدلاً من أبيض
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)               // ← أقرب للبوكس
            .padding(.bottom, -20)                      // ← مسافة بسيطة فوقه
    }


    
    func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.95))
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 4)
        
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.black.opacity(0.1))
            .frame(height: 1)
            .padding(.leading, 48)
    }
    
    func row(icon: String, title: String, value: String) -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                .foregroundColor(.black)
                Text(title)            }
            .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.black.opacity(0.8))
        }
        .font(.system(size: 15))
        .frame(height: 52)
        .padding(.horizontal, 18)
    }
    
    func editableRow(icon: String, title: String, value: String) -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.black)
                Text(title)
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.black.opacity(0.7))
            
            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.3))
        }
        .font(.system(size: 15))
        .frame(height: 52)
        .padding(.horizontal, 18)
    }
    
    func prefRow(icon: String, title: String, isOn: Binding<Bool>, isStar: Bool) -> some View {
        HStack {
                Image(systemName: icon)
                    .foregroundColor(isStar ? Color.yellow : .black)
                
                Text(title)
                    .foregroundColor(.black)
            
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(Color.jasmineGreen)
        }
        .frame(height: 52)
        .padding(.horizontal, 18)
    }
}

struct EditNameView: View {
    @ObservedObject var vm: ProfileViewModel
    let userId: String

    @State private var newName: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                Text("Edit Your Full Name")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("New Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                TextField("Enter full name...", text: $newName)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 15)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 30)
            .onAppear {
                newName = vm.fullName
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let name = newName
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        guard !name.isEmpty else { return }

                        Task {
                            await vm.updateName(userId: userId, fullName: name)
                            dismiss()
                        }
                    }
                    .foregroundColor(.black)
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(SessionStore())
        .environmentObject(RoutineStore())
}
