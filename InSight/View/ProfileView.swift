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

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                InSightScreenBackground(theme: theme)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text(appState.displayName)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.82))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }

                            Spacer()

                            Image(systemName: "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 56)
                        .softAppear()

                        Group {
                            if let profile = appState.userProfile {
                                profileContent(profile)
                            } else {
                                missingProfileContent
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(0, proxy.size.height - 150), alignment: .top)
                        .background(
                            TopRoundedPanelBackground(fill: theme.surface)
                        )
                        .padding(.top, 22)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingEditProfile) {
            if let profile = appState.userProfile {
                EditProfileView(profile: profile)
                    .environment(appState)
            }
        }
    }

    private func profileContent(_ profile: UserProfile) -> some View {
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
                        Text(profileInitials(profile))
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .offset(y: -44)
                    .padding(.bottom, -32)

                Text("My Profile")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                VStack(spacing: 14) {
                    ProfileInfoRow(title: "Name", value: profile.fullName, theme: theme)
                    ProfileInfoRow(title: "Email", value: profile.email, theme: theme)
                    ProfileInfoRow(title: "Age", value: String(profile.age), theme: theme)
                    ProfileInfoRow(title: "Gender", value: genderDisplay(profile.gender), theme: theme)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 22)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(theme.card)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .softAppear(delay: 0.06)

            VStack(alignment: .leading, spacing: 12) {
                Text("My Health DNA")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 12) {
                    ProfileMetricCard(icon: "drop.fill", title: "Skin Type", value: cleanDisplay(profile.skinType), theme: theme)
                    ProfileMetricCard(
                        icon: "allergens.fill",
                        title: "Reaction",
                        value: allergiesDisplay(profile.allergies),
                        theme: theme
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(theme.card)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .softAppear(delay: 0.12)

            ProfileScoreNoteCard(
                skinType: cleanDisplay(profile.skinType),
                allergies: allergiesDisplay(profile.allergies),
                theme: theme
            )
            .softAppear(delay: 0.16)

            ThemePickerCard(selectedTheme: appState.selectedTheme) { theme in
                withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                    appState.updateTheme(theme)
                }
            }
            .softAppear(delay: 0.2)

            profileActions
                .softAppear(delay: 0.26)
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 120)
    }

    private var missingProfileContent: some View {
        VStack(spacing: 14) {
            Spacer()

            ProgressView()
                .tint(backgroundColor)

            Text(appState.isLoading ? "Loading profile..." : "Profile information could not be loaded.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let errorMessage = appState.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task {
                    await appState.reloadProfile()
                }
            } label: {
                Text("Retry")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(appState.isLoading)

            Button {
                appState.signOut()
            } label: {
                Text("Sign Out")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.925, green: 0.302, blue: 0.302).opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Spacer()
        }
    }

    private var profileActions: some View {
        VStack(spacing: 10) {
            Button {
                isShowingEditProfile = true
            } label: {
                Label("Edit Profile", systemImage: "pencil")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle())

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
            .buttonStyle(PressableButtonStyle())
        }
    }

    private func cleanDisplay(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? String(localized: "Not specified") : trimmed
    }

    private func allergiesDisplay(_ allergies: [String]) -> String {
        let values = allergies
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return values.isEmpty ? String(localized: "None") : values.joined(separator: ", ")
    }

    private func genderDisplay(_ gender: String) -> String {
        switch gender.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "female":
            return "Female"
        case "male":
            return "Male"
        case "other":
            return "Non-binary"
        default:
            return gender.isEmpty ? String(localized: "Not specified") : gender
        }
    }

    private func profileInitials(_ profile: UserProfile) -> String {
        let first = profile.firstName.first.map(String.init) ?? ""
        let last = profile.lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}

private struct ProfileInfoRow: View {
    let title: String
    let value: String
    let theme: AppTheme

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
        }
    }
}

private struct ProfileMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(theme.isDark ? theme.textPrimary : theme.brand)

            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.panel)
        )
    }
}

