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

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 0.953, green: 0.643, blue: 0.286)

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
                                        .foregroundStyle(.black)
                                    Text("place")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(backgroundColor)
                                }
                                .multilineTextAlignment(.center)

                                HStack(spacing: 12) {
                                    CategoryCard(icon: "bag.fill", title: String(localized: "Skin Care"))
                                    CategoryCard(icon: "heart.fill", title: String(localized: "Food"))
                                }
                                .padding(.horizontal, 24)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recommended for You")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 24)

                                    if appState.recommendations.isEmpty {
                                        RecommendationCard(
                                            title: String(localized: "No recommendations yet"),
                                            subtitle: String(localized: "Scan a product to personalize this area.")
                                        )
                                    } else {
                                        ForEach(appState.recommendations) { recommendation in
                                            RecommendationCard(
                                                title: recommendation.title,
                                                subtitle: recommendation.subtitle
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                        }
                    }
                    .padding(.top, 22)
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
}

struct CategoryCard: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.996, green: 0.761, blue: 0.471), Color(red: 0.957, green: 0.443, blue: 0.365)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct RecommendationCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
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
