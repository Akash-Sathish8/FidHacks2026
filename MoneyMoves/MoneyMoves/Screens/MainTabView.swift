import SwiftUI

struct MainTabView: View {
    @State private var selection: Tab = .play

    enum Tab: Hashable, CaseIterable {
        case home, quests, play, money, squad, buddy

        var label: String {
            switch self {
            case .home: return "Home"
            case .quests: return "Quests"
            case .play: return "Play"
            case .money: return "Money"
            case .squad: return "Squad"
            case .buddy: return "Buddy"
            }
        }
        var glyph: String {
            switch self {
            case .home: return "✦"
            case .quests: return "✧"
            case .play: return "◈"
            case .money: return "◐"
            case .squad: return "◇"
            case .buddy: return "❀"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selection {
            case .home:   HomeView()
            case .quests: QuestsView()
            case .play:   MinigamesHubView()
            case .money:  MoneyView()
            case .squad:  SquadView()
            case .buddy:  BuddyView()
            }

            TabBar(selection: $selection)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBar: View {
    @Binding var selection: MainTabView.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                let focused = selection == tab
                Button { selection = tab } label: {
                    VStack(spacing: 2) {
                        Text(tab.glyph)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(focused ? Palette.ink : Palette.inkMuted)
                        Text(tab.label)
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(focused ? Palette.ink : Palette.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1))
        )
        .shadow(color: Palette.ink.opacity(0.12), radius: 24, x: 0, y: 12)
    }
}

struct PlaceholderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Spacer().frame(height: Spacing.xxxl)
                Eyebrow(text: "Budget Bloom")
                Text(title).font(Typo.display).foregroundStyle(Palette.ink)
                Text(subtitle).font(Typo.body).foregroundStyle(Palette.inkSoft)
                Spacer()
            }
            .padding(.horizontal, Spacing.xl)
        }
    }
}

#Preview {
    MainTabView().environmentObject(AppState())
}