private struct ProfileScoreNoteCard: View {
    let skinType: String
    let allergies: String
    let theme: AppTheme

    var body: some View {
        InSightCard(fill: theme.panel) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(theme.isDark ? theme.textPrimary : theme.gold)
                        .frame(width: 34, height: 34)
                        .background(theme.isDark ? Color.white.opacity(0.12) : theme.gold.opacity(0.14))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("How your score is personalized")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)

                        Text("Your skin profile helps InSight read product results more carefully.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    ProfileScoreNoteRow(title: "Skin type", value: skinType, theme: theme)
                    ProfileScoreNoteRow(title: "Avoid list", value: allergies, theme: theme)
                }
            }
        }
    }
}

private struct ThemePickerCard: View {
    let selectedTheme: AppTheme
    let onSelect: (AppTheme) -> Void

    var body: some View {
        InSightCard(fill: selectedTheme.panel) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Theme")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedTheme.textPrimary)

                    Text("Try a different visual mood for the app.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(selectedTheme.textSecondary)
                }

                VStack(spacing: 10) {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            onSelect(theme)
                        } label: {
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Circle().fill(theme.brand).frame(width: 14, height: 14)
                                    Circle().fill(theme.accent).frame(width: 14, height: 14)
                                    Circle().fill(theme.gold).frame(width: 14, height: 14)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(theme.title)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(selectedTheme.textPrimary)

                                    Text(theme.subtitle)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundStyle(selectedTheme.textSecondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: selectedTheme == theme ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(checkmarkColor(for: theme))
                            }
                            .padding(12)
                            .background(rowBackground(for: theme))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(PressableButtonStyle(scale: 0.97))
                    }
                }
            }
        }
    }

    private func checkmarkColor(for theme: AppTheme) -> Color {
        if selectedTheme == theme {
            return selectedTheme.isDark ? selectedTheme.textPrimary : theme.brand
        }

        return selectedTheme.textSecondary.opacity(0.5)
    }

    private func rowBackground(for theme: AppTheme) -> Color {
        if selectedTheme == theme {
            return selectedTheme.isDark ? Color.white.opacity(0.12) : theme.soft
        }

        return selectedTheme.card.opacity(0.82)
    }
}

