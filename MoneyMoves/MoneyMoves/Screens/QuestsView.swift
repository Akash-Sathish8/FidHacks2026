import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var app: AppState
    @State private var selectedQuest: Quest? = nil

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Daily lessons")
                    Text("Quests.").font(Typo.display).foregroundStyle(Palette.ink)
                    Text("Bite-sized lessons. Earn coins. Build the habit.")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.md)

                    VStack(spacing: Spacing.md) {
                        ForEach(QUESTS) { quest in
                            QuestCard(quest: quest,
                                      completed: app.user.completedQuests.contains(quest.id)) {
                                selectedQuest = quest
                            }
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
        .sheet(item: $selectedQuest) { q in
            QuestDetailView(quest: q) { selectedQuest = nil }
        }
    }
}

struct QuestCard: View {
    let quest: Quest
    let completed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.lavenderSoft, Palette.lavender.opacity(0.5)],
                                              startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                    Text(quest.category.emoji).font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(quest.title).font(Typo.h3).foregroundStyle(Palette.ink)
                    Text(quest.blurb).font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    HStack(spacing: 8) {
                        Label("\(quest.xp) XP", systemImage: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Palette.lavenderDeep)
                        Label("\(quest.coins) coins", systemImage: "circle.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Palette.peachDeep)
                    }.padding(.top, 2)
                }
                Spacer()

                if completed {
                    ZStack {
                        Circle().fill(Palette.success).frame(width: 28, height: 28)
                        Text("✓").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                    }
                } else {
                    Text("→").font(.system(size: 22, weight: .bold)).foregroundStyle(Palette.inkMuted)
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1))
            )
            .shadow(color: Palette.ink.opacity(0.08), radius: 24, x: 0, y: 12)
            .opacity(completed ? 0.7 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct QuestDetailView: View {
    let quest: Quest
    let onClose: () -> Void
    @EnvironmentObject var app: AppState
    @State private var step: Int = 0

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        Button("Close", action: onClose).foregroundStyle(Palette.lavenderDeep)
                        Spacer()
                        Text("\(step + 1) / \(quest.lesson.count)")
                            .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    }

                    Text(quest.category.emoji).font(.system(size: 56))
                    Eyebrow(text: quest.category.rawValue.uppercased())
                    Text(quest.title)
                        .font(Typo.h1).foregroundStyle(Palette.ink)
                        .padding(.bottom, Spacing.sm)

                    GlassCard {
                        Text(quest.lesson[step])
                            .font(Typo.body).foregroundStyle(Palette.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: 120, alignment: .topLeading)
                    }

                    Spacer().frame(height: Spacing.lg)

                    if step < quest.lesson.count - 1 {
                        GradientButton(title: "Next") {
                            withAnimation { step += 1 }
                        }
                    } else {
                        GradientButton(title: app.user.completedQuests.contains(quest.id)
                                        ? "Already completed — close"
                                        : "Complete +\(quest.xp) XP  +\(quest.coins) coins") {
                            if !app.user.completedQuests.contains(quest.id) {
                                app.completeQuest(quest.id)
                                app.addXP(quest.xp)
                                app.addCoins(quest.coins)
                            }
                            onClose()
                        }
                    }

                    if step > 0 {
                        Button("Back") { withAnimation { step -= 1 } }
                            .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
            }
        }
    }
}

#Preview {
    QuestsView().environmentObject(AppState())
}
