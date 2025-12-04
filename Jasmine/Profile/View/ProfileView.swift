//
//  ProfileView.swift
//  Jasmine
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore
    @StateObject var vm = ProfileViewModel()
    
    @State private var showingEditNameSheet = false
    
    private let rowHeight: CGFloat = 52
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ZStack(alignment: .top) {
                    Color.lightJasmine
                        .frame(height: 220)
                        .edgesIgnoringSafeArea(.top)
                    
                    VStack(spacing: 12) {
                        
                       
                        
                        VStack(spacing: 6) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 70))
                                .foregroundColor(.black)
                                .shadow(radius: 4)
                            
                            Text(vm.fullName.isEmpty ? "Guest" : vm.fullName)
                                .font(.title3.bold())
                                .foregroundColor(.black)
                        }
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Text("personal information")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal)
                        
                        infoCard {
                            Button { showingEditNameSheet = true } label: {
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
                        
                        Text("preferences")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal)
                        
                        infoCard {
                            prefRow(
                                icon: "star.fill",
                                title: "Motivational Rewards",
                                isOn: $routineStore.isRewardEnabled,
                                isStar: true
                            )
                            
                            divider
                            
                            prefRow(
                                icon: "bell.fill",
                                title: "Push Notifications",
                                isOn: $vm.notificationsEnabled,
                                isStar: false
                            )
                        }
                        .onChange(of: vm.notificationsEnabled) { newValue in
                            if newValue { vm.requestNotificationPermission() }
                        }
                        
                    }
                    .padding(.top, 18)
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
    
    func topButton(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(.black)
            .frame(width: 38, height: 38)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .background(Color.lightJasmine)
        .cornerRadius(20)
        .padding(.horizontal)
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
                Text(title)
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(width: 110, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.black)
        }
        .font(.system(size: 15))
        .frame(height: rowHeight)
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
            .frame(width: 110, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.black.opacity(0.7))
            
            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.3))
        }
        .font(.system(size: 15))
        .frame(height: rowHeight)
        .padding(.horizontal, 18)
    }
    
    func prefRow(icon: String, title: String, isOn: Binding<Bool>, isStar: Bool) -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(isStar ? Color.yellow : .black)
                
                Text(title)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(Color.jasmineGreen)
        }
        .frame(height: rowHeight)
        .padding(.horizontal, 18)
    }
}

struct EditNameView: View {
    @ObservedObject var vm: ProfileViewModel
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

#Preview {
    ProfileView()
        .environmentObject(SessionStore())
        .environmentObject(RoutineStore())
}