private struct ProfileScoreNoteRow: View {
    let title: String
    let value: String
    let theme: AppTheme

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary.opacity(0.86))
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct EditProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var draft: ProfileUpdateDraft
    @State private var newEmail: String
    @State private var currentEmailCode = ""
    @State private var newEmailCode = ""
    @State private var emailChangeStep = 0
    @State private var emailStatusMessage: String?

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let panelColor = Color(red: 0.972, green: 0.978, blue: 0.975)
    private let skinTypeOptions = ["Oily", "Combination", "Dry", "Sensitive", "Normal"]
    private let genderOptions = ["Female", "Male", "Non-binary"]
    private let allergyOptions = [
        "Fragrance",
        "Essential Oils",
        "Alcohol Denat.",
        "Parabens",
        "Sulfates",
        "SLS",
        "Lanolin",
        "Nickel",
        "Latex",
        "Benzoyl Peroxide",
        "Salicylic Acid",
        "Retinoids",
        "Formaldehyde Releasers",
        "Methylisothiazolinone",
        "Cocamidopropyl Betaine",
        "Propylene Glycol"
    ]

    init(profile: UserProfile) {
        _draft = State(initialValue: ProfileUpdateDraft(profile: profile))
        _newEmail = State(initialValue: profile.email)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                panelColor
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(backgroundColor.opacity(0.13))
                                    .frame(width: 76, height: 76)

                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundStyle(backgroundColor)
                            }

                            VStack(spacing: 5) {
                                Text("Edit Profile")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.black)

                                Text("Update the details used to personalize your product reviews.")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.black.opacity(0.58))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        EditProfileSection(title: "Basic Information", icon: "person.text.rectangle.fill") {
                            VStack(spacing: 12) {
                                ProfileEditField(title: "First Name", text: $draft.firstName, icon: "person.fill")
                                ProfileEditField(title: "Last Name", text: $draft.lastName, icon: "person.fill")
                                AgeStepperRow(age: $draft.age)
                                ProfileEditMenu(
                                    title: "Gender",
                                    selection: $draft.gender,
                                    options: genderOptions
                                )
                            }
                        }

                        EditProfileSection(title: "Email Address", icon: "envelope.fill") {
                            EmailChangePanel(
                                currentEmail: draft.email,
                                newEmail: $newEmail,
                                currentCode: $currentEmailCode,
                                newCode: $newEmailCode,
                                step: $emailChangeStep,
                                statusMessage: $emailStatusMessage
                            )
                        }

                        EditProfileSection(title: "Skin Profile", icon: "drop.fill") {
                            ProfileEditMenu(
                                title: "Skin Type",
                                selection: $draft.skinType,
                                options: skinTypeOptions
                            )
                        }

                        EditProfileSection(title: "Allergy Notes", icon: "allergens.fill") {
                            VStack(alignment: .leading, spacing: 10) {
                                AllergySelectionGrid(
                                    selection: $draft.allergies,
                                    options: allergyOptions
                                )

                                Text("Select any ingredients your skin reacts to. You can leave this empty.")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.black.opacity(0.52))
                            }
                        }

                        if let errorMessage = appState.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        Button {
                            Task {
                                await appState.updateProfile(draft: draft)

                                if appState.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if appState.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                }

                                Text(appState.isLoading ? String(localized: "Saving...") : String(localized: "Save Changes"))
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(isValid ? backgroundColor : Color.black.opacity(0.18))
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
        (12...120).contains(draft.age) &&
        !draft.gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.skinType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct AgeStepperRow: View {
    @Binding var age: Int

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Age")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.48))

            HStack(spacing: 14) {
                ageButton(symbol: "minus") {
                    age = max(12, age - 1)
                }
                .disabled(age <= 12)
                .opacity(age <= 12 ? 0.45 : 1)

                Spacer()

                VStack(spacing: 2) {
                    Text("\(age)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)

                    Text("years old")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.48))
                }

                Spacer()

                ageButton(symbol: "plus") {
                    age = min(120, age + 1)
                }
                .disabled(age >= 120)
                .opacity(age >= 120 ? 0.45 : 1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(red: 0.972, green: 0.978, blue: 0.975))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func ageButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct EmailChangePanel: View {
    @Environment(AppStateViewModel.self) private var appState

    let currentEmail: String
    @Binding var newEmail: String
    @Binding var currentCode: String
    @Binding var newCode: String
    @Binding var step: Int
    @Binding var statusMessage: String?

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let panelColor = Color(red: 0.972, green: 0.978, blue: 0.975)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileEditField(title: "New Email", text: $newEmail, icon: "envelope.fill")
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button {
                Task {
                    await appState.requestEmailChangeCurrentCode(newEmail: newEmail)
                    if appState.errorMessage == nil {
                        step = max(step, 1)
                        statusMessage = "We sent a code to your current email: \(currentEmail)"
                    }
                }
            } label: {
                emailActionLabel("Send Code to Current Email", icon: "paperplane.fill")
            }
            .disabled(appState.isLoading || !canRequestCurrentCode)

            if step >= 1 {
                ProfileEditField(title: "Current Email Code", text: $currentCode, icon: "lock.fill")
                    .keyboardType(.numberPad)

                Button {
                    Task {
                        await appState.verifyEmailChangeCurrentCode(currentCode)
                        if appState.errorMessage == nil {
                            step = max(step, 2)
                            statusMessage = "Current email verified. We sent a code to your new email."
                        }
                    }
                } label: {
                    emailActionLabel("Verify Current Email", icon: "checkmark.shield.fill")
                }
                .disabled(appState.isLoading || currentCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if step >= 2 {
                ProfileEditField(title: "New Email Code", text: $newCode, icon: "lock.fill")
                    .keyboardType(.numberPad)

                Button {
                    Task {
                        await appState.confirmEmailChangeNewCode(newCode)
                        if appState.errorMessage == nil {
                            step = 3
                            statusMessage = "Email updated successfully."
                        }
                    }
                } label: {
                    emailActionLabel("Confirm New Email", icon: "checkmark.seal.fill")
                }
                .disabled(appState.isLoading || newCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(backgroundColor)
                    .lineSpacing(2)
            }
        }
    }

    private var canRequestCurrentCode: Bool {
        let value = newEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return value.contains("@") && value.contains(".") && value != currentEmail.lowercased()
    }

    private func emailActionLabel(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(canRequestCurrentCode || step > 0 ? .white : Color.black.opacity(0.35))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(canRequestCurrentCode || step > 0 ? backgroundColor : panelColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct EditProfileSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(backgroundColor)
                    .frame(width: 28, height: 28)
                    .background(backgroundColor.opacity(0.12))
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
            }

            content
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

private struct ProfileEditField: View {
    let title: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.48))

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.459, green: 0.643, blue: 0.533))
                    .frame(width: 18)

                TextField("", text: $text, prompt: Text(title).foregroundStyle(Color.black.opacity(0.48)))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .tint(.black)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(red: 0.972, green: 0.978, blue: 0.975))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                    Image(systemName: "drop.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.459, green: 0.643, blue: 0.533))
                        .frame(width: 18)

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
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

private struct AllergySelectionGrid: View {
    @Binding var selection: String
    let options: [String]

    private let selectedColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let surfaceColor = Color(red: 0.972, green: 0.978, blue: 0.975)

    private var selectedValues: [String] {
        selection
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        FlowLayout(spacing: 8, rowSpacing: 10) {
            ForEach(options, id: \.self) { option in
                Button {
                    toggle(option)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isSelected(option) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 13, weight: .bold))

                        Text(option)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(isSelected(option) ? .white : Color.black.opacity(0.68))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(isSelected(option) ? selectedColor : surfaceColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func isSelected(_ option: String) -> Bool {
        selectedValues.contains { $0.caseInsensitiveCompare(option) == .orderedSame }
    }

    private func toggle(_ option: String) {
        var values = selectedValues

        if let index = values.firstIndex(where: { $0.caseInsensitiveCompare(option) == .orderedSame }) {
            values.remove(at: index)
        } else {
            values.append(option)
        }

        selection = values.joined(separator: ", ")
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat
    let rowSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = arrangeSubviews(subviews, maxWidth: maxWidth)

        return CGSize(
            width: maxWidth,
            height: rows.last.map { $0.y + $0.height } ?? 0
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = arrangeSubviews(subviews, maxWidth: bounds.width)

        for row in rows {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private func arrangeSubviews(_ subviews: Subviews, maxWidth: CGFloat) -> [FlowRow] {
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentX: CGFloat = 0
        var currentHeight: CGFloat = 0
        let availableWidth = max(maxWidth, 1)

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextX = currentItems.isEmpty ? 0 : currentX + spacing

            if nextX + size.width > availableWidth, !currentItems.isEmpty {
                let y = rows.last.map { $0.y + $0.height + rowSpacing } ?? 0
                rows.append(FlowRow(y: y, height: currentHeight, items: currentItems))
                currentItems = []
                currentX = 0
                currentHeight = 0
            }

            let itemX = currentItems.isEmpty ? 0 : currentX + spacing
            currentItems.append(FlowItem(index: index, x: itemX, size: size))
            currentX = itemX + size.width
            currentHeight = max(currentHeight, size.height)
        }

        if !currentItems.isEmpty {
            let y = rows.last.map { $0.y + $0.height + rowSpacing } ?? 0
            rows.append(FlowRow(y: y, height: currentHeight, items: currentItems))
        }

        return rows
    }
}

private struct FlowRow {
    let y: CGFloat
    let height: CGFloat
    let items: [FlowItem]
}

private struct FlowItem {
    let index: Int
    let x: CGFloat
    let size: CGSize
}

#Preview {
    ProfileView()
        .environment(AppStateViewModel())
}
