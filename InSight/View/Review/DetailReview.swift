//
//  ProductPageTwoView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct DetailReview: View {
    @State private var userName: String = "Susan Clay"

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let accentColor = Color(red: 0.953, green: 0.643, blue: 0.286)

    private let ingredients = [
        "Water, Glycerin, Butylene Glycol, Niacinamide, Sodium Hyaluronate, Tocopherol, Panthenol, Fragrance",
        "Contains fragrance and alcohol derivatives that may irritate sensitive skin in repeated use.",
        "Low-risk hydration ingredients are present, but the formula is not ideal for very reactive skin."
    ]

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

                        Text(userName)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    Spacer()

                    Image(systemName: "bell.fill")
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
                                    Text("CERAVE Cleanser")
                                        .font(.system(size: 19, weight: .bold, design: .rounded))

                                    Text("Score 70 / 100")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(accentColor)

                                    Text("The product is 70% safe.")
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
                                Text("This formula delivers hydration and barrier support, but a few components may not suit highly sensitive users.")
                            }

                            DetailSection(title: "Ingredients") {
                                ForEach(ingredients, id: \.self) { item in
                                    Text(item)
                                }
                            }

                            DetailSection(title: "Why It Matters") {
                                Text("Humectants like glycerin help retain water, while fragrance can raise irritation risk depending on skin sensitivity.")
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
        .toolbar(.hidden, for: .navigationBar)
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

#Preview {
    DetailReview()
}
