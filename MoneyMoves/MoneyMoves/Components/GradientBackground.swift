import SwiftUI

struct GradientBackground<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        ZStack {
            Gradients.app.ignoresSafeArea()

            // Soft decorative blobs
            Circle()
                .fill(Palette.lavender.opacity(0.4))
                .frame(width: 380, height: 380)
                .blur(radius: 8)
                .offset(x: 140, y: -200)
            Circle()
                .fill(Palette.peach.opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 8)
                .offset(x: -120, y: 340)
            Circle()
                .fill(Palette.mint.opacity(0.3))
                .frame(width: 240, height: 240)
                .blur(radius: 8)
                .offset(x: -150, y: 60)

            content()
        }
    }
}

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Radius.xl
    var padding: CGFloat = Spacing.lg
    let content: () -> Content
    init(cornerRadius: CGFloat = Radius.xl, padding: CGFloat = Spacing.lg,
         @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Palette.glassBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Palette.ink.opacity(0.08), radius: 32, x: 0, y: 12)
    }
}

struct GradientButton: View {
    let title: String
    var gradient: LinearGradient = Gradients.hero
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typo.bodyBold)
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                        .fill(gradient)
                )
                .shadow(color: Palette.lavenderDeep.opacity(0.25), radius: 36, x: 0, y: 16)
        }
        .buttonStyle(.plain)
    }
}

struct Eyebrow: View {
    let text: String
    var color: Color = Palette.lavenderDeep
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .tracking(1.4)
            .foregroundStyle(color)
    }
}
