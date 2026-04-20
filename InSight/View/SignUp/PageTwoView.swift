//
//  PageTwoView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct PageTwoView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var skinType: String = ""
    @State private var allergies: String = ""

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 1.0, green: 0.176, blue: 0.333)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()

                Text("Sign Up")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                AuthField(title: "Skin Type", text: $skinType)
                AuthField(title: "Allergies", text: $allergies)

                NavigationLink {
                    VerificationView()
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.top, 8)

                Spacer()

                HStack(spacing: 4) {
                    Text("Already Have Account?")
                        .foregroundStyle(Color.white.opacity(0.82))

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Sign In")
                            .foregroundStyle(Color(red: 0.988, green: 0.922, blue: 0.353))
                            .fontWeight(.bold)
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    PageTwoView()
        .environment(AppStateViewModel())
}
