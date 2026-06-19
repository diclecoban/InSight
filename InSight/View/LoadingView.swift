//
//  LoadingView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct LoadingView: View {
    @Environment(AppStateViewModel.self) private var appState

    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    @State private var animateRing = false

    private var backgroundColor: Color { appState.selectedTheme.brand }
    private var ringColor: Color { appState.selectedTheme.accent }

    init(
        title: LocalizedStringKey = "Please wait",
        subtitle: LocalizedStringKey = "We're working hard\nfor you to have perfect\nresults!"
    ) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        ZStack(alignment: .top) {
            InSightScreenBackground(theme: appState.selectedTheme)

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("InSight")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Checking your workspace")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
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
                    TopRoundedPanelBackground(fill: appState.selectedTheme.surface)
                        .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 22) {
                        Text(title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(appState.selectedTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)

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

                        Text(subtitle)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(appState.selectedTheme.textSecondary)
                            .lineSpacing(3)
                            .lineLimit(4)
                            .minimumScaleFactor(0.82)
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
        .environment(AppStateViewModel())
}
