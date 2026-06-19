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

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 0.953, green: 0.643, blue: 0.286)

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
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header(topInset: proxy.safeAreaInsets.top)

                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(Color.white)
                            .ignoresSafeArea(edges: .bottom)

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 18) {
                                HStack(spacing: 16) {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.black.opacity(0.06))
                                        .frame(width: 96, height: 112)
                                        .overlay {
                                            Image(systemName: "doc.text.image.fill")
                                                .font(.system(size: 32))
                                                .foregroundStyle(accentColor)
                                        }

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(scanResult.product.name)
                                            .font(.system(size: 19, weight: .bold, design: .rounded))
                                            .lineLimit(2)

                                        Text(scoreText)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundStyle(scanResult.safetyLevel.color)

                                        Text(scanResult.summary)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color.black.opacity(0.6))
                                    }

                                    Spacer()
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                                )

                                DetailSection(title: "Overview") {
                                    Text(scanResult.summary)
                                }

                                DetailSection(title: "Ingredients") {
                                    if scanResult.ingredients.isEmpty {
                                        Text("No ingredient details were found for this product.")
                                    } else {
                                        ForEach(scanResult.ingredients) { ingredient in
                                            IngredientDetailRow(ingredient: ingredient)
                                        }
                                    }
                                }

                                DetailSection(title: "Why It Matters") {
                                    Text(personalizedExplanation)
                                }
                            }
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.72))
                            .padding(.horizontal, 22)
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                        }
                    }
                    .padding(.top, 20)
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
            return String(localized: "The score is based on the ingredient risk notes available for this product.")
        }

        return String.localizedStringWithFormat(
            String(localized: "%@ appears in your allergy list, so this product may need extra caution."),
            allergyMatches.joined(separator: ", ")
        )
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(3)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct IngredientDetailRow: View {
    let ingredient: IngredientInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ingredient.name)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Text(ingredient.detail)
                .foregroundStyle(Color.black.opacity(0.68))

            Text(ingredient.riskNote)
                .foregroundStyle(Color.black.opacity(0.52))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

#Preview {
    DetailReview()
        .environment(AppStateViewModel())
}
