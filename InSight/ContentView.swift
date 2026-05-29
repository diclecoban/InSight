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
        ZStack(alignment: .top) {
            if appState.isRestoringSession {
                LoadingView(
                    title: "Restoring session",
                    subtitle: "Checking your secure session before opening the app."
                )
            } else if appState.isLoggedIn {
                MainTabView()
            } else {
                WelcomeView()
            }

            if let message = appState.backendConnectivityMessage {
                connectivityBanner(message)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
        }
    }

    private func connectivityBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.92), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .accessibilityLabel(message)
    }
}

#Preview {
    ContentView()
        .environment(AppStateViewModel())
}
