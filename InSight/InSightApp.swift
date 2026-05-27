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
        let sessionStore: SessionPersisting
        let initialSession: AuthSession?
        let initialProfile: UserProfile?
        let initialSavedReviews: [SavedReview]
        let initialRecommendations: [RecommendationItem]
        let initialScanResult: ScanResult?

        if NetworkConfiguration.useMockAuth {
            authService = MockAuthService()
            profileService = MockProfileService()
            contentService = MockContentService()
            scanService = MockScanService()
            sessionStore = InMemorySessionStore()
            initialSession = nil
            initialProfile = AppMockData.profile
            initialSavedReviews = AppMockData.savedReviews
            initialRecommendations = AppMockData.recommendations
            initialScanResult = AppMockData.sampleScanResult
        } else {
            let client = APIClient(baseURL: NetworkConfiguration.baseURL)
            authService = APIAuthService(client: client)
            profileService = APIProfileService(client: client)
            contentService = APIContentService(client: client)
            scanService = APIScanService(client: client)
            sessionStore = KeychainSessionStore()
            initialSession = sessionStore.loadSession()
            initialProfile = nil
            initialSavedReviews = []
            initialRecommendations = []
            initialScanResult = nil
        }

        _appState = State(
            initialValue: AppStateViewModel(
                authService: authService,
                profileService: profileService,
                contentService: contentService,
                scanService: scanService,
                sessionStore: sessionStore,
                session: initialSession,
                userProfile: initialProfile,
                savedReviews: initialSavedReviews,
                recommendations: initialRecommendations,
                latestScanResult: initialScanResult
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    await appState.restoreSession()
                }
        }
    }
}
