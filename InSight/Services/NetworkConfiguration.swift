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
        string: Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? fallbackBaseURL
    )!

    static let clientVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"

    private static var fallbackBaseURL: String {
        #if DEBUG
        "http://127.0.0.1:3000"
        #else
        "https://api.insight.app"
        #endif
    }
}
