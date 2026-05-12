import SwiftUI

struct SplashView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        GradientBackground {
            ZStack {
                // Centered cluster: logo + tagline — sits dead-center on screen
                VStack(spacing: 45) {     // gap below the logo
                    GeometryReader { geo in
                        Image("BudgetBloomLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.width)
                            .scaleEffect(1.7)
                            .shadow(color: Palette.lavenderDeep.opacity(0.2), radius: 36, x: 0, y: 20)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.leading, Spacing.lg)
                    .padding(.trailing, Spacing.xxl)  // extra right padding

                    Text("Make your wallet boom\nwith Budget Bloom.")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 40)    // adds visible gap above the bottom button

                // Bottom-pinned button
                VStack {
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
}

#Preview {
    SplashView().environmentObject(AppState())
}

