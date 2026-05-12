import SwiftUI

struct LoginView: View {
    @EnvironmentObject var app: AppState
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedLocale: AppLocale = .usa

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Welcome")
                    Text("Let's get to\nknow you.")
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                    Text("Name, email, and where you live — we'll show money in your currency.")
                        .font(Typo.body)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.lg)

                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            labeledField(label: "First name", placeholder: "Akash", text: $name)
                            Divider().background(Palette.glassBorder)
                            labeledField(label: "Email", placeholder: "you@school.edu", text: $email)
                            Divider().background(Palette.glassBorder)
                            locationPicker
                        }
                    }

                    Spacer().frame(height: Spacing.lg)

                    GradientButton(title: "Continue") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        app.user.name = trimmed
                        app.user.email = email
                        app.setLocale(selectedLocale)
                        app.route = .buddyPicker
                    }

                    Spacer(minLength: Spacing.xxxl)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .onAppear {
            selectedLocale = AppLocale.find(app.user.localeId)
            if !app.user.name.isEmpty { name = app.user.name }
            if !app.user.email.isEmpty { email = app.user.email }
        }
    }

    private var locationPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("LOCATION")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Palette.inkMuted)
            Menu {
                ForEach(AppLocale.all) { loc in
                    Button {
                        selectedLocale = loc
                    } label: {
                        Label("\(loc.flag) \(loc.country) — \(loc.currencyCode)", systemImage: "")
                    }
                }
            } label: {
                HStack {
                    Text("\(selectedLocale.flag)  \(selectedLocale.country)")
                        .font(Typo.bodyBold)
                        .foregroundStyle(Palette.ink)
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

    @ViewBuilder
    private func labeledField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Palette.inkMuted)
            TextField(placeholder, text: text)
                .font(Typo.bodyBold)
                .foregroundStyle(Palette.ink)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
        }
    }
}

#Preview {
    LoginView().environmentObject(AppState())
}
