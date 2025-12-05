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
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    Text(entry.condition.capitalized)
                        .font(.title2.bold())
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                Text("Date: \(entry.date)")
                    .font(.body)
                    .foregroundColor(.gray)

                Divider()

                if entry.isClear {
                    Text("No issues detected 🎉")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Text("A condition was detected. You should follow your doctor’s advice or review your skin routine.")
                        .font(.body)
                }

                Spacer()

            }
            .padding()
            .frame(maxWidth: 330, minHeight: 260)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 10)
        }
    }
}
