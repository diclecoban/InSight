//
//  ProfileView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var isShowingEditProfile = false

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 0.953, green: 0.643, blue: 0.286)

    private var profile: UserProfile {
        appState.userProfile ?? AppMockData.profile
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(profile.fullName)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    Spacer()

                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 56)

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(Color.white)
                        .ignoresSafeArea(edges: .bottom)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.996, green: 0.761, blue: 0.471), Color(red: 0.957, green: 0.443, blue: 0.365)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 92, height: 92)
                                    .overlay {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 64, height: 64)
                                            .foregroundStyle(.white)
                                    }
                                    .offset(y: -44)
                                    .padding(.bottom, -32)

                                Text("My Profile")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))

                                VStack(spacing: 14) {
                                    ProfileInfoRow(title: "Name", value: profile.firstName)
                                    ProfileInfoRow(title: "Age", value: String(profile.age))
                                    ProfileInfoRow(title: "Condition", value: profile.condition)
                                    ProfileInfoRow(title: "Sensitivity", value: profile.sensitivity)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 22)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                            )

                            VStack(alignment: .leading, spacing: 12) {
                                Text("My Health DNA")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))

                                HStack(spacing: 12) {
                                    ProfileMetricCard(icon: "drop.fill", title: "Skin Type", value: profile.skinType)
                                    ProfileMetricCard(
                                        icon: "allergens.fill",
                                        title: "Reaction",
                                        value: profile.allergies.first ?? String(localized: "None")
                                    )
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                            )

                            VStack(spacing: 10) {
                                Button {
                                    isShowingEditProfile = true
                                } label: {
                                    Text("Edit Profile")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }

                                Button {
                                    appState.signOut()
                                } label: {
                                    Text("Sign Out")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(red: 0.925, green: 0.302, blue: 0.302).opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 24)
                        .padding(.bottom, 120)
                    }
                }
                .padding(.top, 22)
            }
        }
        .sheet(isPresented: $isShowingEditProfile) {
            EditProfileView(profile: profile)
                .environment(appState)
        }
    }
}

private struct ProfileInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.45))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
        }
    }
}

private struct ProfileMetricCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(red: 0.459, green: 0.643, blue: 0.533))

            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.5))

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.972, green: 0.978, blue: 0.975))
        )
    }
}

private struct EditProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var draft: ProfileUpdateDraft

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 0.953, green: 0.643, blue: 0.286)
    private let skinTypeOptions = ["Oily", "Combination", "Dry", "Sensitive", "Normal"]
    private let sensitivityOptions = ["Low", "Medium", "High"]

    init(profile: UserProfile) {
        _draft = State(initialValue: ProfileUpdateDraft(profile: profile))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.972, green: 0.978, blue: 0.975)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Edit Profile")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)

                            Text("Keep your health DNA current for better product guidance.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.black.opacity(0.56))
                        }

                        VStack(spacing: 12) {
                            ProfileEditField(title: "First Name", text: $draft.firstName)
                            ProfileEditField(title: "Last Name", text: $draft.lastName)

                            ProfileEditMenu(
                                title: "Skin Type",
                                selection: $draft.skinType,
                                options: skinTypeOptions
                            )

                            ProfileEditField(title: "Condition", text: $draft.condition)

                            ProfileEditMenu(
                                title: "Sensitivity",
                                selection: $draft.sensitivity,
                                options: sensitivityOptions
                            )

                            ProfileEditField(title: "Allergies", text: $draft.allergies)
                        }
                        .padding(18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)

                        if let errorMessage = appState.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                                .multilineTextAlignment(.leading)
                        }

                        Button {
                            Task {
                                await appState.updateProfile(draft: draft)

                                if appState.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text(appState.isLoading ? String(localized: "Saving...") : String(localized: "Save Changes"))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(appState.isLoading || !isValid)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, 36)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(backgroundColor)
                }
            }
        }
    }

    private var isValid: Bool {
        !draft.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.skinType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct ProfileEditField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.48))

            TextField(title, text: $text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(red: 0.972, green: 0.978, blue: 0.975))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

private struct ProfileEditMenu: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.48))

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? title : selection)
                        .foregroundStyle(selection.isEmpty ? Color.black.opacity(0.42) : .black)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.4))
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(red: 0.972, green: 0.978, blue: 0.975))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppStateViewModel())
}
