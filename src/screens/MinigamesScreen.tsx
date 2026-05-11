import React from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import Svg, { Path, Defs, LinearGradient as SvgLinearGradient, Stop, Circle } from 'react-native-svg';
import { GradientBackground } from '../components/GradientBackground';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';

type Game = {
  id: 'swipe' | 'moves' | 'market';
  tag: string;
  title: string;
  desc: string;
  cta: string;
  ready: boolean;
  gradient: readonly [string, string];
  glyphTint: string;
};

const GAMES: Game[] = [
  {
    id: 'swipe',
    tag: 'Spending reflex',
    title: 'SwipeSmart',
    desc: 'Swipe right to buy, left to skip. Build instinct for needs vs wants.',
    cta: 'Coming soon',
    ready: false,
    gradient: [palette.rose, palette.peach],
    glyphTint: '#B33A6B',
  },
  {
    id: 'moves',
    tag: 'Life decisions',
    title: 'MoneyMoves',
    desc: 'Branching scenarios. Pick your path, watch the future compound.',
    cta: 'Coming soon',
    ready: false,
    gradient: [palette.lavender, palette.lavenderSoft],
    glyphTint: '#6D4FD4',
  },
  {
    id: 'market',
    tag: 'Investing',
    title: 'Market Games',
    desc: 'Rewind real market history. Compress months into seconds. Beat the benchmark.',
    cta: 'Play now  →',
    ready: true,
    gradient: [palette.mint, '#DCF7EB'],
    glyphTint: '#0F8862',
  },
];

export default function MinigamesScreen() {
  const navigation = useNavigation<any>();

  const onPress = (game: Game) => {
    if (game.id === 'market') {
      navigation.navigate('Trade');
    } else {
      Alert.alert(`${game.title} is coming soon`, 'Stay tuned — this one is in the lab.');
    }
  };

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.eyebrow}>money moves</Text>
          <Text style={styles.title}>Minigames.</Text>
          <Text style={styles.sub}>
            Three quick ways to practice your first money moves.
          </Text>
        </Animated.View>

        <View style={{ gap: spacing.md, marginTop: spacing.xl }}>
          {GAMES.map((game, i) => (
            <Animated.View key={game.id} entering={FadeInUp.duration(500).delay(80 + i * 70)}>
              <Pressable
                onPress={() => onPress(game)}
                style={({ pressed }) => [pressed && { transform: [{ scale: 0.985 }] }]}
              >
                <View style={[styles.card, shadows.card]}>
                  <LinearGradient
                    colors={game.gradient}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 1 }}
                    style={styles.glyph}
                  >
                    {game.id === 'swipe' && <SwipeGlyph tint={game.glyphTint} />}
                    {game.id === 'moves' && <MovesGlyph tint={game.glyphTint} />}
                    {game.id === 'market' && <MarketGlyph />}
                  </LinearGradient>

                  <View style={styles.body}>
                    <Text style={styles.tag}>{game.tag}</Text>
                    <Text style={styles.cardTitle}>{game.title}</Text>
                    <Text style={styles.desc} numberOfLines={2}>
                      {game.desc}
                    </Text>
                    <Text style={[styles.cta, game.ready && styles.ctaReady]}>{game.cta}</Text>
                  </View>
                </View>
              </Pressable>
            </Animated.View>
          ))}
        </View>

        <Text style={styles.footer}>FidHacks 2026</Text>
      </ScrollView>
    </GradientBackground>
  );
}

function SwipeGlyph({ tint }: { tint: string }) {
  return (
    <View style={glyphStyles.swipeWrap}>
      <View style={[glyphStyles.swipeCard, glyphStyles.swipeBack]} />
      <View style={[glyphStyles.swipeCard, glyphStyles.swipeMid]} />
      <View style={[glyphStyles.swipeCard, glyphStyles.swipeFront]}>
        <Text style={[glyphStyles.swipeDollar, { color: tint }]}>$</Text>
      </View>
    </View>
  );
}

