import SwiftUI

struct Buddy: Identifiable {
    let id: String
    let name: String
    let emoji: String       // emoji fallback
    let imageName: String?  // nil → render emoji; non-nil → render asset image
    let tagline: String
    let gradient: LinearGradient
}

let BUDDIES: [Buddy] = [
    Buddy(id: "fox",   name: "Fox",   emoji: "🦊", imageName: "Fox_Plain",   tagline: "Sharp + scrappy",  gradient: Gradients.peachCard),
    Buddy(id: "bunny", name: "Bunny", emoji: "🐰", imageName: "Bunny_Plain", tagline: "Playful + steady", gradient: Gradients.mintCard),
    Buddy(id: "cat",   name: "Cat",   emoji: "🐱", imageName: "Cat_Plain",   tagline: "Curious + calm",   gradient: Gradients.lavenderCard),
]

struct BuddyPickerView: View {
    @EnvironmentObject var app: AppState
    @State private var selectedId: String? = nil

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Spacer().frame(height: Spacing.xxxl)

                Eyebrow(text: "Pick your buddy")
                Text("Who's coming\nwith you?")
                    .font(Typo.display)
                    .foregroundStyle(Palette.ink)
                Text("They'll celebrate every win and coach every move.")
                    .font(Typo.body)
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.bottom, Spacing.md)

                VStack(spacing: Spacing.md) {
                    ForEach(BUDDIES) { buddy in
                        BuddyCard(buddy: buddy, selected: selectedId == buddy.id) {
                            selectedId = buddy.id
                        }
                    }
                }

                Spacer()

                GradientButton(title: selectedId == nil ? "Pick a buddy" : "Let's go") {
                    guard let id = selectedId else { return }
                    app.setBuddyId(id)
                    app.route = .goalSetup
                }
                .opacity(selectedId == nil ? 0.5 : 1)
                .disabled(selectedId == nil)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
    }
}

struct BuddyCard: View {
    let buddy: Buddy
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(buddy.gradient)
                        .frame(width: 88, height: 88)
                    if let img = buddy.imageName {
                        // Image larger than the tile so the character pops past
                        // the frame — keeps the original button size intact.
                        Image(img).resizable().scaledToFit()
                            .frame(width: 130, height: 130)
                    } else {
                        Text(buddy.emoji).font(.system(size: 44))
                    }
                }
                .frame(width: 88, height: 88)
                VStack(alignment: .leading, spacing: 4) {
                    Text(buddy.name).font(Typo.h2).foregroundStyle(Palette.ink)
                    Text(buddy.tagline).font(Typo.body).foregroundStyle(Palette.inkSoft)
                }
                Spacer()
                if selected {
                    ZStack {
                        Circle().fill(Palette.lavenderDeep).frame(width: 28, height: 28)
                        Text("✓").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                            .stroke(selected ? Palette.lavenderDeep : Palette.glassBorder,
                                    lineWidth: selected ? 2 : 1)
                    )
            )
            .shadow(color: Palette.ink.opacity(selected ? 0.12 : 0.08),
                    radius: selected ? 36 : 24, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BuddyPickerView().environmentObject(AppState())
}
