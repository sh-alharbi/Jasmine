//
//  LargeHistoryPopUp.swift
//  Jasmine
//
//  Created by lamess on 14/06/1447 AH.
//
import SwiftUI

struct LargeHistoryPopUp: View {

    let entry: UserHistory
    let onClose: () -> Void

    var body: some View {
        ZStack {

            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(alignment: .leading, spacing: 14) {

                // ✅ العنوان + زر الإغلاق
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

                        // ✅ Explanation
                        sectionView(
                            title: "Explanation",
                            icon: "doc.text",
                            text: clean(entry.explanation)
                        )

                        // ✅ Tips
                        sectionView(
                            title: "Tips",
                            icon: "lightbulb",
                            text: clean(entry.tips)
                        )

                        // ✅ Sources
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
            // ✅ حجم أصغر ومربع أكثر
            .frame(width: 354, height: 582)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25)) // أقل دائرية
            .shadow(color: .black.opacity(0.15), radius: 8)
        }
    }

    // ✅ شكل موحد لكل الأقسام – أسود بالكامل
    func sectionView(title: String, icon: String, text: String, isSource: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundColor(.black)

            Text(text)
                .font(.system(size: isSource ? 12 : 13))
                .foregroundColor(.black)
        }
    }

    // ✅ تنظيف النص من ** والأرقام
    func clean(_ text: String) -> String {
        text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "1)", with: "")
            .replacingOccurrences(of: "2)", with: "")
            .replacingOccurrences(of: "3)", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
