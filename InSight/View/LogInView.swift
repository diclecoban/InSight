//
//  LogInView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var email = ""
    @State private var password = ""

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 1.0, green: 0.176, blue: 0.333)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Text("Log In")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)

                VStack(spacing: 12) {
                    AuthField(title: "Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    AuthSecureField(title: "Password", text: $password)
                }
                .padding(.horizontal, 24)

                HStack {
                    Spacer()
                    Button("Forgot Your Password?") {
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.88))
                }
                .padding(.horizontal, 24)

                Button {
                    Task {
                        await appState.signIn(email: email, password: password)
                    }
                } label: {
                    Text("Login")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 24)
                .disabled(appState.isLoading)

                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(height: 1)

                    Text("Or")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.78))

                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)

                HStack(spacing: 14) {
                    SocialButton(symbol: "envelope.fill")
                    SocialButton(symbol: "apple.logo")
                    SocialButton(symbol: "f.cursive")
                }

                Spacer()

                if appState.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                HStack(spacing: 4) {
                    Text("Don't Have Account?")
                        .foregroundStyle(Color.white.opacity(0.82))

                    NavigationLink {
                        PageOneView()
                    } label: {
                        Text("Sign Up")
                            .foregroundStyle(Color(red: 0.988, green: 0.922, blue: 0.353))
                            .fontWeight(.bold)
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AuthField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct AuthSecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct SocialButton: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.black.opacity(0.78))
            .frame(width: 36, height: 36)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    LoginView()
        .environment(AppStateViewModel())
}
