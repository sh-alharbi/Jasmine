//
//  LargeHistoryPopUp.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
//
import SwiftUI
import Supabase

struct LargeHistoryPopUp: View {

    let entry: AnalysisHistoryJSON
    let onClose: () -> Void

    var body: some View {

        let parsed = ExplanationParser.parse(entry.explanation)

        ZStack {

            // Background (Apple dim)
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // IMAGE
                        if let imgPath = entry.imagePath {
                            SupabaseAsyncImage(path: imgPath)
                                .frame(maxWidth: .infinity)
                                .frame(height: 230)
                                .clipped()
                                .cornerRadius(20)
                        }

                        // Condition
                        Text(entry.label.capitalized)
                            .font(.title2.bold())
                            .foregroundColor(.green)

                        Divider()

                        // Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explanation of the Disease")
                                .font(.headline)

                            Text(parsed.explanation)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tips & Recommendations")
                                .font(.headline)

                            ForEach(parsed.tips, id: \.self) { tip in
                                HStack(alignment: .top) {
                                    Text("•")
                                    Text(tip)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Sources
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Sources")
                                .font(.headline)

                            ForEach(parsed.sources, id: \.self) { src in
                                HStack(alignment: .top) {
                                    Text("•")
                                    Text(src)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }

                // Close Button
                Button(action: onClose) {
                    Text("Close")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(20)
                        .padding()
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
            )
            .padding(.horizontal, 20)
        }
    }
}

// Helper
struct SupabaseAsyncImage: View {
    let path: String
    
    var body: some View {
        if let url = try? Supa.client.storage
            .from("skin-images")
            .getPublicURL(path: path) {
            
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    ProgressView()
                default:
                    Color.gray.opacity(0.2)
                }
            }
        } else {
            Color.gray.opacity(0.2)
        }
    }
}

