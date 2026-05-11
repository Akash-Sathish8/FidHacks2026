import SwiftUI

struct SplashView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        GradientBackground {
            VStack(spacing: Spacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Gradients.hero)
                        .frame(width: 180, height: 180)
                        .shadow(color: Palette.lavenderDeep.opacity(0.35), radius: 40, x: 0, y: 24)
                    Text("✦")
                        .font(.system(size: 96))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 6) {
                    Eyebrow(text: "FidHacks 2026")
                    Text("Budget Bloom.")
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                    Text("Make your wallet boom with Budget Bloom.")
                        .font(Typo.body)
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                }
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.md)

                Spacer()

                GradientButton(title: "Get started") {
                    app.route = .login
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
        }
    }
}

#Preview {
    SplashView().environmentObject(AppState())
}
