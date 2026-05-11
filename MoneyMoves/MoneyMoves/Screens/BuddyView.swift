import SwiftUI

struct BuddyView: View {
    @EnvironmentObject var app: AppState
    @State private var happiness: Int = 60
    @State private var toast: String? = nil

    // Interactive layer state
    @State private var foods: [FoodDrop] = []
    @State private var hearts: [HeartPop] = []
    @State private var buddyBob: Bool = false
    @State private var buddyScale: CGFloat = 1
    @State private var buddyRotation: Double = 0
    @State private var mouthOpen: Bool = false

    private var buddyEmoji: String {
        switch app.user.buddyId {
        case "fox":   return "🦊"
        case "otter": return "🦦"
        case "cat":   return "🐱"
        default:      return "✨"
        }
    }

    private var foodPool: [String] {
        switch app.user.buddyId {
        case "fox":   return ["🍇", "🍓", "🐭"]
        case "otter": return ["🐟", "🦀", "🦞", "🐚"]
        case "cat":   return ["🐟", "🐭", "🥛", "🍣"]
        default:      return ["🍪", "🍇", "🍓"]
        }
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Your buddy")
                    Text("Buddy.").font(Typo.display).foregroundStyle(Palette.ink)
                    Text("Tap to pet. Feed for treats. Keep them happy.")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)

                    buddyPlayArea

                    actionRow

                    HStack {
                        Text("Coins").font(Typo.h3).foregroundStyle(Palette.ink)
                        Spacer()
                        HStack(spacing: 4) {
                            Circle().fill(Palette.peachDeep).frame(width: 14, height: 14)
                            Text("\(app.user.coins)")
                                .font(Typo.h3).foregroundStyle(Palette.ink)
                        }
                    }.padding(.top, Spacing.md)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 2),
                              spacing: Spacing.md) {
                        ForEach(ACCESSORIES) { acc in
                            AccessoryTile(
                                accessory: acc,
                                owned: app.user.ownedAccessories.contains(acc.id),
                                equipped: app.user.equippedAccessory == acc.id,
                                canAfford: app.user.coins >= acc.cost
                            ) {
                                tapAccessory(acc)
                            }
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
        .overlay(alignment: .top) {
            if let msg = toast {
                Text(msg)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(Palette.ink))
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            buddyBob = true
            // Happiness drifts down slowly to nudge interaction (purely visual)
            startHappinessDecay()
        }
    }

    // MARK: - Play area (buddy + food layer + hearts)

    private var buddyPlayArea: some View {
        ZStack {
            // Hero gradient background
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(Gradients.hero)
                .frame(height: 320)
                .shadow(color: Palette.lavenderDeep.opacity(0.35), radius: 36, x: 0, y: 16)

            // Falling foods layer
            ForEach(foods) { food in
                FallingFood(emoji: food.emoji,
                            xOffset: food.xOffset) {
                    // food reached the buddy — catch!
                    foods.removeAll { $0.id == food.id }
                    catchFood()
                }
            }

            // Hearts layer
            ForEach(hearts) { h in
                RisingHeart(xOffset: h.xOffset) {
                    hearts.removeAll { $0.id == h.id }
                }
            }

            // Buddy
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 140, height: 140)
                Text(buddyEmoji)
                    .font(.system(size: mouthOpen ? 94 : 84))
                    .rotationEffect(.degrees(buddyBob ? 4 : -4))
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: buddyBob)
                    .rotationEffect(.degrees(buddyRotation))
                    .scaleEffect(buddyScale)

                // Equipped accessory floats above
                if let eq = app.user.equippedAccessory,
                   let acc = ACCESSORIES.first(where: { $0.id == eq }) {
                    Text(acc.emoji)
                        .font(.system(size: 34))
                        .offset(y: -54)
                        .scaleEffect(buddyScale)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { petBuddy() }
            .offset(y: -10)

            // Level / XP / streak — pinned to the bottom of the stage with its own padding
            VStack(spacing: 2) {
                Spacer()
                Text("Level \(app.user.level)")
                    .font(Typo.bodyBold).foregroundStyle(.white)
                Text("\(app.user.xp) XP · \(app.user.streak)🔥 streak")
                    .font(Typo.caption).foregroundStyle(.white.opacity(0.85))
            }
            .padding(.bottom, Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            // Happiness meter (top of card)
            VStack {
                happinessBar
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                Spacer()
            }
        }
        .frame(height: 320)
    }

    private var happinessBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("HAPPINESS")
                    .font(.system(size: 10, weight: .bold)).tracking(1.2)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Text("\(happiness)/100")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .contentTransition(.numericText())
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.25))
                    Capsule()
                        .fill(happiness > 30 ? Color.white : Palette.peachDeep)
                        .frame(width: geo.size.width * CGFloat(happiness) / 100)
                        .animation(.easeOut(duration: 0.4), value: happiness)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Action row (feed + pet)

    private var actionRow: some View {
        HStack(spacing: Spacing.md) {
            Button(action: feedBuddy) {
                actionTile(emoji: foodPool.first ?? "🍪",
                           label: "Feed",
                           hint: "Tap to drop a treat")
            }.buttonStyle(.plain)

            Button(action: petBuddy) {
                actionTile(emoji: "✋",
                           label: "Pet",
                           hint: "Tap the buddy too")
            }.buttonStyle(.plain)
        }
    }

    private func actionTile(emoji: String, label: String, hint: String) -> some View {
        HStack(spacing: Spacing.md) {
            Text(emoji).font(.system(size: 32))
            VStack(alignment: .leading, spacing: 0) {
                Text(label).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                Text(hint).font(Typo.caption).foregroundStyle(Palette.inkMuted)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(Palette.glassBorder, lineWidth: 1))
        )
    }

    // MARK: - Interactions

    private func feedBuddy() {
        let emoji = foodPool.randomElement() ?? "🍪"
        let drop = FoodDrop(emoji: emoji, xOffset: CGFloat.random(in: -30...30))
        foods.append(drop)
    }

    private func catchFood() {
        // mouth open + bounce
        withAnimation(.easeOut(duration: 0.15)) { mouthOpen = true }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { buddyScale = 1.18 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                buddyScale = 1
                mouthOpen = false
            }
        }
        // heart pop
        spawnHeart()
        // happiness up
        withAnimation { happiness = min(100, happiness + 8) }
    }

    private func petBuddy() {
        // Quick tilt + heart
        withAnimation(.easeOut(duration: 0.15)) { buddyRotation = -10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { buddyRotation = 0 }
        }
        spawnHeart()
        withAnimation { happiness = min(100, happiness + 3) }
    }

    private func spawnHeart() {
        let h = HeartPop(xOffset: CGFloat.random(in: -40...40))
        hearts.append(h)
    }

    private func startHappinessDecay() {
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if happiness > 0 {
                    withAnimation { happiness -= 1 }
                }
            }
        }
    }

    // MARK: - Accessories (unchanged)

    private func tapAccessory(_ acc: Accessory) {
        if app.user.ownedAccessories.contains(acc.id) {
            if app.user.equippedAccessory == acc.id {
                app.user.equippedAccessory = nil
                showToast("\(acc.emoji) removed")
            } else {
                app.user.equippedAccessory = acc.id
                showToast("\(acc.emoji) equipped")
            }
        } else if app.user.coins >= acc.cost {
            app.user.coins -= acc.cost
            app.user.ownedAccessories.insert(acc.id)
            app.user.equippedAccessory = acc.id
            showToast("\(acc.emoji) unlocked + equipped")
        } else {
            showToast("Not enough coins — earn \(acc.cost - app.user.coins) more.")
        }
    }

    private func showToast(_ s: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toast = s }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.25)) { toast = nil }
        }
    }
}

