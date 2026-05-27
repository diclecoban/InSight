//
//  NetworkConfiguration.swift
//  InSight
//
//  Created by Codex on 20.04.2026.
//

import Foundation

enum NetworkConfiguration {
    static let useMockAuth = false

    static let baseURL = URL(
        string: Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://192.168.1.135:3000"
    )!

    static let clientVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
}
