import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore
    @Environment(\.dismiss) private var dismiss

    @StateObject var vm = ProfileViewModel()

    @State private var showingEditNameSheet = false
    @State private var showGuestAlert = false
    @State private var goToLogin = false

    var body: some View {
            ZStack {

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

                        sectionTitle("preferences")

                        infoCard {

                            prefRow(
                                icon: "star.fill",
                                title: "Motivational Rewards",
                                isOn: Binding(
                                    get: { vm.isRewardOn },
                                    set: { newValue in
                                        if session.isGuest { showGuestAlert = true; return }

                                        vm.isRewardOn = newValue
                                        routineStore.isRewardEnabled = newValue

                                        Task {
                                            if let uid = session.userUUID {
                                                await vm.updateRewardPreference(userId: uid, isOn: newValue)
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
                                        if session.isGuest { showGuestAlert = true; return }

                                        vm.isNotificationOn = newValue

                                        Task {
                                            if newValue {
                                                let granted = await NotificationManager.shared.requestPermission()
                                                if granted {
                                                    NotificationManager.shared.scheduleRoutineReminder()
                                                } else {
                                                    vm.isNotificationOn = false
                                                    return
                                                }
                                            } else {
                                                NotificationManager.shared.cancelRoutineReminder()
                                            }

                                            if let uid = session.userUUID {
                                                await vm.updateNotificationPreference(userId: uid, isOn: vm.isNotificationOn)
                                            }
                                        }
                                    }
                                ),
                                isStar: false
                            )
                        }

                        if !session.isGuest {
                            Button(role: .destructive) {
                                Task { await session.signOut() }
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
            }
           
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.35)))
                    }
                }
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
                    .environmentObject(routineStore)
            }

            .sheet(isPresented: $showingEditNameSheet) {
                if let uid = session.userUUID {
                    EditNameView(vm: vm, userId: uid)
                        .presentationDetents([.fraction(0.4)])
                }
            }

            .task {
                if let uid = session.userUUID {
                    await vm.loadUser(userId: uid)
                    routineStore.isRewardEnabled = vm.isRewardOn
                }
            }
        }
    }


    func sectionTitle(_ text: String) -> some View {
        Text(text.capitalized)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.black.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.bottom, -20)
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

    var divider: some View {
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
            }
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
                .foregroundColor(isStar ? .yellow : .black)

            Text(title)
                .foregroundColor(.black)

            Spacer()

            Toggle("", isOn: isOn)
                .tint(Color.jasmineGreen)
        }
        .frame(height: 52)
        .padding(.horizontal, 18)
        .contentShape(Rectangle())
    }


struct EditNameView: View {
    @ObservedObject var vm: ProfileViewModel
    let userId: UUID

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
            .onAppear { newName = vm.fullName }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
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
