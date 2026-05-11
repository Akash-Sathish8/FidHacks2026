import SwiftUI

struct SquadView: View {
    @EnvironmentObject var app: AppState

    private var board: [LeaderboardEntry] {
        var entries: [LeaderboardEntry] = SQUAD.map {
            LeaderboardEntry(id: $0.id, name: $0.name, emoji: $0.emoji,
                             ret: $0.bestReturn, isMe: false)
        }
        let myBest = app.tradeBests.values.map { $0.finalReturn }.max() ?? 0
        entries.append(LeaderboardEntry(id: "me", name: app.user.name.isEmpty ? "You" : app.user.name,
                                        emoji: "✨", ret: myBest, isMe: true))
        return entries.sorted { $0.ret > $1.ret }
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Your crew")
                    Text("Squad.").font(Typo.display).foregroundStyle(Palette.ink)
                    Text("Practice together. Compare best paper trading runs.")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.md)

                    GlassCard {
                        VStack(spacing: 4) {
                            ForEach(Array(board.enumerated()), id: \.element.id) { idx, entry in
                                LeaderboardRow(rank: idx + 1, entry: entry)
                                if idx < board.count - 1 {
                                    Divider().background(Palette.glassBorder).padding(.vertical, 2)
                                }
                            }
                        }
                    }

                    Text("Badges").font(Typo.h3).foregroundStyle(Palette.ink)
                        .padding(.top, Spacing.md)

                    VStack(spacing: Spacing.sm) {
                        ForEach(SQUAD) { m in
                            badgeRow(member: m)
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
    }

    private func badgeRow(member: SquadMember) -> some View {
        HStack(spacing: Spacing.md) {
            Text(member.emoji).font(.system(size: 22))
            Text(member.name).font(Typo.bodyBold).foregroundStyle(Palette.ink)
            Spacer()
            HStack(spacing: 6) {
                ForEach(member.badges, id: \.self) { b in
                    Text(badgeLabel(b))
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Capsule().fill(Palette.lavenderSoft))
                        .foregroundStyle(Palette.lavenderDeep)
                }
                if member.badges.isEmpty {
                    Text("none yet").font(Typo.caption).foregroundStyle(Palette.inkMuted)
                }
            }
        }
        .padding(.horizontal, Spacing.md).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Palette.glassBorder, lineWidth: 1))
        )
    }

    private func badgeLabel(_ id: String) -> String {
        switch id {
        case "diversifier": return "Diversifier"
        case "streak-7":    return "7-day streak"
        case "streak-30":   return "30-day streak"
        default:            return id
        }
    }
}

struct LeaderboardEntry: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let ret: Double
    let isMe: Bool
}

struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text("\(rank)")
                .font(.system(size: 16, weight: .bold))
                .frame(width: 24, alignment: .leading)
                .foregroundStyle(Palette.inkMuted)
            Text(entry.emoji).font(.system(size: 24))
            Text(entry.name)
                .font(Typo.bodyBold)
                .foregroundStyle(entry.isMe ? Palette.lavenderDeep : Palette.ink)
            Spacer()
            Text(entry.ret.percent)
                .font(Typo.bodyBold)
                .foregroundStyle(entry.ret >= 0 ? Palette.success : Palette.roseDeep)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SquadView().environmentObject(AppState())
}