function MovesGlyph({ tint }: { tint: string }) {
  return (
    <View style={glyphStyles.movesWrap}>
      <Svg viewBox="0 0 80 80" width="100%" height="100%">
        <Path
          d="M10,60 Q25,15 40,45 T70,20"
          stroke={tint}
          strokeWidth={3}
          fill="none"
          strokeLinecap="round"
        />
        <Circle cx={14} cy={58} r={5} fill={tint} />
        <Circle cx={36} cy={42} r={5} fill={tint} />
        <Circle cx={56} cy={32} r={5} fill={tint} />
        <Circle cx={70} cy={20} r={5} fill={tint} />
      </Svg>
    </View>
  );
}

function MarketGlyph() {
  return (
    <View style={glyphStyles.marketWrap}>
      <Svg viewBox="0 0 120 60" width="100%" height="100%">
        <Defs>
          <SvgLinearGradient id="mg-fill" x1="0" y1="0" x2="0" y2="1">
            <Stop offset="0%" stopColor="#6FE3B3" stopOpacity={0.6} />
            <Stop offset="100%" stopColor="#6FE3B3" stopOpacity={0} />
          </SvgLinearGradient>
        </Defs>
        <Path
          d="M0,45 L15,38 L25,42 L40,22 L55,30 L70,14 L90,22 L105,8 L120,12 L120,60 L0,60 Z"
          fill="url(#mg-fill)"
        />
        <Path
          d="M0,45 L15,38 L25,42 L40,22 L55,30 L70,14 L90,22 L105,8 L120,12"
          stroke="#1A9F7A"
          strokeWidth={2.5}
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.xxxl + spacing.md,
    paddingBottom: 140,
  },
  eyebrow: {
    ...typography.label,
    color: palette.lavenderDeep,
    marginBottom: spacing.xs,
  },
  title: {
    ...typography.display,
    color: palette.ink,
    marginBottom: spacing.sm,
  },
  sub: {
    ...typography.body,
    color: palette.inkSoft,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: palette.glass,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    padding: spacing.lg,
    gap: spacing.lg,
  },
  glyph: {
    width: 88,
    height: 88,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  body: { flex: 1, minWidth: 0 },
  tag: {
    ...typography.caption,
    color: palette.inkMuted,
    letterSpacing: 1.2,
    textTransform: 'uppercase',
    fontSize: 10,
    fontWeight: '700',
    marginBottom: spacing.xs,
  },
  cardTitle: {
    ...typography.h2,
    color: palette.ink,
    marginBottom: 2,
  },
  desc: {
    fontSize: 13,
    lineHeight: 18,
    color: palette.inkSoft,
    marginBottom: spacing.sm,
  },
  cta: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.8,
    textTransform: 'uppercase',
    color: palette.inkMuted,
  },
  ctaReady: {
    color: '#0F8862',
  },
  footer: {
    textAlign: 'center',
    marginTop: spacing.xl,
    fontSize: 11,
    letterSpacing: 0.8,
    color: palette.inkMuted,
  },
});

const glyphStyles = StyleSheet.create({
  swipeWrap: {
    width: 70,
    height: 70,
    position: 'relative',
    alignItems: 'center',
    justifyContent: 'center',
  },
  swipeCard: {
    position: 'absolute',
    width: 40,
    height: 54,
    borderRadius: 9,
    backgroundColor: '#fff',
    shadowColor: '#1A1726',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  swipeBack: {
    transform: [{ translateX: -12 }, { translateY: 6 }, { rotate: '-10deg' }],
    backgroundColor: 'rgba(255,255,255,0.6)',
  },
  swipeMid: {
    transform: [{ translateX: 0 }, { translateY: 0 }, { rotate: '0deg' }],
    backgroundColor: 'rgba(255,255,255,0.85)',
  },
  swipeFront: {
    transform: [{ translateX: 12 }, { translateY: -6 }, { rotate: '10deg' }],
  },
  swipeDollar: {
    fontSize: 22,
    fontWeight: '700',
  },
  movesWrap: {
    width: 72,
    height: 72,
  },
  marketWrap: {
    width: 72,
    height: 56,
  },
});
