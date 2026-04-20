//
//  ContentView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppStateViewModel.self) private var appState

    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStateViewModel())
}
