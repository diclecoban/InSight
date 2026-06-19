//
//  ListsView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct ListsView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var selectedFilter: SavedReviewFilter = .all

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }

    private var filteredReviews: [SavedReview] {
        appState.savedReviews.filter { review in
            selectedFilter.matches(review)
        }
    }

    private var safeCount: Int {
        appState.savedReviews.filter { $0.status == .safe }.count
    }

    private var cautionCount: Int {
        appState.savedReviews.filter { $0.status == .mostlySafe }.count
    }

    private var riskyCount: Int {
        appState.savedReviews.filter { $0.status == .risky }.count
    }

    var body: some View {
        NavigationStack {
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

                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 52)
                            .softAppear()

                            VStack(alignment: .leading, spacing: 18) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Saved Reviews")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(theme.textPrimary)

                                        Text("\(filteredReviews.count) products")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundStyle(theme.textSecondary)
                                    }

                                    Spacer()
                                }
                                .softAppear(delay: 0.06)

                                HStack(spacing: 10) {
                                    SavedSummaryCard(title: "Safe", value: safeCount, tint: SafetyLevel.safe.color, theme: theme)
                                    SavedSummaryCard(title: "Caution", value: cautionCount, tint: SafetyLevel.mostlySafe.color, theme: theme)
                                    SavedSummaryCard(title: "Risky", value: riskyCount, tint: SafetyLevel.risky.color, theme: theme)
                                }
                                .softAppear(delay: 0.08)

                                SavedReviewFilterBar(selectedFilter: $selectedFilter, theme: theme)
                                    .softAppear(delay: 0.12)

                                if appState.savedReviews.isEmpty {
                                    EmptySavedReviewsView()
                                        .softAppear(delay: 0.16)
                                } else if filteredReviews.isEmpty {
                                    EmptyStateCard(
                                        icon: "line.3.horizontal.decrease.circle",
                                        title: "No products in this filter",
                                        message: "Try another safety filter to see more saved reviews.",
                                        tint: theme.gold,
                                        fill: theme.panel,
                                        textPrimary: theme.textPrimary,
                                        textSecondary: theme.textSecondary,
                                        isDarkContext: theme.isDark
                                    )
                                    .softAppear(delay: 0.16)
                                } else {
                                    ForEach(filteredReviews) { product in
                                        NavigationLink {
                                            SavedReviewDetailView(product: product)
                                        } label: {
                                            SavedProductCard(product: product) {
                                                Task {
                                                    await appState.deleteSavedReview(product)
                                                }
                                            }
                                            .environment(appState)
                                        }
                                        .buttonStyle(PressableButtonStyle())
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                                            removal: .opacity.combined(with: .scale(scale: 0.96))
                                        ))
                                    }
                                }

                                InSightCard(fill: theme.panel) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Insights")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(theme.textPrimary)

                                        Text("Use filters to compare safe, cautious, and risky products before buying again.")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textSecondary)
                                            .lineSpacing(3)
                                    }
                                }
                                .softAppear(delay: 0.18)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: max(0, proxy.size.height - 150), alignment: .top)
                            .padding(.horizontal, 22)
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                            .background(
                                TopRoundedPanelBackground(fill: theme.surface)
                            )
                            .padding(.top, 20)
                            .animation(.spring(response: 0.42, dampingFraction: 0.82), value: selectedFilter)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct SavedSummaryCard: View {
    let title: String
    let value: Int
    let tint: Color
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)

            Text("\(value)")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(theme.textPrimary)

            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private enum SavedReviewFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case safe = "Safe"
    case mostlySafe = "Caution"
    case risky = "Risky"

    var id: String { rawValue }

    func matches(_ review: SavedReview) -> Bool {
        switch self {
        case .all:
            return true
        case .safe:
            return review.status == .safe
        case .mostlySafe:
            return review.status == .mostlySafe
        case .risky:
            return review.status == .risky
        }
    }
}

private struct SavedReviewFilterBar: View {
    @Binding var selectedFilter: SavedReviewFilter
    let theme: AppTheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SavedReviewFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(filterForeground(isSelected: selectedFilter == filter))
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .background(filterBackground(isSelected: selectedFilter == filter))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.94))
                }
            }
        }
    }

    private func filterForeground(isSelected: Bool) -> Color {
        if isSelected {
            return .white
        }

        return theme.isDark ? theme.textPrimary : theme.deep
    }

    private func filterBackground(isSelected: Bool) -> Color {
        if isSelected {
            return theme.isDark ? theme.accent : theme.deep
        }

        return theme.isDark ? Color.white.opacity(0.12) : theme.soft
    }
}

private struct SavedProductCard: View {
    @Environment(AppStateViewModel.self) private var appState

    let product: SavedReview
    let onDelete: () -> Void

    private var theme: AppTheme { appState.selectedTheme }

    var body: some View {
        HStack(spacing: 14) {
            ProductThumbnail(
                imageURL: product.imageURL,
                brand: product.brand,
                tint: product.status.color,
                size: 62,
                isDarkContext: theme.isDark
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(product.productName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(2)

                Text(product.brand.isEmpty ? product.barcode : product.brand)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary)

                StatusPill(level: product.status)
            }

            Spacer()

            Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(theme.isDark ? Color.white.opacity(0.92) : InSightPalette.danger)
                    .frame(width: 34, height: 34)
                    .background(theme.isDark ? Color.white.opacity(0.12) : InSightPalette.danger.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(PressableButtonStyle(scale: 0.9))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.card)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct EmptySavedReviewsView: View {
    @Environment(AppStateViewModel.self) private var appState

    private var theme: AppTheme { appState.selectedTheme }

    var body: some View {
        EmptyStateCard(
            icon: "bookmark",
            title: "No saved reviews yet",
            message: "Scan a product and save the analysis to keep it here.",
            fill: theme.panel,
            textPrimary: theme.textPrimary,
            textSecondary: theme.textSecondary,
            isDarkContext: theme.isDark
        )
    }
}

private struct SavedReviewDetailView: View {
    @Environment(AppStateViewModel.self) private var appState

    let product: SavedReview

    private var theme: AppTheme { appState.selectedTheme }

    var body: some View {
        ZStack {
            theme.surface
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 16) {
                        ProductThumbnail(
                            imageURL: product.imageURL,
                            brand: product.brand,
                            tint: product.status.color,
                            size: 92,
                            isDarkContext: theme.isDark
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            StatusPill(level: product.status)

                            Text(product.productName)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textPrimary)
                                .lineLimit(3)

                            Text(product.brand)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textSecondary)
                        }
                    }

                    InSightCard(fill: theme.panel) {
                        VStack(alignment: .leading, spacing: 12) {
                            SavedDetailRow(title: "Barcode", value: product.barcode, theme: theme)
                            SavedDetailRow(title: "Saved", value: product.savedAt.formatted(date: .abbreviated, time: .shortened), theme: theme)
                            SavedDetailRow(title: "Decision", value: product.status.title, theme: theme)
                        }
                    }

                    Text("Open a fresh scan for the latest personalized score if your profile information has changed.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .lineSpacing(3)
                }
                .padding(22)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("Saved Product")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SavedDetailRow: View {
    let title: String
    let value: String
    let theme: AppTheme

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary.opacity(0.82))
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ListsView()
        .environment(AppStateViewModel())
}
