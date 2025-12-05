//
//  ActivityView.swift
//  Jasmine
//
//  Created by lamess on 08/06/1447 AH.
//
import SwiftUI
import Combine
import Supabase

struct ActivityView: View {

    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore

    @StateObject var vm = ActivityViewModel()

    var body: some View {
        NavigationView {
            ZStack {

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: Header
                        HStack {
                            Text("Activity")
                                .font(.largeTitle.bold())
                                .padding(.horizontal)
                            Spacer()

                            NavigationLink {
                                MyRoutineView()
                            } label: {
                                topButton(icon: "list.bullet")
                            }

                            NavigationLink {
                                ProfileView()
                            } label: {
                                topButton(icon: "person.fill")
                            }
                        }
                        .padding(.top, 10)

                        // MARK: Reward Card
                        rewardCard

                        // MARK: Scan Button
                        NavigationLink(destination: ContentView(onSignOut: { })) {
                            scanCard
                        }

                        // MARK: History Section
                        Text("Your History")
                            .font(.title3.bold())
                            .padding(.horizontal)

                        VStack(spacing: 14) {
                            if vm.loading {
                                ProgressView()
                                    .padding(.top)
                            } else {
                                ForEach(vm.history) { item in
                                    historyCell(item)
                                        .onTapGesture { vm.openDetails(item) }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
                .navigationBarHidden(true)

                // MARK: Popup View
                if vm.showPopUp, let selected = vm.selectedEntry {
                    LargeHistoryPopUp(entry: selected) {
                        vm.closePopUp()
                    }
                    .zIndex(20).transition(.scale.combined(with: .opacity))
                }

            }
            .onAppear {
                Task {
                    do {
                        let session = try await Supa.client.auth.session
                        let uid = session.user.id.uuidString

                        print("🟢 Logged User:", uid)

                        await vm.loadHistory(userId: uid)

                    } catch {
                        print("❌ No active session:", error.localizedDescription)
                    }
                }
            }


//            .onAppear {
//                Task {
//                    if let uid = session.userID {
//                        await vm.loadHistory(userId: uid)
//                    }
//                }
//            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Reusable Top Button
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

    // MARK: Reward Card
    var rewardCard: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Reward Points")
                .foregroundColor(.black.opacity(0.6))

            HStack(spacing: 6) {
                Text("\(routineStore.totalPoints)")
                    .font(.title2.bold())
                
                Text("/ 500 Points to reach Gold Tier")
                    .foregroundColor(.gray)
            }

            ProgressView(value: 0)
                .tint(Color.green)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.22),
                    Color.green.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal)
    }

    // MARK: Scan Card
    var scanCard: some View {
        HStack {
            Image(systemName: "hand.tap")
                .font(.system(size: 26))
                .foregroundColor(.black)

            Text("Skin your scan now!")
                .font(.headline)
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 22).fill(.white))
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }

    // MARK: History Cell
    func historyCell(_ item: UserHistory) -> some View {
        HStack(spacing: 14) {

            Image(systemName: item.isClear ? "checkmark.circle.fill" : "cross.circle.fill")
                .foregroundColor(item.isClear ? .green : .red)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.condition.capitalized)
                    .font(.headline)

                Text("Date: \(item.formattedDate)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(.white))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 3)
    }
}

#Preview {
    ActivityView()
        .environmentObject(SessionStore())
        .environmentObject(RoutineStore())

}
