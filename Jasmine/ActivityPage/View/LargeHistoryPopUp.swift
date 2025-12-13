//
//  LargeHistoryPopUp.swift
//  Jasmine
//
//  Created by lamess on 14/06/1447 AH.
//
import SwiftUI
import Foundation

struct LargeHistoryPopUp: View {

    let entry: UserHistory
    let onClose: () -> Void

    var body: some View {
        ZStack {

            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(alignment: .leading, spacing: 14) {

                HStack {
                    Text(entry.condition.capitalized)
                        .font(.headline)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    }
                }

                Divider()

                Text("Date: \(entry.formattedDate)")
                    .font(.caption)
                    .foregroundColor(.black)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        sectionView(
                            title: "Explanation",
                            icon: "doc.text",
                            text: clean(entry.explanation)
                        )

                        sectionView(
                            title: "Tips",
                            icon: "lightbulb",
                            text: clean(entry.tips)
                        )

                        sectionView(
                            title: "Sources",
                            icon: "link",
                            text: clean(entry.sources),
                            isSource: true
                        )
                    }
                }
            }
            .padding()
            .frame(width: 354, height: 582)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.15), radius: 8)
        }
    }

    func sectionView(title: String, icon: String, text: String, isSource: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundColor(.black)

            if isSource {
                      Text(linkify(text))
                          .font(.system(size: 12))
                          .foregroundColor(.black)
                          .tint(.blue)
                          .textSelection(.enabled)
            } else {
                      Text(text)
                          .font(.system(size: 13))
                          .foregroundColor(.black)
                          .textSelection(.enabled)
                  }
        }
    }

    func clean(_ text: String) -> String {
        text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "1)", with: "")
            .replacingOccurrences(of: "2)", with: "")
            .replacingOccurrences(of: "3)", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
