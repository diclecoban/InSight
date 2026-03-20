//
//  ContentView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            NavigationStack {
                WelcomeView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

#Preview {
    ContentView()
}
