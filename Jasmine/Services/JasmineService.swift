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
    let explanation: String
}

struct ActivityLogRow: Codable {
    let logid: String
    let userid: String
    let date: String
    let routinename: String
    let isdone: Bool
    let note: String?
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

    static func signedURLString(for path: String) async throws -> String {
        let url: URL = try await Supa.client.storage
            .from(bucket)
            .createSignedURL(path: path, expiresIn: 60 * 10)
        return url.absoluteString
    }


    //  حفظ نتيجة التحليل
    static func saveAnalysis(imageID: String, label: String, explanation: String) async throws {
        let row = AnalysisRow(
            analysisid: UUID().uuidString,
            imageid: imageID,
            conditionlabel: label,
            explanation: explanation
        )
        _ = try await Supa.client
            .from("analysis")
            .insert(row)
            .execute()
    }

    //  وضع علامة الروتين + زيادة النقاط (ما استخدمناها لسا)
    static func markRoutine(userID: String, routine: String, note: String?) async throws {
        // تسجل Log ف
        let log = ActivityLogRow(
            logid: UUID().uuidString,
            userid: userID,
            date: ISO8601DateFormatter().string(from: Date()),
            routinename: routine,
            isdone: true,
            note: note
        )
        _ = try await Supa.client
            .from("activity_logs")
            .insert(log)
            .execute()

        // يجيب النقاط الحاليه
        struct RewardRow: Decodable { let points: Int? }

        let res = try await Supa.client
            .from("reward_system")
            .select("points")
            .eq("userid", value: userID)
            .single()
            .execute()

        let reward = try JSONDecoder().decode(RewardRow.self, from: res.data)
        let current = reward.points ?? 0
        let newPoints = current + 5


     
//حدّث نقاط المستخدم في جدول reward_system
        struct RewardUpdate: Encodable { let points: Int }

        _ = try await Supa.client
            .from("reward_system")
            .update(RewardUpdate(points: newPoints))
            .eq("userid", value: userID)
            .execute()

    }
}