// MARK: - Food drop particle

struct FoodDrop: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let xOffset: CGFloat
}

struct FallingFood: View {
    let emoji: String
    let xOffset: CGFloat
    let onLand: () -> Void
    @State private var y: CGFloat = -180
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Text(emoji)
            .font(.system(size: 36))
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: y)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.95)) {
                    y = 38   // lands at buddy's mouth area
                    rotation = Double.random(in: -180...180)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                    withAnimation(.easeOut(duration: 0.15)) { opacity = 0 }
                    onLand()
                }
            }
    }
}

// MARK: - Heart particle

struct HeartPop: Identifiable, Equatable {
    let id = UUID()
    let xOffset: CGFloat
}

struct RisingHeart: View {
    let xOffset: CGFloat
    let onDone: () -> Void
    @State private var y: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.6

    var body: some View {
        Text("❤️")
            .font(.system(size: 26))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: xOffset, y: y)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1
                }
                withAnimation(.easeOut(duration: 1.1)) {
                    y = -120
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    onDone()
                }
            }
    }
}

// MARK: - Accessory tile (unchanged)

struct AccessoryTile: View {
    let accessory: Accessory
    let owned: Bool
    let equipped: Bool
    let canAfford: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(equipped ? Palette.lavenderSoft : Color.white.opacity(0.6))
                        .frame(height: 96)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(equipped ? Palette.lavenderDeep : Palette.glassBorder,
                                        lineWidth: equipped ? 2 : 1)
                        )
                    Text(accessory.emoji)
                        .font(.system(size: 50))
                        .opacity(owned ? 1 : 0.45)
                }

                Text(accessory.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)

                if owned {
                    Text(equipped ? "Equipped ✓" : "Tap to equip")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Palette.lavenderDeep)
                } else {
                    HStack(spacing: 3) {
                        Circle().fill(canAfford ? Palette.peachDeep : Palette.inkMuted)
                            .frame(width: 8, height: 8)
                        Text("\(accessory.cost)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(canAfford ? Palette.ink : Palette.inkMuted)
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BuddyView().environmentObject(AppState())
}
