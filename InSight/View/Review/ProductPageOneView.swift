//
//  ProductPageOneView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct ProductPageOneView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var didShowSavedMessage = false

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var primaryActionColor: Color { theme.deep }
    private var secondaryActionColor: Color { theme.soft }

    private var scanResult: ScanResult {
        appState.latestScanResult ?? AppMockData.sampleScanResult
    }

    private var score: Double {
        scanResult.score
    }

    private var decisionTitle: String {
        switch scanResult.safetyLevel {
        case .safe:
            return String(localized: "Good match")
        case .mostlySafe:
            return String(localized: "Use with caution")
        case .risky:
            return String(localized: "Avoid for now")
        }
    }

    private var decisionSubtitle: String {
        if !allergyMatches.isEmpty {
            return String.localizedStringWithFormat(
                String(localized: "Your profile flags %@."),
                allergyMatches.joined(separator: ", ")
            )
        }

        if scanResult.ingredients.isEmpty {
            return String(localized: "The product was found, but ingredient data is limited.")
        }

        return scanResult.summary
    }

    private var safetyColor: Color {
        scanResult.safetyLevel.color
    }

    private var allergyMatches: [String] {
        scanResult.ingredients
            .map(\.name)
            .filter { ingredientName in
                appState.userProfile?.allergies.contains(where: {
                    $0.caseInsensitiveCompare(ingredientName) == .orderedSame
                }) ?? false
            }
    }

    private var dataQualityText: String {
        scanResult.ingredients.isEmpty
            ? String(localized: "We found the product, but the ingredient list is incomplete.")
            : String.localizedStringWithFormat(
                String(localized: "%lld ingredients checked for skin risk"),
                scanResult.ingredients.count
            )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                InSightScreenBackground(theme: theme)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header(topInset: proxy.safeAreaInsets.top)
                            .softAppear()

                        VStack(spacing: 0) {
                            VStack(spacing: 22) {
                                ProductHeroCard(product: scanResult.product, tint: safetyColor)
                                    .offset(y: -56)
                                    .padding(.bottom, -30)
                                    .softAppear(delay: 0.04)

                                DecisionSummaryCard(
                                    product: scanResult.product,
                                    title: decisionTitle,
                                    subtitle: decisionSubtitle,
                                    level: scanResult.safetyLevel,
                                    score: score,
                                    theme: theme
                                )
                                .padding(.horizontal, 22)
                                .softAppear(delay: 0.1)

                                VStack(spacing: 10) {
                                    DecisionReasonRow(
                                        icon: "person.crop.circle.badge.checkmark",
                                        title: "Profile match",
                                        value: allergyMatches.isEmpty
                                            ? String(localized: "No allergy match found")
                                            : allergyMatches.joined(separator: ", "),
                                        tint: allergyMatches.isEmpty ? theme.brand : InSightPalette.danger,
                                        fill: theme.panel,
                                        textPrimary: theme.textPrimary,
                                        textSecondary: theme.textSecondary,
                                        isDarkContext: theme.isDark
                                    )

                                    DecisionReasonRow(
                                        icon: "list.bullet.clipboard",
                                        title: "Ingredient info",
                                        value: dataQualityText,
                                        tint: scanResult.ingredients.isEmpty ? theme.gold : theme.brand,
                                        fill: theme.panel,
                                        textPrimary: theme.textPrimary,
                                        textSecondary: theme.textSecondary,
                                        isDarkContext: theme.isDark
                                    )

                                    DecisionReasonRow(
                                        icon: "checkmark.seal",
                                        title: "Review basis",
                                        value: "Reviewed with Open Beauty Facts ingredient information and InSight safety rules",
                                        tint: primaryActionColor,
                                        fill: theme.panel,
                                        textPrimary: theme.textPrimary,
                                        textSecondary: theme.textSecondary,
                                        isDarkContext: theme.isDark
                                    )
                                }
                                .padding(.horizontal, 22)
                                .softAppear(delay: 0.16)

                                SafetyBar(score: score, tint: safetyColor, theme: theme)
                                    .softAppear(delay: 0.2)

                                Button {
                                    Task {
                                        await appState.saveLatestScanResult()
                                        if appState.errorMessage == nil {
                                            didShowSavedMessage = true
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: appState.isLatestScanSaved ? "bookmark.fill" : "bookmark")
                                            .font(.system(size: 15, weight: .bold))

                                        Text(appState.isLatestScanSaved ? String(localized: "Saved to Reviews") : String(localized: "Save Review"))
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundStyle(appState.isLatestScanSaved ? secondaryButtonForeground : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(appState.isLatestScanSaved ? secondaryActionColor : primaryActionColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .padding(.horizontal, 24)
                                .disabled(appState.isLoading || appState.isLatestScanSaved)
                                .buttonStyle(PressableButtonStyle())

                                NavigationLink {
                                    DetailReview()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .font(.system(size: 15, weight: .bold))

                                        Text("See score details")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundStyle(secondaryButtonForeground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(secondaryActionColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .padding(.horizontal, 24)
                                .buttonStyle(PressableButtonStyle())

                                if let errorMessage = appState.errorMessage {
                                    Text(errorMessage)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 28)
                                } else if didShowSavedMessage {
                                    Text("This analysis is now available in Saved Reviews.")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(theme.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 28)
                                }
                            }
                            .padding(.top, 36)
                            .padding(.bottom, 140)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(0, proxy.size.height - 170), alignment: .top)
                        .background(
                            TopRoundedPanelBackground(fill: theme.surface)
                        )
                        .padding(.top, 36)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func header(topInset: CGFloat) -> some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(backgroundColor)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.94))
                    .clipShape(Circle())
            }
            .accessibilityLabel(Text("Back to Scan"))
            .buttonStyle(PressableButtonStyle(scale: 0.9))

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
            .padding(.leading, 4)

            Spacer()

            Image(systemName: "bell.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 62)
    }

    private var secondaryButtonForeground: Color {
        theme.isDark ? theme.textPrimary : primaryActionColor
    }
}

private struct ProductHeroCard: View {
    let product: Product
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .frame(width: 150, height: 150)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.964, green: 0.973, blue: 0.992),
                            Color(red: 0.905, green: 0.929, blue: 0.976)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 132, height: 132)
                .overlay {
                    productVisual
                }
        }
    }

    @ViewBuilder
    private var productVisual: some View {
        if let imageURL = product.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: 132, height: 132)
                case .failure:
                    fallbackVisual
                case .empty:
                    ProgressView()
                        .tint(tint)
                @unknown default:
                    fallbackVisual
                }
            }
        } else {
            fallbackVisual
        }
    }

    private var fallbackVisual: some View {
        VStack(spacing: 10) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(tint)

            Text(product.brand)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.55))
                .lineLimit(1)
                .padding(.horizontal, 14)

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}

