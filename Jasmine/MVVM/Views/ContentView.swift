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

struct ContentView: View {
    // الصوره الي اختارها
    @State private var selectedItem: PhotosPickerItem? = nil
    // الصوره الي اختارها بعد تحويلها ل uiimage
    @State private var selectedImage: UIImage? = nil
    @State private var isLoading = false
    // النتيجة الي تجينا من ال fastapi
    @State private var result: PredictResponse? = nil
    @State private var step: Int = 1
    @State private var errorMsg: String? = nil

    @State private var saveToHistory = false
    @State private var isSaving = false
    @State private var infoMsg: String? = nil
    @State private var goToActivity = false

    let onSignOut: () async -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                HStack(spacing: 30) {
                    // الدوائر الخضراء الي تطلع فوق الشاشه
                    ForEach(1...3, id: \.self) { i in
                        VStack {
                            Image(systemName: i <= step ? "circle.fill" : "circle")
                                .foregroundColor(i <= step ? .green : .gray)
                            Text("Step \(i)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // STEP 1 = يحط الصورة
                if step == 1 {
                    VStack(spacing: 16) {
                        Text("Upload Photo")
                            .font(.title2).bold()
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            VStack {
                                Image(systemName: "icloud.and.arrow.up")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                Text("Tap to upload photo")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 250, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                            )
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                        
                        if let selectedImage {
                            // بعد ما اختار وحط الصوره بنعدل مكانها وحجمها بالواجهه
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 160)
                                .cornerRadius(12)
                        }
                        
                        Button("Continue") {
                            step = 2
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(selectedImage == nil)
                    }
                }
                
                // STEP 2 = التحليل
                else if step == 2 {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Analyzing...")
                                .font(.title2)
                                .bold()
                            
                            if isLoading {
                                ProgressView()
                                // اذا فعلا ال fastapi طلعت لنا بنتيجة
                            } else if let result = result {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Predicted Condition:")
                                        .font(.headline)
                                    Text(result.top1.label.capitalized)
                                        .foregroundColor(.green)
                                        .font(.headline)
                                    
                                    Divider()
                                    // اذا التشات جبتي فعلا رجع شرح
                                    if let expl = result.chatgpt_explanation, !expl.isEmpty {
                                        Text("Explanation of the Disease")
                                            .font(.headline)
                                        Text(expl)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                        Divider()
                                    }
                                    
                                    Button("Continue") {
                                        step = 3
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                }
                            } else {
                                // ماتحملت الصوره او ماعندنا شرح للحاله
                                Button("Analyze Photo") {
                                    Task { await analyze() }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .disabled(selectedImage == nil)
                                
                                if let errorMsg {
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
                        if result == nil, selectedImage != nil, !isLoading {
                            await analyze()
                        }
                    }
                }
                
                // STEP 3
                else if step == 3 {
                    VStack(spacing: 16) {
                        Text("Save your result to history.")
                            .font(.title3)
                            .padding(.top)
                        
                        Toggle("Save to history", isOn: $saveToHistory)
                            .tint(.green)
                            .padding(.horizontal)
                        
                        if isSaving {
                            ProgressView()
                        }
                        
                        if let infoMsg {
                            Text(infoMsg)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .padding(.top, 6)
                        
                        HStack(spacing: 12) {
//                            Button("Finish") {
//                                Task { await SaveToHistory() }
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .tint(.green)
//                            .disabled(isSaving)
                            Button("Finish") {
                                Task {
                                    await SaveToHistory()
                                    
                                    await MainActor.run {
                                        goToActivity = true
                                    }
                                }}.buttonStyle(.borderedProminent)
                                    .tint(.green)
                                
                            Button("Start New Analysis") {
                                step = 1
                                result = nil
                                selectedImage = nil
                                errorMsg = nil
                                infoMsg = nil
                                saveToHistory = false
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 6)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Jasmine")
            .navigationDestination(isPresented: $goToActivity) {
                ActivityView()
            }

        }
    }

    func analyze() async {
        // 1)  تأكيد وجود صورة مختارة من اليوزر
        guard let selectedImage else {
            errorMsg = "Please select a photo first."
            return
        }
        isLoading = true
        errorMsg = nil
        defer { isLoading = false }

        do {
            //  أرسل الصورة وانتظر الرد( 2
            let res = try await SkinAPIService.shared.predict(image: selectedImage, topk: 1)
            self.result = res
        } catch {
            // 3) خزّن النتيجة لعرضها في Step 2

            self.result = nil
            self.errorMsg = error.localizedDescription
            print("❌ Error:", error.localizedDescription)
        }
    }

    func SaveToHistory() async {
        guard saveToHistory else {
            infoMsg = "Skipped saving. You can enable the toggle to save next time."
            return
        }
        guard let img = selectedImage else {
            infoMsg = "No image to save."
            return
        }
        isSaving = true
        defer { isSaving = false }

        do {
            #if canImport(Supabase)
            // 1) ارفعي الصورة على Storage
            let fileName = "\(UUID().uuidString).jpg"
            guard let data = img.jpegData(compressionQuality: 0.9) else {
                infoMsg = "Failed to encode image."
                return
            }

            let storage = Supa.client.storage.from("skin-images")
            _ = try await storage.upload(
                path: fileName,
                file: data,
                options: FileOptions(contentType: "image/jpeg", upsert: true) // حدّدنا النوع لتجنب "Cannot infer contextual base"
            )

            let publicURL = try storage.getPublicURL(path: fileName).absoluteString
            _ = publicURL

            let userId: String
            if let session = try? await Supa.client.auth.session {
                userId = session.user.id.uuidString
            } else if let session = Supa.client.auth.currentSession {
                userId = session.user.id.uuidString
            } else {
                infoMsg = "Saved file. Login required to write DB row."
                return
            }


            struct Row: Encodable {
                let imageid: String
                let userid: String
                let uploaddate: String
                let storagepath: String
            }

            let row = Row(
                imageid: UUID().uuidString,
                userid: userId,
                uploaddate: isoDateString(Date()),
                storagepath: fileName
            )

            try await Supa.client
                .from("skin_images")
                .insert(row)
                .execute()

            infoMsg = "Saved to history ✅"
            #else
            infoMsg = "Supabase SDK not linked. Skipped save."
            #endif
        } catch {
            infoMsg = "Save failed: \(error.localizedDescription)"
        }
    }

    func isoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(onSignOut: { })
    }
}
