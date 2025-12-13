import Foundation
import UIKit

enum SkinAPI {
    static let baseURL = URL(string: "https://jasmine-api-2nsv.onrender.com")!

    static let predictPath = "/predict"
}


struct PredictResponse: Codable {
    struct TopItem: Codable {
        let label: String
        let score: Double
    }
    let arch: String
    let top1: TopItem
    let topk: [TopItem]
    let chatgpt_explanation: String?
}


final class SkinAPIService {
    static let shared = SkinAPIService()
    private init() {}

    func predict(image: UIImage, topk: Int = 5) async throws -> PredictResponse {
        guard let url = URL(string: SkinAPI.predictPath + "?topk=\(topk)", relativeTo: SkinAPI.baseURL) else {
            throw URLError(.badURL)
        }

        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "ImageEncoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "HTTP", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(PredictResponse.self, from: data)
        return result
    }
}
