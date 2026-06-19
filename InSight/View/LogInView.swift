//
//  LogInView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var accentColor: Color { theme.accent }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Text("Log In")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .softAppear()

                VStack(spacing: 12) {
                    AuthField(title: "Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    AuthSecureField(title: "Password", text: $password)
                }
                .padding(.horizontal, 24)
                .softAppear(delay: 0.08)

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
                .buttonStyle(PressableButtonStyle())
                .softAppear(delay: 0.14)

                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
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
                    .buttonStyle(PressableButtonStyle(scale: 0.94))
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.bottom, 28)
            }

            VStack {
                HStack {
                    OnboardingBackButton(action: {
                        dismiss()
                    }, tint: theme.deep)

                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer()
            }
            .softAppear()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AuthField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(title).foregroundStyle(Color.black.opacity(0.58)))
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.black)
            .tint(.black)
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
        SecureField("", text: $text, prompt: Text(title).foregroundStyle(Color.black.opacity(0.58)))
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.black)
            .tint(.black)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    LoginView()
        .environment(AppStateViewModel())
}
