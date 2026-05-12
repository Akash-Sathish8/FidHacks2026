import SwiftUI

struct HomeView: View {
    @EnvironmentObject var app: AppState

    private let greeting: String = "Hi, Akash."

    // "Plush" font on Home — SwiftUI silently falls back to system if the
    // custom font isn't bundled, so we layer SF Rounded on top to keep the
    // warm/soft feel until a real Plush.ttf is added to the project.
    private func plush(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Text(greeting)
                        .font(plush(50, weight: .bold))       // 40 × 1.25
                        .foregroundStyle(Palette.ink)
                    Text("Your buddy is proud of you for showing up.")
                        .font(plush(19, weight: .regular))    // 15 × 1.25 ≈ 19
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.md)

                    GlassCard {
                        HStack(spacing: Spacing.lg) {
                            ZStack {
                                Circle().fill(Gradients.hero).frame(width: 72, height: 72)
                                Text("🦊").font(.system(size: 36))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Level \(app.user.level)")
                                    .font(plush(23, weight: .semibold))   // 18 × 1.25
                                    .foregroundStyle(Palette.ink)
                                Text("\(app.user.xp) XP · \(app.user.coins) coins")
                                    .font(plush(15, weight: .medium))     // 12 × 1.25
                                    .foregroundStyle(Palette.inkMuted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("🔥 \(app.user.streak)")
                                    .font(plush(23, weight: .semibold))
                                    .foregroundStyle(Palette.peachDeep)
                                Text("day streak")
                                    .font(plush(15, weight: .medium))
                                    .foregroundStyle(Palette.inkMuted)
                            }
                        }
                    }

                    Text("Today's move")
                        .font(plush(28, weight: .bold))       // 22 × 1.25
                        .foregroundStyle(Palette.ink)
                        .padding(.top, Spacing.md)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("QUEST")
                                .font(plush(14, weight: .bold))
                                .tracking(1.4)
                                .foregroundStyle(Palette.lavenderDeep)
                            Text("Read your first paycheck.")
                                .font(plush(23, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                            Text("Federal, state, FICA — where does it actually go?")
                                .font(plush(19, weight: .regular))
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

struct SettingsSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLocale: AppLocale = AppCurrency.current
    @State private var showResetConfirm: Bool = false

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("Settings").font(Typo.h2).foregroundStyle(Palette.ink)
                    Spacer()
                    Button("Done") { dismiss() }.foregroundStyle(Palette.lavenderDeep)
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LOCATION")
                            .font(.system(size: 10, weight: .bold)).tracking(1.2)
                            .foregroundStyle(Palette.inkMuted)
                        Menu {
                            ForEach(AppLocale.all) { loc in
                                Button {
                                    selectedLocale = loc
                                    app.setLocale(loc)
                                } label: {
                                    Text("\(loc.flag) \(loc.country) — \(loc.currencyCode)")
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(selectedLocale.flag)  \(selectedLocale.country)")
                                    .font(Typo.bodyBold).foregroundStyle(Palette.ink)
                                Spacer()
                                Text(selectedLocale.currencyCode)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Palette.inkMuted)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(Palette.lavenderSoft))
                                Text("▾").font(.system(size: 14)).foregroundStyle(Palette.inkMuted)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }

                Button {
                    showResetConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                        Text("Sign out — back to login").font(Typo.bodyBold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Capsule().fill(Palette.roseDeep))
                }.buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
        .alert("Sign out?",
               isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign out", role: .destructive) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    app.resetForNewSession()
                }
            }
        } message: {
            Text("This sends you back to the splash + onboarding flow. Your trade bests, goals, and accessories will be cleared.")
        }
    }
}

struct NameEditorSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("What should we call you?")
                        .font(Typo.h2).foregroundStyle(Palette.ink)
                    Spacer()
                    Button("Cancel") { dismiss() }.foregroundStyle(Palette.lavenderDeep)
                }
                TextField("Akash", text: $draft)
                    .font(Typo.h1).foregroundStyle(Palette.ink)
                    .focused($focused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                Rectangle().fill(Palette.lavenderDeep).frame(height: 2)
                Spacer()
                Button {
                    app.setName(draft)
                    dismiss()
                } label: {
                    Text("Save").font(Typo.bodyBold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Capsule().fill(Palette.lavenderDeep))
                }.buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
        .onAppear {
            draft = app.user.name
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { focused = true }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
