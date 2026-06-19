//
//  ListsView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct ListsView: View {
    @Environment(AppStateViewModel.self) private var appState

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)

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

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(Color.white)
                        .ignoresSafeArea(edges: .bottom)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Saved Reviews")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)

                            if appState.savedReviews.isEmpty {
                                EmptySavedReviewsView()
                            } else {
                                ForEach(appState.savedReviews) { product in
                                    SavedProductCard(product: product) {
                                        Task {
                                            await appState.deleteSavedReview(product)
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Insights")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))

                                Text("Products with fragrance continue to appear in your scans. Consider filtering for fragrance-free alternatives.")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.black.opacity(0.62))
                                    .lineSpacing(3)
                            }
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color(red: 0.972, green: 0.978, blue: 0.975))
                            )
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 24)
                        .padding(.bottom, 120)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}

private struct SavedProductCard: View {
    let product: SavedReview
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(product.status.color.opacity(0.14))
                .frame(width: 58, height: 58)
                .overlay {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(product.status.color)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.productName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                Text(product.status.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(product.status.color)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                    .frame(width: 34, height: 34)
                    .background(Color(red: 0.925, green: 0.302, blue: 0.302).opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct EmptySavedReviewsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "bookmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 0.459, green: 0.643, blue: 0.533))

            Text("No saved reviews yet")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Text("Scan a product and save the analysis to keep it here.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.58))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.972, green: 0.978, blue: 0.975))
        )
    }
}

#Preview {
    ListsView()
        .environment(AppStateViewModel())
}
