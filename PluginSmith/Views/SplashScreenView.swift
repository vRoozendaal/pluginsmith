import SwiftUI

struct SplashScreenView: View {
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color(.windowBackgroundColor)
                .ignoresSafeArea()

            // Subtle radial glow behind icon
            RadialGradient(
                colors: [
                    Color.accentColor.opacity(glowOpacity * 0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 200
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // App icon
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(.tint)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                // App name
                Text("PluginSmith")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .opacity(titleOpacity)

                // Tagline
                Text("Claude Code Plugin & Skill Builder")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.secondary)
                    .opacity(subtitleOpacity)

                Spacer()

                // Version
                Text("v0.1.0")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.quaternary)
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Staggered entrance animation
            withAnimation(.easeOut(duration: 0.8)) {
                iconScale = 1.0
                iconOpacity = 1.0
                glowOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                titleOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.7).delay(0.6)) {
                subtitleOpacity = 1.0
            }
        }
    }
}
