//
//  WelcomeView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("WELCOME")
                .font(.system(size: 40, weight: .black))
                .padding(.horizontal, 8)
                .background(Color.yellow)
                .padding(.leading, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack {
                NavigationLink {
                    LoginView(isLoggedIn: $isLoggedIn)
                } label: {
                    Text("Let's Start")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 1, green: 0.176, blue: 0.333))
                        .cornerRadius(30)
                        .padding(.horizontal, 24)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color(red: 0.459, green: 0.643, blue: 0.533))
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
}

#Preview {
    WelcomeView(isLoggedIn: .constant(false))
}
