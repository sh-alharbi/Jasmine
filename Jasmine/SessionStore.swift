//
//  SessionStore.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
//
import Foundation
import Combine
class SessionStore: ObservableObject {
    @Published var userID: String? = nil
}
