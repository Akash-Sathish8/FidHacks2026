import React, { useEffect } from 'react';
import { Dimensions, ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { GradientButton } from '../components/GradientButton';
import { PortfolioChart } from '../components/PortfolioChart';
import { Buddy } from '../components/Buddy';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { useApp } from '../state/AppState';
import { RunSummary, useTrade } from '../state/TradeState';
import { RootStackParamList } from '../navigation';

type Route = RouteProp<RootStackParamList, 'TradeResult'>;
const { width: SCREEN_W } = Dimensions.get('window');

function pickReaction(s: RunSummary): string {
  const overVTI = s.finalReturn - s.vtiReturn;
  if (s.maxConcentration > 0.7) {
    return `You ${overVTI >= 0 ? 'beat' : 'lost to'} VTI by ${Math.abs(overVTI * 100).toFixed(1)}% — but ${(s.maxConcentration * 100).toFixed(0)}% of your portfolio was in a single asset. That's a coin flip, not a strategy. Try spreading across ≥4 assets next round.`;
  }
  if (s.diversifierBadge && overVTI >= 0) {
    return `Real move. You held ${s.assetsTouched.length} assets, beat the diversified baseline by ${(overVTI * 100).toFixed(1)}%, and kept drawdown manageable. This is what risk-adjusted return looks like.`;
  }
  if (s.diversifierBadge && overVTI < 0) {
    return `You diversified well (${s.assetsTouched.length} assets), but came in ${Math.abs(overVTI * 100).toFixed(1)}% under VTI. Honestly? Most active traders lose to the index over time. Diversifying and matching the market is the long game.`;
  }
  if (s.assetsTouched.length <= 1) {
    return `You held ${s.assetsTouched.length === 0 ? 'no positions' : 'one asset'}. The market doesn't reward sitting out or going all-in on a single bet. Spread it across 4+ next time.`;
  }
  return `Solid run. You held ${s.assetsTouched.length} assets. Diversification is a free lunch — it cuts risk without cutting returns. Keep it up.`;
}

export default function TradeResultScreen() {
  const route = useRoute<Route>();
  const navigation = useNavigation<any>();
  const { user, setUser, addCoins, addXP } = useApp();
  const { startRun } = useTrade();
  const summary = route.params.summary;

  // Persist best + grant rewards once
  useEffect(() => {
    const existing = user.tradeBests?.[summary.mode];
    const isBest = !existing || summary.finalReturn > existing.finalReturn;
    setUser((u) => ({
      ...u,
      tradeBests: {
        ...(u.tradeBests ?? {}),
        ...(isBest
          ? { [summary.mode]: { finalReturn: summary.finalReturn, date: summary.startDate, diversifierBadge: summary.diversifierBadge } }
          : {}),
      },
    }));
    addXP(summary.beatBenchmark ? 200 : 50);
    addCoins(summary.beatBenchmark ? 100 : 0);
    if (summary.diversifierBadge) addCoins(50);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const reaction = pickReaction(summary);

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Pressable onPress={() => navigation.popToTop()} style={styles.close}>
          <Text style={styles.closeText}>×</Text>
        </Pressable>

        <Animated.View entering={FadeInUp.duration(500)} style={{ alignItems: 'center', marginTop: spacing.xxl }}>
          <Buddy kind={user.buddyKind} size={120} accessory={summary.beatBenchmark ? '✨' : undefined} />
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(80)}>
          <Text style={styles.eyebrow}>your run</Text>
          <Text style={styles.title}>
            {summary.beatBenchmark ? 'You beat VTI.' : "You didn't beat VTI."}
          </Text>
          <Text style={styles.sub}>{summary.startDate} → {summary.endDate}</Text>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(140)}>
          <GlassCard>
            <Text style={styles.label}>portfolio path</Text>
            <View style={{ alignItems: 'center', marginTop: spacing.md }}>
              <PortfolioChart
                series={summary.portfolioSeries}
                benchmarkSeries={summary.vtiSeries}
                width={SCREEN_W - spacing.xl * 2 - spacing.xl * 2}
                height={140}
              />
            </View>
            <View style={styles.legendRow}>
              <View style={styles.legendItem}>
                <View style={[styles.dot, { backgroundColor: summary.finalReturn >= 0 ? palette.mintDeep : palette.peachDeep }]} />
                <Text style={styles.legendText}>you</Text>
              </View>
              <View style={styles.legendItem}>
                <View style={[styles.dot, { backgroundColor: palette.inkMuted }]} />
                <Text style={styles.legendText}>VTI buy & hold</Text>
              </View>
            </View>
          </GlassCard>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(200)}>
          <View style={styles.threeRow}>
            <View style={[styles.stat, { backgroundColor: summary.beatBenchmark ? palette.ink : palette.glass, borderColor: summary.beatBenchmark ? palette.ink : palette.glassBorder }]}>
              <Text style={[styles.statLabel, summary.beatBenchmark && { color: palette.creamDeep }]}>YOU</Text>
              <Text style={[styles.statValue, summary.beatBenchmark && { color: palette.cream }]}>
                {summary.finalReturn >= 0 ? '+' : ''}
                {(summary.finalReturn * 100).toFixed(1)}%
              </Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statLabel}>VTI</Text>
              <Text style={styles.statValue}>
                {summary.vtiReturn >= 0 ? '+' : ''}
                {(summary.vtiReturn * 100).toFixed(1)}%
              </Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statLabel}>BEST {summary.bestSingleSymbol}</Text>
              <Text style={styles.statValue}>
                {summary.bestSingleReturn >= 0 ? '+' : ''}
                {(summary.bestSingleReturn * 100).toFixed(1)}%
              </Text>
            </View>
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(260)}>
          <GlassCard>
            <Text style={styles.label}>diversification scorecard</Text>
            <View style={styles.scoreRow}>
              <Text style={styles.scoreKey}>assets touched</Text>
              <Text style={styles.scoreVal}>{summary.assetsTouched.length} / 8</Text>
            </View>
            <View style={styles.scoreRow}>
              <Text style={styles.scoreKey}>max concentration</Text>
              <Text style={styles.scoreVal}>{(summary.maxConcentration * 100).toFixed(0)}%</Text>
            </View>
            <View style={styles.scoreRow}>
              <Text style={styles.scoreKey}>max drawdown</Text>
              <Text style={styles.scoreVal}>−{(summary.maxDrawdown * 100).toFixed(1)}%</Text>
            </View>
            <View style={styles.scoreRow}>
              <Text style={styles.scoreKey}>final value</Text>
              <Text style={styles.scoreVal}>${summary.finalValue.toFixed(0)}</Text>
            </View>
            {summary.diversifierBadge && (
              <View style={styles.badge}>
                <Text style={styles.badgeText}>🛡 Diversifier — +50 ◐ bonus</Text>
              </View>
            )}
          </GlassCard>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(320)}>
          <GlassCard>
            <Text style={styles.label}>coach note</Text>
            <Text style={styles.reaction}>{reaction}</Text>
          </GlassCard>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(380)} style={{ alignItems: 'center', gap: spacing.md, marginTop: spacing.lg }}>
          <GradientButton
            label="Play again"
            onPress={() => {
              startRun(summary.mode);
              navigation.replace('TradeGame');
            }}
          />
          <Pressable onPress={() => navigation.popToTop()}>
            <Text style={styles.smallCta}>back to Trade</Text>
          </Pressable>
        </Animated.View>

        <View style={{ height: 80 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 90, gap: spacing.xl },
  close: { position: 'absolute', top: 60, right: spacing.xl, width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, zIndex: 10 },
  closeText: { fontSize: 24, color: palette.ink, lineHeight: 26 },
  eyebrow: { ...typography.label, color: palette.lavenderDeep, marginTop: spacing.lg },
  title: { ...typography.display, color: palette.ink, marginTop: 4 },
  sub: { ...typography.caption, color: palette.inkMuted, marginTop: 4 },
  label: { ...typography.label, color: palette.inkMuted },
  legendRow: { flexDirection: 'row', justifyContent: 'center', gap: spacing.xl, marginTop: spacing.md },
  legendItem: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  dot: { width: 10, height: 10, borderRadius: 5 },
  legendText: { ...typography.caption, color: palette.inkSoft },
  threeRow: { flexDirection: 'row', gap: spacing.sm },
  stat: { flex: 1, padding: spacing.md, borderRadius: radius.lg, backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, alignItems: 'center', gap: 4, ...shadows.soft },
  statLabel: { ...typography.label, color: palette.inkMuted, letterSpacing: 0.8 },
  statValue: { ...typography.h2, color: palette.ink },
  scoreRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: spacing.md },
  scoreKey: { ...typography.body, color: palette.inkSoft },
  scoreVal: { ...typography.bodyBold, color: palette.ink },
  badge: { marginTop: spacing.lg, padding: spacing.md, borderRadius: radius.md, backgroundColor: palette.mintSoft, alignItems: 'center' },
  badgeText: { ...typography.bodyBold, color: palette.mintDeep },
  reaction: { ...typography.body, color: palette.ink, marginTop: spacing.sm },
  smallCta: { ...typography.body, color: palette.inkSoft, fontWeight: '600' },
});
