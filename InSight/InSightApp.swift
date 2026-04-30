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

        if NetworkConfiguration.useMockAuth {
            authService = MockAuthService()
        } else {
            let client = APIClient(baseURL: NetworkConfiguration.baseURL)
            authService = APIAuthService(client: client)
        }

        _appState = State(
            initialValue: AppStateViewModel(
                authService: authService
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
