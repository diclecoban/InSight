//
//  MainTabView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(0)
            
            HomeView(userName: "Dicle")
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
                    Image(systemName: "doc.text.fill")
                }
                .tag(3)
        }
        .tint(Color(red: 0.459, green: 0.643, blue: 0.533))
    }
}

#Preview {
    MainTabView()
}
