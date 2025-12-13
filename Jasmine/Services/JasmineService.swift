//
//  JasmineService.swift
//  Jasmine
//

import Foundation
import UIKit
import Supabase


struct SkinImageRow: Codable {
    let imageid: UUID
    let userid: UUID
    let uploaddate: String
    let storagepath: String
}

struct AnalysisRow: Codable {
    let analysisid: UUID
    let imageid: UUID
    let conditionlabel: String
    let recommendation: String
    let status: String
}

struct DailyRoutineRow: Codable {
    let routineid: UUID
    let userid: UUID
    let routinename: String
    let isdone: Bool
    let time: String?
    let routinetype: String?
}


enum JasmineService {
    static let bucket = "skin-images"

    static func uploadSkinImage(_ image: UIImage, userID: UUID) async throws -> (imageID: UUID, path: String) {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "ImageEncoding", code: -1)
        }

        let imageID = UUID()
        let path = "users/\(userID.uuidString)/\(imageID.uuidString).jpg"

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

    static func saveAnalysis(imageID: UUID, label: String, recommendation: String, status: String = "draft") async throws -> UUID {

        struct InsertRow: Encodable {
            let analysisid: UUID
            let imageid: UUID
            let conditionlabel: String
            let recommendation: String
            let status: String
        }

        let newId = UUID()

        let row = InsertRow(
            analysisid: newId,
            imageid: imageID,
            conditionlabel: label,
            recommendation: recommendation,
            status: status
        )

        _ = try await Supa.client
            .from("analysis")
            .insert(row)
            .execute()

        return newId
    }


    static func upsertRoutine(
        routineID: UUID,
        userID: UUID,
        routineName: String,
        routineType: String?,
        isDone: Bool,
        time: String?
    ) async throws {

        let cleanTime: String? = {
            guard let t = time?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !t.isEmpty else { return nil }
            return t
        }()

        let row = DailyRoutineRow(
            routineid: routineID,
            userid: userID,
            routinename: routineName,
            isdone: isDone,
            time: cleanTime,
            routinetype: routineType
        )

        _ = try await Supa.client
            .from("daily_routine")
            .upsert(row, onConflict: "routineid")
            .execute()
    }

    static func upsertRewardPoints(
        userID: UUID,
        points: Int,
    ) async throws {

        struct RewardUpsert: Encodable {
            let userid: UUID
            let points: Int
        }

        let row = RewardUpsert(
            userid: userID,
            points: points,
        )

        _ = try await Supa.client
            .from("reward_system")
            .upsert(row, onConflict: "userid")
            .execute()
    }

    static func ensureRewardRowExists(userID: UUID) async throws {
        try await upsertRewardPoints(userID: userID, points: 0)
    }
}
