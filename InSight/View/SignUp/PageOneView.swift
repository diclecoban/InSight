//
//  PageOneView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct PageOneView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password = ""
    @State private var confirmPassword: String = ""

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var accentColor: Color { theme.accent }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                Text("Sign Up")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .softAppear()

                AuthField(title: "Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                HStack(spacing: 12) {
                    AuthField(title: "First Name", text: $firstName)
                    AuthField(title: "Last Name", text: $lastName)
                }

                AuthSecureField(title: "Password", text: $password)
                AuthSecureField(title: "Confirm Password", text: $confirmPassword)
                    .softAppear(delay: 0.08)

                NavigationLink {
                    PageTwoView()
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.top, 6)
                .buttonStyle(PressableButtonStyle())
                .softAppear(delay: 0.14)
                .simultaneousGesture(TapGesture().onEnded {
                    guard isFormValid else {
                        appState.errorMessage = String(localized: "Please fill in all fields and make sure the passwords match.")
                        return
                    }

                    appState.updateRegistrationDraft(
                        RegistrationDraft(
                            email: email,
                            firstName: firstName,
                            lastName: lastName,
                            password: password,
                            age: appState.registrationDraft.age,
                            gender: appState.registrationDraft.gender,
                            skinType: appState.registrationDraft.skinType,
                            allergies: appState.registrationDraft.allergies
                        )
                    )
                    appState.errorMessage = nil
                })
                .disabled(!isFormValid)

                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }

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
                    .buttonStyle(PressableButtonStyle(scale: 0.94))
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)

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
        .onAppear {
            let draft = appState.registrationDraft
            email = draft.email
            firstName = draft.firstName
            lastName = draft.lastName
            password = draft.password
            confirmPassword = draft.password
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
}

#Preview {
    PageOneView()
        .environment(AppStateViewModel())
}
