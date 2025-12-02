//
//  ProfileView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 12/2/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore
    @StateObject var vm = ProfileViewModel()
    
    @State private var showingEditNameSheet = false
    
    private let cardBackground = Color(red: 243/255, green: 247/255, blue: 232/255)
    private let cardCornerRadius: CGFloat = 20
    private let rowHeight: CGFloat = 52
    private let headerColor = Color(red: 243/255, green: 255/255, blue: 232/255)
    private let toggleColor = Color(red: 153/255, green: 188/255, blue: 148/255)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Header
                ZStack(alignment: .top) {
                    // الخلفية تغطي أعلى الشاشة
                    headerColor
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 14) {
                        // Title + buttons
                        HStack {
                            Text("Profile")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            NavigationLink {
                                MyRoutineView()
                            } label: {
                                topButton(icon: "list.bullet")
                            }
                            
                            NavigationLink {
                                ActivityView()
                            } label: {
                                topButton(icon: "house.fill")
                            }
                        }
                        .padding(10)   // نفس الـ padding في ActivityView
                        
                        // Avatar + name
                        VStack(spacing: 6) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 70))
                            
                            Text(vm.fullName.isEmpty ? "Guest" : vm.fullName)
                                .font(.title2.bold())
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    // نرفع كل الهيدر فوق عشان يطابق التصميم
                    .padding(.top, -28)
                }
                .frame(height: 195)
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        Text("personal information")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal)
                        
                        personalInfoCard(
                            name: vm.fullName,
                            email: vm.email
                        )
                        
                        Text("preferences")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal)
                        
                        preferencesCard(
                            isRewardOn: $routineStore.isRewardEnabled,
                            isNotificationOn: $vm.notificationsEnabled
                        )
                        .onChange(of: vm.notificationsEnabled) { newValue in
                            if newValue { vm.requestNotificationPermission() }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 25)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .sheet(isPresented: $showingEditNameSheet) {
                EditNameView(vm: vm)
                    .presentationDetents([.medium])
            }
        }
        .task {
            await vm.checkNotificationStatus()
            if let uid = session.userID {
                await vm.loadUser(userId: uid)
            }
        }
    }
    
    // MARK: - Components
    
    // نفس تصميم زر الهيدر في ActivityView بالضبط
    func topButton(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(.black)
            .frame(width: 38, height: 38)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.trailing, 4)
    }
    
    func personalInfoCard(name: String, email: String) -> some View {
        VStack(spacing: 0) {
            
            Button {
                showingEditNameSheet = true
            } label: {
                editableInfoRowContent(
                    icon: "person.fill",
                    title: "Name",
                    value: name.isEmpty ? "-" : name
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
                .padding(.leading, 48)
            
            infoRowContent(
                icon: "envelope.fill",
                title: "Email",
                value: email.isEmpty ? "-" : email
            )
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(Color.black.opacity(0.05), lineWidth: 0.8)
                )
        )
        .padding(.horizontal)
    }
    
    func infoRowContent(icon: String, title: String, value: String) -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.black.opacity(0.7))
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(height: rowHeight)
        .padding(.horizontal, 18)
    }
    
    func editableInfoRowContent(icon: String, title: String, value: String) -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.black.opacity(0.7))
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black.opacity(0.3))
        }
        .frame(height: rowHeight)
        .padding(.horizontal, 18)
    }
    
    func preferencesCard(
        isRewardOn: Binding<Bool>,
        isNotificationOn: Binding<Bool>
    ) -> some View {
        VStack(spacing: 0) {
            prefRow(
                icon: "star.fill",
                title: "Motivational Rewards",
                isOn: isRewardOn,
                isStar: true
            )
            
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
                .padding(.leading, 48)
            
            prefRow(
                icon: "bell.fill",
                title: "Push Notifications",
                isOn: isNotificationOn,
                isStar: false
            )
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(Color.black.opacity(0.05), lineWidth: 0.8)
                )
        )
        .padding(.horizontal)
    }
    
    func prefRow(
        icon: String,
        title: String,
        isOn: Binding<Bool>,
        isStar: Bool
    ) -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(
                        isStar
                        ? Color(red: 255/255, green: 204/255, blue: 0/255)
                        : .black.opacity(0.7)
                    )
                    .font(.system(size: 18))
                
                Text(title)
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(toggleColor)
        }
        .frame(height: rowHeight)
        .padding(.horizontal, 18)
    }
    
    
    struct EditNameView: View {
        @ObservedObject var vm: ProfileViewModel
        @State private var newName: String = ""
        @Environment(\.dismiss) var dismiss
        
        private let saveButtonColor = Color(red: 153/255, green: 188/255, blue: 148/255)
        private let fieldBorderColor = Color(red: 153/255, green: 188/255, blue: 148/255).opacity(0.8)
        
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(fieldBorderColor, lineWidth: 2)
                        )
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
                            vm.fullName = newName
                            dismiss()
                        }
                        .foregroundColor(.black)
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
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
