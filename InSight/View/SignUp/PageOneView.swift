//
//  PageOneView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct PageOneView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password = ""
    @State private var confirmPassword: String = ""

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 1.0, green: 0.176, blue: 0.333)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                Text("Sign Up")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

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
                .simultaneousGesture(TapGesture().onEnded {
                    guard isFormValid else {
                        appState.errorMessage = "Lutfen tum alanlari doldur ve sifreleri eslestir."
                        return
                    }

                    appState.updateRegistrationDraft(
                        RegistrationDraft(
                            email: email,
                            firstName: firstName,
                            lastName: lastName,
                            password: password,
                            birthDate: appState.registrationDraft.birthDate,
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
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
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
