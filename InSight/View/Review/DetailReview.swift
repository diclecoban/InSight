//
//  ProductPageTwoView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct DetailReview: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var accentColor: Color { theme.gold }

    private var scanResult: ScanResult {
        appState.latestScanResult ?? AppMockData.sampleScanResult
    }

    private var scoreText: String {
        String.localizedStringWithFormat(
            String(localized: "Score %lld / 100"),
            Int(scanResult.score * 100)
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
                            VStack(alignment: .leading, spacing: 18) {
                                HStack(spacing: 16) {
                                    ProductThumbnail(
                                        imageURL: scanResult.product.imageURL,
                                        brand: scanResult.product.brand,
                                        tint: scanResult.safetyLevel.color,
                                        size: 96,
                                        isDarkContext: theme.isDark
                                    )

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(scanResult.product.name)
                                            .font(.system(size: 19, weight: .bold, design: .rounded))
                                            .foregroundStyle(theme.textPrimary)
                                            .lineLimit(2)

                                        Text(scoreText)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundStyle(scanResult.safetyLevel.color)

                                        Text(scanResult.summary)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textSecondary)
                                    }

                                    Spacer()
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(theme.card)
                                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                                )
                                .softAppear(delay: 0.06)

                                DetailSection(title: "Overview", theme: theme) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(scanResult.summary)

                                        Text("This result is based on Open Beauty Facts ingredient information and InSight safety rules.")
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                }
                                .softAppear(delay: 0.12)

                                DetailSection(title: "Ingredients", theme: theme) {
                                    if scanResult.ingredients.isEmpty {
                                        Text("No ingredient details were found for this product.")
                                    } else {
                                        ForEach(scanResult.ingredients) { ingredient in
                                            IngredientDetailRow(ingredient: ingredient, theme: theme)
                                        }
                                    }
                                }
                                .softAppear(delay: 0.18)

                                DetailSection(title: "Why It Matters", theme: theme) {
                                    Text(personalizedExplanation)
                                }
                                .softAppear(delay: 0.24)
                            }
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textPrimary.opacity(0.82))
                            .padding(.horizontal, 22)
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(0, proxy.size.height - 150), alignment: .top)
                        .background(
                            TopRoundedPanelBackground(fill: theme.surface)
                        )
                        .padding(.top, 20)
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
            .accessibilityLabel(Text("Back to Results"))
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
        .padding(.bottom, 52)
    }

    private var personalizedExplanation: String {
        let allergyMatches = scanResult.ingredients
            .map(\.name)
            .filter { ingredientName in
                appState.userProfile?.allergies.contains(where: {
                    $0.caseInsensitiveCompare(ingredientName) == .orderedSame
                }) ?? false
            }

        if allergyMatches.isEmpty {
            return String(localized: "The score compares the listed ingredients with common skin-risk signals and your profile preferences.")
        }

        return String.localizedStringWithFormat(
            String(localized: "%@ appears in your allergy list, so this product may need extra caution."),
            allergyMatches.joined(separator: ", ")
        )
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    let theme: AppTheme
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(3)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.card)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct IngredientDetailRow: View {
    let ingredient: IngredientInsight
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(ingredient.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                Spacer()

                Text(ingredient.riskLevel.capitalized)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(riskColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(riskColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            Text(ingredient.detail)
                .foregroundStyle(theme.textPrimary.opacity(0.78))

            Text(ingredient.riskNote)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var riskColor: Color {
        switch ingredient.riskLevel.lowercased() {
        case "high":
            return InSightPalette.danger
        case "medium":
            return InSightPalette.gold
        default:
            return theme.brand
        }
    }
}

#Preview {
    DetailReview()
        .environment(AppStateViewModel())
}
