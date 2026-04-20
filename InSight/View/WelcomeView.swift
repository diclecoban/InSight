//
//  WelcomeView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppStateViewModel.self) private var appState

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 1.0, green: 0.176, blue: 0.333)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: 72)

                Text("WELCOME")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.988, green: 0.922, blue: 0.353))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)

                Spacer()

                VStack(spacing: 20) {
                    Text("Know what you're using before it touches your skin.")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(.horizontal, 40)

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Let's Start")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
            }
            .background(Color.white)
            .ignoresSafeArea(edges: .bottom)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppStateViewModel())
}
