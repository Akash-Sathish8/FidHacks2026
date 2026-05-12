import SwiftUI

// Mocked Plaid-Link-style bank connection. The UI mirrors the real Plaid Link
// sheet: bank picker → loading → success. In production, swap the loading step
// with the actual Plaid Link iOS SDK callback and exchange the public_token
// on your backend for an access_token to call the /transactions endpoint.

struct Bank: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let tint: Color
}

let SUPPORTED_BANKS: [Bank] = {
    var out: [Bank] = []
    out.append(Bank(id: "chase",    name: "Chase",            emoji: "🏦", tint: Color(hex: 0x117ACA)))
    out.append(Bank(id: "boa",      name: "Bank of America",  emoji: "🇺🇸", tint: Color(hex: 0xCE1126)))
    out.append(Bank(id: "wells",    name: "Wells Fargo",      emoji: "🐎", tint: Color(hex: 0xC81E2E)))
    out.append(Bank(id: "citi",     name: "Citi",             emoji: "🏙", tint: Color(hex: 0x004BA0)))
    out.append(Bank(id: "capone",   name: "Capital One",      emoji: "💳", tint: Color(hex: 0x004979)))
    out.append(Bank(id: "apple",    name: "Apple Card",       emoji: "🍎", tint: Color.black))
    out.append(Bank(id: "amex",     name: "American Express", emoji: "🟦", tint: Color(hex: 0x006FCF)))
    out.append(Bank(id: "ally",     name: "Ally",             emoji: "🛡", tint: Color(hex: 0x6633CC)))
    out.append(Bank(id: "schwab",   name: "Charles Schwab",   emoji: "📈", tint: Color(hex: 0x0078A8)))
    out.append(Bank(id: "fidelity", name: "Fidelity",         emoji: "💚", tint: Color(hex: 0x368727)))
    return out
}()

struct BankConnectView: View {
    @EnvironmentObject var app: AppState
    let onClose: () -> Void

    enum Phase: Equatable {
        case picker
        case connecting(Bank)
        case success(Bank)
    }
    @State private var phase: Phase = .picker
    @State private var query: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            // Soft cream-to-lavender wash, NO giant decorative blobs (those were
            // dominating the empty space above the content). Keeps the brand feel.
            LinearGradient(colors: [Palette.cream, Color(hex: 0xF6EEF8), Color(hex: 0xEEF1FA)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                switch phase {
                case .picker:            pickerView
                case .connecting(let b): connectingView(b)
                case .success(let b):    successView(b)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Text(phase == .picker ? "Cancel" : "Done")
                    .font(Typo.bodyBold)
                    .foregroundStyle(Palette.lavenderDeep)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text("SECURE LINK")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
            }
            .foregroundStyle(Palette.inkMuted)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, Spacing.lg).padding(.top, Spacing.lg).padding(.bottom, Spacing.md)
    }

    // MARK: - Picker

    private var filteredBanks: [Bank] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return SUPPORTED_BANKS }
        return SUPPORTED_BANKS.filter { $0.name.lowercased().contains(q) }
    }

    private var pickerView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 6) {
                    Eyebrow(text: "Powered by Budget Bloom Link")
                    Text("Choose your bank.")
                        .font(Typo.h1).foregroundStyle(Palette.ink)
                    Text("We'll pull your recent transactions and categorize them automatically. Read-only — we can't move money.")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)
                }

                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(Palette.inkMuted)
                    TextField("Search 11k+ banks", text: $query)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Palette.glassBorder, lineWidth: 1))
                )

                LazyVStack(spacing: 8) {
                    ForEach(filteredBanks) { bank in
                        Button {
                            startConnect(bank)
                        } label: {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12).fill(bank.tint.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Text(bank.emoji).font(.system(size: 22))
                                }
                                Text(bank.name).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Palette.inkMuted)
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                        .stroke(Palette.glassBorder, lineWidth: 1))
                            )
                        }.buttonStyle(.plain)
                    }

                    if filteredBanks.isEmpty {
                        Text("No banks match \"\(query)\"")
                            .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, Spacing.lg)
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                    Text("256-bit encryption · We never see your password · Read-only access")
                        .font(.system(size: 11))
                }
                .foregroundStyle(Palette.inkMuted)
                .padding(.top, Spacing.md)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Connecting

    private func connectingView(_ bank: Bank) -> some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(bank.tint.opacity(0.15)).frame(width: 120, height: 120)
                Text(bank.emoji).font(.system(size: 60))
            }
            VStack(spacing: 8) {
                Text("Connecting to \(bank.name)…")
                    .font(Typo.h2).foregroundStyle(Palette.ink)
                Text("Negotiating secure link · pulling 30 days of transactions")
                    .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    .multilineTextAlignment(.center)
            }
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)
                .tint(Palette.lavenderDeep)
            Spacer()
        }
        .padding(.horizontal, Spacing.xxl)
        .onAppear {
            // Fake authentication delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                app.connectBank(bank.name)
                withAnimation(.easeInOut(duration: 0.35)) {
                    phase = .success(bank)
                }
            }
        }
    }

    // MARK: - Success

    private func successView(_ bank: Bank) -> some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(Palette.success.opacity(0.15)).frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 84, weight: .semibold))
                    .foregroundStyle(Palette.success)
            }
            VStack(spacing: 8) {
                Text("\(bank.name) connected.")
                    .font(Typo.h1).foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                Text("Recent transactions just landed in your categories. You'll keep syncing in the background.")
                    .font(Typo.body).foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            Spacer()
            Button(action: onClose) {
                Text("See your money").font(Typo.bodyBold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Capsule().fill(Palette.lavenderDeep))
            }.buttonStyle(.plain)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func startConnect(_ bank: Bank) {
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .connecting(bank)
        }
    }
}
