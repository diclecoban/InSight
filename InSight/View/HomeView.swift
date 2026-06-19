//
//  HomeView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State var userName: String = "Susan Clay"

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var accentColor: Color { theme.gold }

    private var latestScanTitle: String {
        appState.latestScanResult?.product.name ?? String(localized: "Ready for your next product")
    }

    private var latestScanSubtitle: String {
        if let result = appState.latestScanResult {
            return String.localizedStringWithFormat(
                String(localized: "%lld%% safety score from your last scan"),
                Int(result.score * 100)
            )
        }

        return String(localized: "Scan a barcode to get a personalized safety decision.")
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                InSightScreenBackground(theme: theme)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header(topInset: proxy.safeAreaInsets.top)
                            .softAppear()

                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.996, green: 0.761, blue: 0.471), Color(red: 0.957, green: 0.443, blue: 0.365)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                                .offset(y: -45)
                                .padding(.bottom, -45)
                                .overlay {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(.white)
                                        .offset(y: -45)
                                }

                            Image(systemName: "medal.fill")
                                .foregroundStyle(accentColor)
                                .font(.system(size: 20, weight: .semibold))

                            Group {
                                Text("Welcome to your\ncomfort ")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary)
                                Text("place")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.accent)
                            }
                            .multilineTextAlignment(.center)
                            .softAppear(delay: 0.08)

                            HStack(spacing: 12) {
                                CategoryCard(icon: "bag.fill", title: String(localized: "Skin Care"), theme: theme)
                                CategoryCard(icon: "heart.fill", title: String(localized: "Food"), theme: theme)
                            }
                            .padding(.horizontal, 24)
                            .softAppear(delay: 0.14)

                            HStack(spacing: 12) {
                                HomeStatCard(
                                    icon: "bookmark.fill",
                                    value: "\(appState.savedReviews.count)",
                                    title: "Saved",
                                    theme: theme
                                )

                                HomeStatCard(
                                    icon: "checkmark.seal.fill",
                                    value: latestSafetyLabel,
                                    title: "Last Check",
                                    theme: theme
                                )
                            }
                            .padding(.horizontal, 24)
                            .softAppear(delay: 0.18)

                            HomeInsightCard(
                                icon: "barcode.viewfinder",
                                title: latestScanTitle,
                                subtitle: latestScanSubtitle,
                                tint: appState.latestScanResult?.safetyLevel.color ?? backgroundColor,
                                fill: theme.panel,
                                textPrimary: theme.textPrimary,
                                textSecondary: theme.textSecondary,
                                isDarkContext: theme.isDark
                            )
                            .padding(.horizontal, 24)
                            .softAppear(delay: 0.22)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recommended for You")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 24)
                                    .foregroundStyle(theme.textPrimary)

                                if appState.recommendations.isEmpty {
                                    RecommendationCard(
                                        title: String(localized: "No recommendations yet"),
                                        subtitle: String(localized: "Scan a product to personalize this area."),
                                        theme: theme
                                    )
                                } else {
                                    ForEach(appState.recommendations) { recommendation in
                                        RecommendationCard(
                                            title: recommendation.title,
                                            subtitle: recommendation.subtitle,
                                            theme: theme
                                        )
                                    }
                                }
                            }
                            .softAppear(delay: 0.26)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(0, proxy.size.height - 150), alignment: .top)
                        .padding(.top, 24)
                        .padding(.bottom, 120)
                        .background(
                            TopRoundedPanelBackground(fill: theme.surface)
                        )
                        .padding(.top, 22)
                    }
                }
            }
        }
    }

    private func header(topInset: CGFloat) -> some View {
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
    }

    private var latestSafetyLabel: String {
        guard let result = appState.latestScanResult else {
            return "--"
        }

        return "\(Int(result.score * 100))%"
    }
}

struct CategoryCard: View {
    let icon: String
    let title: String
    let theme: AppTheme

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(theme.isDark ? theme.textPrimary : theme.accent)
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct RecommendationCard: View {
    let title: String
    let subtitle: String
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
}

private struct HomeStatCard: View {
    let icon: String
    let value: String
    let title: String
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(theme.isDark ? theme.textPrimary : theme.deep)
                .frame(width: 36, height: 36)
                .background(theme.isDark ? Color.white.opacity(0.12) : theme.soft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private struct HomeInsightCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let fill: Color
    let textPrimary: Color
    let textSecondary: Color
    let isDarkContext: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(iconForeground)
                .frame(width: 48, height: 48)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(textPrimary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(textSecondary)
                    .lineSpacing(3)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(fill)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var iconForeground: Color {
        isDarkContext ? textPrimary : tint
    }

    private var iconBackground: Color {
        isDarkContext ? Color.white.opacity(0.12) : tint.opacity(0.12)
    }
}

var greeting: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 6..<12:  return String(localized: "Good Morning")
    case 12..<18: return String(localized: "Good Afternoon")
    default:      return String(localized: "Good Evening")
    }
}

#Preview {
    HomeView()
        .environment(AppStateViewModel())
}
