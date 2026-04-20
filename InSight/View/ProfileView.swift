//
//  ProfileView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppStateViewModel.self) private var appState

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 0.953, green: 0.643, blue: 0.286)

    private var profile: UserProfile {
        appState.userProfile ?? AppStateViewModel.mockProfile
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
                                    ProfileMetricCard(icon: "allergens.fill", title: "Reaction", value: profile.allergies.first ?? "None")
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
                                } label: {
                                    Text("Health History")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(accentColor)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
                                        }
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

#Preview {
    ProfileView()
        .environment(AppStateViewModel())
}
