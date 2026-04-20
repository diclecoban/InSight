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
                    }

                    Spacer()

                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
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

                            ForEach(appState.savedReviews) { product in
                                SavedProductCard(product: product)
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

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.25))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ListsView()
        .environment(AppStateViewModel())
}
