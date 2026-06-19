import SwiftUI

enum InSightPalette {
    static let brand = Color(red: 0.459, green: 0.643, blue: 0.533)
    static let deepGreen = Color(red: 0.208, green: 0.431, blue: 0.329)
    static let softGreen = Color(red: 0.898, green: 0.941, blue: 0.918)
    static let gold = Color(red: 0.953, green: 0.643, blue: 0.286)
    static let panel = Color(red: 0.972, green: 0.978, blue: 0.975)
    static let danger = Color(red: 0.925, green: 0.302, blue: 0.302)
}

struct InSightCard<Content: View>: View {
    var fill: Color = .white
    var cornerRadius: CGFloat = 22
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
    }
}

struct StatusPill: View {
    let level: SafetyLevel

    var body: some View {
        Text(level.title)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(level.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(level.color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct ProductThumbnail: View {
    let imageURL: URL?
    let brand: String
    let tint: Color
    var size: CGFloat = 64
    var isDarkContext = false

    var body: some View {
        RoundedRectangle(cornerRadius: min(18, size * 0.28), style: .continuous)
            .fill(isDarkContext ? Color.white.opacity(0.12) : tint.opacity(0.12))
            .frame(width: size, height: size)
            .overlay {
                if let imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFit()
                                .padding(size * 0.1)
                        case .failure:
                            fallbackVisual
                        case .empty:
                            ProgressView()
                                .tint(thumbnailForeground)
                        @unknown default:
                            fallbackVisual
                        }
                    }
                } else {
                    fallbackVisual
                }
            }
    }

    private var fallbackVisual: some View {
        VStack(spacing: 4) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: max(18, size * 0.34), weight: .semibold))
                .foregroundStyle(thumbnailForeground)

            if !brand.isEmpty, size > 58 {
                Text(brand)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(isDarkContext ? Color.white.opacity(0.72) : Color.black.opacity(0.52))
                    .lineLimit(1)
                    .padding(.horizontal, 6)
            }
        }
    }

    private var thumbnailForeground: Color {
        isDarkContext ? Color.white.opacity(0.9) : tint
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    var tint: Color = InSightPalette.brand
    var fill: Color = InSightPalette.panel
    var textPrimary: Color = .black
    var textSecondary: Color = Color.black.opacity(0.58)
    var isDarkContext = false

    var body: some View {
        InSightCard(fill: fill) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isDarkContext ? textPrimary : tint)

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(textPrimary)

                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(textSecondary)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TopRoundedPanelBackground: View {
    var fill: Color = .white
    var cornerRadius: CGFloat = 34

    var body: some View {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: cornerRadius,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: cornerRadius
            ),
            style: .continuous
        )
        .fill(fill)
    }
}

struct InSightScreenBackground: View {
    var theme: AppTheme = .clinicalWarm
    var topHeight: CGFloat = 280

    var body: some View {
        ZStack(alignment: .top) {
            theme.surface
                .ignoresSafeArea()

            theme.brand
                .frame(height: topHeight)
                .ignoresSafeArea(edges: .top)
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct OnboardingBackButton: View {
    let action: () -> Void
    var tint: Color = InSightPalette.deepGreen

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.94))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
        .accessibilityLabel(Text("Back"))
    }
}

struct SoftAppearModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 18)
            .onAppear {
                withAnimation(.spring(response: 0.52, dampingFraction: 0.82).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func softAppear(delay: Double = 0) -> some View {
        modifier(SoftAppearModifier(delay: delay))
    }
}
