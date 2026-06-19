//
//  MainTabView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(0)

            HomeView(userName: appState.displayName)
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(1)

            ScanView()
                .tabItem {
                    Image(systemName: "camera.fill")
                }
                .tag(2)

            ListsView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                }
                .tag(3)
        }
        .tint(appState.selectedTheme.brand)
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: selectedTab)
    }
}

#Preview {
    MainTabView()
        .environment(AppStateViewModel())
}
