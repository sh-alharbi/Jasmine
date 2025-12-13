//
//  ContentView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/5/25.
//
import SwiftUI
import PhotosUI

#if canImport(Supabase)
import Supabase
#endif

struct AnalysisView: View {

    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore

     @State private var showAgeAlert = false
     @State private var showGuestSaveAlert = false
     @State private var pendingContinue = false
    @State private var goToLogin = false

    @StateObject private var vm = AnalysisViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    let darkGreen = Color(
        red: 31/255,
        green: 117/255,
        blue: 31/255
    )

    let midGreen = Color(
        red: 159/255,
        green: 203/255,
        blue: 154/255
    )


    let onSignOut: () async -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {


                HStack {
                    ForEach(1...3, id: \.self) { i in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(i <= vm.step ? midGreen : Color.gray.opacity(0.15))
                                    .frame(width: 50, height: 50)

                                Image(systemName: i == 1 ? "square.and.arrow.up"
                                     : i == 2 ? "doc.text"
                                     : "square.and.arrow.down")
                                    .foregroundColor(i <= vm.step ? darkGreen : .gray)
                            }

                            Text("Step \(i)")
                                .font(.caption)
                                .foregroundColor(.black)
                        }

                        if i != 3 {
                            Rectangle()
                                .fill(i < vm.step ? darkGreen : Color.gray.opacity(0.3))
                                .frame(width: 40, height: 2)
                        }
                    }
                }
                .padding(.bottom, 10)

                if vm.step == 1 {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("Upload Photo")
                            .font(.title2).bold()

                        PhotosPicker(selection: $selectedItem, matching: .images) {

                            ZStack {
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .frame(width: 300, height: 290)

                                if let img = vm.selectedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 290)
                                        .clipShape(RoundedRectangle(cornerRadius: 40))

                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(.white)
                                                .shadow(radius: 6)
                                                .padding(12)
                                        }
                                        Spacer()

                                        Text("Tap to change photo")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.white)
                                            .padding(.bottom, 14)
                                    }
                                    .frame(width: 300, height: 290)
                                    .background(
                                        LinearGradient(
                                            colors: [.black.opacity(0.35), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 40))
                                    )

                                } else {
                                    VStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(midGreen.opacity(0.25))
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "icloud.and.arrow.up")
                                                .font(.system(size: 26))
                                                .foregroundColor(darkGreen)
                                        }

                                        Text("Tap to upload photo")
                                            .font(.headline)
                                            .foregroundColor(darkGreen)

                                        Text("PNG, JPG")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            guard let newItem else { return }
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    vm.selectedImage = uiImage
                                }
                            }
                        }

                        
                        Spacer()

                   
                            .onChange(of: selectedItem) { newItem in
                                guard let newItem else { return }

                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        vm.selectedImage = uiImage
                                    }
                                }
                            }


                

                        Button("Continue") {
                            if session.isGuest && pendingContinue == false {
                                showAgeAlert = true
                            } else {
                                vm.step = 2
                            }                        }
                        .frame(maxWidth: 250)
                        .padding()
                        .background(Color(red: 153/255, green: 188/255, blue: 148/255))
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(28)
                        .padding(.top, 10)
                        .disabled(vm.selectedImage == nil)
                    }
                    Spacer()
                }
                

                else if vm.step == 2 {
                    ScrollView {
                        VStack(spacing: 16) {
                            Spacer()
                            
                            if vm.isLoading {
                                VStack(spacing: 12) {

                                    Text("Analyzing…")
                                        .font(.title2)
                                        .bold()
                                        .multilineTextAlignment(.center)

                                    ProgressView()

                                    Text("""
                            ⚠️ Disclaimer:
                            This analysis is generated by an experimental AI model and may not be 100% accurate. Do not rely on this result for medical decisions. Always consult a qualified dermatologist. This tool is intended for educational and research purposes only.
                            """)
                                    .font(.footnote)
                                    .foregroundColor(.red.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                                    .padding(.horizontal)
                                }
                            }

                            else if let result = vm.result {

                                VStack(alignment: .leading, spacing: 16) {

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Predicted Condition:")
                                            .font(.headline)

                                        Text(result.top1.label.capitalized)
                                            .font(.title3.bold())
                                            .foregroundColor(darkGreen)
                                    }

                                    Divider()

                                    VStack(alignment: .leading, spacing: 8) {
                                        Label("Explanation", systemImage: "doc.text")
                                            .font(.headline)

                                        Text(
                                            result.chatgpt_explanation?
                                                .section("Explanation")
                                                .cleanMarkdown() ?? ""
                                        )
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)
                                        .textSelection(.enabled)


                                    }

                                    Divider()

                                    VStack(alignment: .leading, spacing: 8) {
                                        Label("Tips", systemImage: "lightbulb")
                                            .font(.headline)

                                        Text(
                                            result.chatgpt_explanation?
                                                .section("Tips")
                                                .cleanMarkdown() ?? ""
                                        )
                                        .textSelection(.enabled)
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)


                                    }

                                    Divider()

                                    VStack(alignment: .leading, spacing: 8) {
                                        Label("Sources", systemImage: "link")
                                            .font(.headline)

                                        Text(
                                            linkify(
                                                result.chatgpt_explanation?
                                                    .section("Sources")
                                                    .cleanMarkdown() ?? ""
                                            )
                                        )
                                        .textSelection(.enabled)
                                        .font(.system(size: 15))


                                    }

                                    Button("Continue") {
                                        vm.step = 3
                                    }


                                    
                                    .padding(.top, 10)
                                    .frame(width: 250)
                                    .background(Color(red: 153/255, green: 188/255, blue: 148/255))
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .cornerRadius(28)
                                    
                                }

                            } else {
                                Button("Analyze Photo") {
                                    Task { await vm.analyze() }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .disabled(vm.selectedImage == nil)

                                if let errorMsg = vm.errorMsg {
                                    Text(errorMsg)
                                        .foregroundColor(.red)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                    }
                    .task {
                        if vm.result == nil,
                           vm.selectedImage != nil,
                           !vm.isLoading {
                            await vm.analyze()
                        }
                    }
                }

                else if vm.step == 3 {

                    VStack(spacing: 24) {

                        Spacer()

                        Text("Do you want to save this result to history?")
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)


                        Button("Save to History") {
                            if session.isGuest {
                                showGuestSaveAlert = true
                                return
                            }

                            Task {
                                guard let uid = session.userUUID else { return }
                                await vm.saveToHistory(userId: uid)
                            }
                        }

                            .frame(width: 250, height: 54)
                            .background(Color(red: 153/255, green: 188/255, blue: 148/255))
                            .foregroundColor(.white)
                            .font(.headline)
                            .cornerRadius(26)
                        
                        Button("Skip") {
                            vm.goToActivity = true
                        }

                        .frame(width: 250, height: 54)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .font(.headline)
                        .cornerRadius(26)

                        Spacer()
                    }
                }

                Spacer(minLength: 0)
            }
            .padding()
            
           

        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
        
        .fullScreenCover(isPresented: $vm.goToActivity) {
            ActivityView()
                .environmentObject(session)
                .environmentObject(routineStore)
        }
        .alert("Are you over 18 years old?", isPresented: $showAgeAlert) {
            Button("Yes") {
                pendingContinue = true
                vm.step = 2
            }
            Button("No", role: .cancel) {
                vm.resetAll()
                vm.goToActivity = true
            }
        }
        .alert("Sign up required", isPresented: $showGuestSaveAlert) {
            Button("Sign up") {
                goToLogin = true   
            }
            Button("Skip", role: .cancel) {
                vm.goToActivity = true
            }

        } message: {
            Text("Guests cannot save results. Please sign up to enable saving.")
        }
        .fullScreenCover(isPresented: $goToLogin) {
            LoginView()
                .environmentObject(session)
                .environmentObject(routineStore)
        }


    }
}

#Preview {
    AnalysisView(onSignOut: { })
        .environmentObject(SessionStore())
        .environmentObject(RoutineStore())
}

