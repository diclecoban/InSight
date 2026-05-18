//
//  InSightApp.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

@main
struct InSightApp: App {
    @State private var appState = AppStateViewModel()

    init() {
        let authService: AuthServicing
        let profileService: ProfileServicing
        let contentService: ContentServicing
        let scanService: ScanServicing

        if NetworkConfiguration.useMockAuth {
            authService = MockAuthService()
            profileService = MockProfileService()
            contentService = MockContentService()
            scanService = MockScanService()
        } else {
            let client = APIClient(baseURL: NetworkConfiguration.baseURL)
            authService = APIAuthService(client: client)
            profileService = APIProfileService(client: client)
            contentService = APIContentService(client: client)
            scanService = APIScanService(client: client)
        }

        _appState = State(
            initialValue: AppStateViewModel(
                authService: authService,
                profileService: profileService,
                contentService: contentService,
                scanService: scanService
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
