import SwiftUI

struct HomeView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Today")
                    Text("Hi \(app.user.name).")
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                    Text("Your buddy is proud of you for showing up.")
                        .font(Typo.body)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.md)

                    GlassCard {
                        HStack(spacing: Spacing.lg) {
                            ZStack {
                                Circle().fill(Gradients.hero).frame(width: 72, height: 72)
                                Text("🦊").font(.system(size: 36))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Level \(app.user.level)").font(Typo.h3).foregroundStyle(Palette.ink)
                                Text("\(app.user.xp) XP · \(app.user.coins) coins")
                                    .font(Typo.caption)
                                    .foregroundStyle(Palette.inkMuted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("🔥 \(app.user.streak)").font(Typo.h3).foregroundStyle(Palette.peachDeep)
                                Text("day streak").font(Typo.caption).foregroundStyle(Palette.inkMuted)
                            }
                        }
                    }

                    Text("Today's move")
                        .font(Typo.h2).foregroundStyle(Palette.ink)
                        .padding(.top, Spacing.md)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Eyebrow(text: "Quest")
                            Text("Read your first paycheck.")
                                .font(Typo.h3).foregroundStyle(Palette.ink)
                            Text("Federal, state, FICA — where does it actually go?")
                                .font(Typo.body)
                                .foregroundStyle(Palette.inkSoft)
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
