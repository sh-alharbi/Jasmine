//
//  JasmineService.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/5/25.
//

import Foundation
import UIKit
import Supabase

struct SkinImageRow: Codable {
    let imageid: String
    let userid: String
    let uploaddate: String
    let storagepath: String
}

struct AnalysisRow: Codable {
    let analysisid: String
    let imageid: String
    let conditionlabel: String
    let recommendation: String
}

struct DailyRoutineRow: Codable {
    let routineid: String
    let userid: String
    let routinename: String
    let isdone: Bool
    let time: String?
    let routinetype: String?
}

enum JasmineService {
    static let bucket = "skin-images"

    static func uploadSkinImage(_ image: UIImage, userID: String) async throws -> (imageID: String, path: String) {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "ImageEncoding", code: -1)
        }

        let imageID = UUID().uuidString
        let path = "users/\(userID)/\(imageID).jpg"

        try await Supa.client.storage
            .from(bucket)
            .upload(
                path: path,
                file: data,
                options: FileOptions(contentType: "image/jpeg", upsert: false)
            )

        let row = SkinImageRow(
            imageid: imageID,
            userid: userID,
            uploaddate: ISO8601DateFormatter().string(from: Date()),
            storagepath: path
        )
        _ = try await Supa.client
            .from("skin_images")
            .insert(row)
            .execute()

        return (imageID, path)
    }

    static func saveAnalysis(imageID: String, label: String, recommendation: String) async throws {
        let row = AnalysisRow(
            analysisid: UUID().uuidString,
            imageid: imageID,
            conditionlabel: label,
            recommendation: recommendation
        )
        _ = try await Supa.client
            .from("analysis")
            .insert(row)
            .execute()
    }

    static func markRoutine(userID: String, routine: String, routineType: String? = nil) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: Date())

        let log = DailyRoutineRow(
            routineid: UUID().uuidString,
            userid: userID,
            routinename: routine,
            isdone: true,
            time: timeString,
            routinetype: routineType
        )

        _ = try await Supa.client
            .from("daily_routine")
            .insert(log)
            .execute()

        struct RewardRow: Decodable { let points: Int? }

        let res = try await Supa.client
            .from("reward_system")
            .select("points")
            .eq("userid", value: userID)
            .single()
            .execute()

        let reward = try JSONDecoder().decode(RewardRow.self, from: res.data)
        let currentPoints = reward.points ?? 0
        let newPoints = currentPoints + 5

        struct RewardUpdate: Encodable { let points: Int }

        _ = try await Supa.client
            .from("reward_system")
            .update(RewardUpdate(points: newPoints))
            .eq("userid", value: userID)
            .execute()
    }
}
