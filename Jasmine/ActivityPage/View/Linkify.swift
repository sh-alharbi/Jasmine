import SwiftUI
import Foundation

func linkify(_ text: String) -> AttributedString {
    var attributed = AttributedString(text)

    let pattern = #"((https?:\/\/)[^\s\)\]\}>"']+)|(\bwww\.[^\s\)\]\}>"']+)|(\b[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(\/[^\s\)\]\}>"']*)?)"#

    guard let regex = try? NSRegularExpression(pattern: pattern) else { return attributed }

    let nsText = text as NSString
    let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

    for m in matches.reversed() {
        let found = nsText.substring(with: m.range)

        let urlString: String
        if found.lowercased().hasPrefix("http://") || found.lowercased().hasPrefix("https://") {
            urlString = found
        } else {
            urlString = "https://\(found)"
        }

        guard let url = URL(string: urlString),
              let range = Range(m.range, in: attributed) else { continue }

        attributed[range].link = url
        attributed[range].foregroundColor = .blue
        attributed[range].underlineStyle = .single
    }

    return attributed
}
