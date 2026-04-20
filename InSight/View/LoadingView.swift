//
//  LoadingView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct LoadingView: View {
    @State private var animateRing = false

    private let backgroundColor = Color(red: 0.459, green: 0.643, blue: 0.533)
    private let ringColor = Color(red: 0.507, green: 0.514, blue: 0.922)

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

                        Text("Susan Clay")
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

                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(Color.white)
                        .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 22) {
                        Text("Please wait")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.8))

                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.08), lineWidth: 12)
                                .frame(width: 92, height: 92)

                            Circle()
                                .trim(from: 0.05, to: 0.73)
                                .stroke(
                                    AngularGradient(
                                        colors: [ringColor.opacity(0.2), ringColor],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 92, height: 92)
                                .rotationEffect(.degrees(animateRing ? 360 : 0))
                                .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: animateRing)
                        }

                        Text("We're working hard\nfor you to have perfect\nresults!")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.black.opacity(0.62))
                            .lineSpacing(3)
                    }
                    .padding(.bottom, 100)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            animateRing = true
        }
    }
}

#Preview {
    LoadingView()
}
