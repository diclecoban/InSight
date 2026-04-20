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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
