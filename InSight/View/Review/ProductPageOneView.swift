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

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let primaryActionColor = Color(red: 0.208, green: 0.431, blue: 0.329)
    private let secondaryActionColor = Color(red: 0.898, green: 0.941, blue: 0.918)

    private var scanResult: ScanResult {
        appState.latestScanResult ?? AppMockData.sampleScanResult
    }

    private var score: Double {
        scanResult.score
    }

    private var safetyText: String {
        scanResult.safetyLevel.title
    }

    private var safetyColor: Color {
        scanResult.safetyLevel.color
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
                            VStack(spacing: 22) {
                                ProductHeroCard(product: scanResult.product, tint: safetyColor)
                                    .offset(y: -56)
                                    .padding(.bottom, -30)

                                VStack(spacing: 10) {
                                    Text(scanResult.product.brand)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.black.opacity(0.45))

                                    Text(scanResult.product.name)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)

                                    Text(scanResult.product.barcode)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color.black.opacity(0.5))

                                    Text("This Product is")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)

                                    Text(safetyText)
                                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                                        .foregroundStyle(safetyColor)
                                }
                                .multilineTextAlignment(.center)

                                Text(scanResult.summary)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.black.opacity(0.58))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 28)

                                SafetyBar(score: score, tint: safetyColor)

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
                                    .foregroundStyle(appState.isLatestScanSaved ? primaryActionColor : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(appState.isLatestScanSaved ? secondaryActionColor : primaryActionColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .padding(.horizontal, 24)
                                .disabled(appState.isLoading || appState.isLatestScanSaved)

                                NavigationLink {
                                    DetailReview()
                                } label: {
                                    Text("Click here to see details")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(primaryActionColor)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(secondaryActionColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .padding(.horizontal, 24)

                                if let errorMessage = appState.errorMessage {
                                    Text(errorMessage)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color(red: 0.925, green: 0.302, blue: 0.302))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 28)
                                } else if didShowSavedMessage {
                                    Text("This analysis is now available in Saved Reviews.")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color.black.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 28)
                                }
                            }
                            .padding(.top, 36)
                            .padding(.bottom, 140)
                        }
                    }
                    .padding(.top, 36)
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

private struct SafetyBar: View {
    let score: Double
    let tint: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Safety Score")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.55))

                Spacer()

                Text("\(Int(score * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 10)

                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * score, height: 10)
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
