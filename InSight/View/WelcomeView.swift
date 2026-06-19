//
//  WelcomeView.swift
//  InSight
//
//  Created by Dicle Sara Coban on 15.03.2026.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var scanOffset: CGFloat = -58
    @State private var cardLift = false
    @State private var selectedIngredient = 0

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 1.0, green: 0.176, blue: 0.333)
    private let amberColor = Color(red: 0.953, green: 0.643, blue: 0.286)
    private let paperColor = Color(red: 0.972, green: 0.978, blue: 0.975)
    private let ingredients = ["Glycerin", "Niacinamide", "Fragrance"]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("InSight")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Know what you're using before it touches your skin.")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.86))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 28)

                    Spacer(minLength: 18)

                    animatedScanner
                        .padding(.horizontal, 26)

                    Spacer(minLength: 22)

                    VStack(spacing: 12) {
                        NavigationLink {
                            LoginView()
                        } label: {
                            Label("Log In", systemImage: "arrow.right.circle.fill")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        NavigationLink {
                            PageOneView()
                        } label: {
                            Label("Sign Up", systemImage: "person.badge.plus")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.black.opacity(0.78))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.white.opacity(0.94))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                startAnimations()
            }
        }
    }

    private var animatedScanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 18)

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Daily Cleanser")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(.black)

                        Text("Sensitive skin review")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.48))
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(backgroundColor.opacity(0.14))
                            .frame(width: 48, height: 48)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(backgroundColor)
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(paperColor)
                        .frame(height: 148)

                    VStack(spacing: 13) {
                        productBottle

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 7)

                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(backgroundColor)
                                .frame(width: cardLift ? 184 : 92, height: 7)
                        }
                        .padding(.horizontal, 18)
                    }

                    Rectangle()
                        .fill(amberColor)
                        .frame(height: 3)
                        .shadow(color: amberColor.opacity(0.55), radius: 8)
                        .offset(y: scanOffset)
                        .padding(.horizontal, 22)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                HStack(spacing: 8) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        Text(ingredients[index])
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(index == selectedIngredient ? .white : Color.black.opacity(0.62))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                            .padding(.horizontal, 10)
                            .frame(height: 30)
                            .background(index == selectedIngredient ? ingredientColor(index) : Color.black.opacity(0.06))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(18)
            .offset(y: cardLift ? -6 : 0)
        }
        .frame(height: 330)
    }

    private var productBottle: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.905, green: 0.929, blue: 0.976)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 72, height: 98)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                VStack(spacing: 8) {
                    Capsule()
                        .fill(backgroundColor.opacity(0.7))
                        .frame(width: 28, height: 8)

                    Image(systemName: "drop.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(backgroundColor)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.black.opacity(0.12))
                        .frame(width: 42, height: 7)
                }
            }

            VStack(alignment: .leading, spacing: 9) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(index == selectedIngredient ? ingredientColor(index) : Color.black.opacity(0.12))
                        .frame(width: index == 1 ? 122 : 148 - CGFloat(index * 12), height: 9)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
    }

    private func ingredientColor(_ index: Int) -> Color {
        switch index {
        case 2:
            return accentColor
        case 1:
            return amberColor
        default:
            return backgroundColor
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.45).repeatForever(autoreverses: true)) {
            scanOffset = 58
            cardLift = true
        }

        Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { _ in
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                selectedIngredient = (selectedIngredient + 1) % ingredients.count
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppStateViewModel())
}