private struct DecisionSummaryCard: View {
    let product: Product
    let title: String
    let subtitle: String
    let level: SafetyLevel
    let score: Double
    let theme: AppTheme

    var body: some View {
        InSightCard(fill: theme.card) {
            VStack(spacing: 14) {
                StatusPill(level: level)

                VStack(spacing: 7) {
                    Text(product.brand)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(1)

                    Text(product.name)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)

                    Text(product.barcode)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                }

                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(level.color)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                Text("\(Int(score * 100))%")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(level.color)
                    .accessibilityLabel(Text("Safety score \(Int(score * 100)) percent"))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct DecisionReasonRow: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color
    var fill: Color = InSightPalette.panel
    var textPrimary: Color = .black
    var textSecondary: Color = Color.black.opacity(0.48)
    var isDarkContext = false

    var body: some View {
        InSightCard(fill: fill, cornerRadius: 18) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isDarkContext ? textPrimary : tint)
                    .frame(width: 34, height: 34)
                    .background(isDarkContext ? Color.white.opacity(0.12) : tint.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(textSecondary)

                    Text(value)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(textPrimary.opacity(0.82))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

private struct SafetyBar: View {
    let score: Double
    let tint: Color
    let theme: AppTheme

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Safety Score")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)

                Spacer()

                Text("\(Int(score * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.textSecondary.opacity(theme.isDark ? 0.18 : 0.14))
                        .frame(height: 10)

                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * score, height: 10)
                        .animation(.spring(response: 0.7, dampingFraction: 0.82), value: score)
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ProductPageOneView()
        .environment(AppStateViewModel())
}
