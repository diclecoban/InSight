//
//  PageTwoView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct PageTwoView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var age = 18
    @State private var gender: String = ""
    @State private var skinType: String = ""
    @State private var allergies: String = ""
    @State private var selectedAllergies: Set<String> = []
    @State private var navigateToVerification = false

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var accentColor: Color { theme.accent }
    private let genderOptions = ["Female", "Male", "Non-binary"]
    private let skinTypeOptions = ["Oily", "Karma", "Dry"]
    private let allergyOptions = ["Fragrance", "Alcohol", "Paraben", "Sulfate", "Silicone"]

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()

                Text("Sign Up")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .softAppear()

                Menu {
                    ForEach(12...100, id: \.self) { option in
                        Button("\(option)") {
                            age = option
                        }
                    }
                } label: {
                    HStack {
                        Text("Age: \(age)")
                            .foregroundStyle(.black)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .softAppear(delay: 0.06)

                Menu {
                    ForEach(genderOptions, id: \.self) { option in
                        Button(option) {
                            gender = option
                        }
                    }
                } label: {
                    HStack {
                        Text(gender.isEmpty ? "Gender" : gender)
                            .foregroundStyle(gender.isEmpty ? Color.black.opacity(0.45) : .black)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .softAppear(delay: 0.09)

                Menu {
                    ForEach(skinTypeOptions, id: \.self) { option in
                        Button(option) {
                            skinType = option
                        }
                    }
                } label: {
                    HStack {
                        Text(skinType.isEmpty ? "Skin Type" : skinType)
                            .foregroundStyle(skinType.isEmpty ? Color.black.opacity(0.45) : .black)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .softAppear(delay: 0.12)

                Menu {
                    ForEach(allergyOptions, id: \.self) { option in
                        Button {
                            toggleAllergy(option)
                        } label: {
                            HStack {
                                Text(option)
                                Spacer()
                                if selectedAllergies.contains(option) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(allergiesDisplayText)
                            .foregroundStyle(selectedAllergies.isEmpty ? Color.black.opacity(0.45) : .black)
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .softAppear(delay: 0.15)

                Button {
                    appState.updateRegistrationDraft(
                        RegistrationDraft(
                            email: appState.registrationDraft.email,
                            firstName: appState.registrationDraft.firstName,
                            lastName: appState.registrationDraft.lastName,
                            password: appState.registrationDraft.password,
                            age: age,
                            gender: gender,
                            skinType: skinType,
                            allergies: allergies
                        )
                    )

                    Task {
                        await appState.register()
                    }
                } label: {
                    Text(appState.isLoading ? String(localized: "Registering...") : String(localized: "Register"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.top, 8)
                .disabled(appState.isLoading || gender.isEmpty || skinType.isEmpty)
                .buttonStyle(PressableButtonStyle())
                .softAppear(delay: 0.2)

                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                if appState.isLoading {
                    ProgressView()
                        .tint(.white)
                }

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
            age = draft.age
            gender = draft.gender
            skinType = draft.skinType
            allergies = draft.allergies
            selectedAllergies = Set(
                draft.allergies
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            )
            appState.resetRegistrationFlow()
        }
        .onChange(of: appState.didCompleteRegistration) { _, newValue in
            if newValue {
                navigateToVerification = true
            }
        }
        .navigationDestination(isPresented: $navigateToVerification) {
            VerificationView()
        }
    }

    private var allergiesDisplayText: String {
        selectedAllergies.isEmpty ? "Allergies" : selectedAllergies.sorted().joined(separator: ", ")
    }

    private func toggleAllergy(_ option: String) {
        if selectedAllergies.contains(option) {
            selectedAllergies.remove(option)
        } else {
            selectedAllergies.insert(option)
        }

        allergies = selectedAllergies.sorted().joined(separator: ", ")
    }
}

#Preview {
    PageTwoView()
        .environment(AppStateViewModel())
}
