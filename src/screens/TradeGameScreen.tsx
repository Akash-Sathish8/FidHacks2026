import React, { useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable, Dimensions } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeIn } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { PortfolioChart } from '../components/PortfolioChart';
import { AssetCard } from '../components/AssetCard';
import { TradeModal } from '../components/TradeModal';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { useTrade, MODE_META, STARTING_CASH, currentValue } from '../state/TradeState';

const { width: SCREEN_W } = Dimensions.get('window');

export default function TradeGameScreen() {
  const navigation = useNavigation<any>();
  const { game, pauseRun, resumeRun, abandon, finalizeRun, buy, sell, universe } = useTrade();
  const [selected, setSelected] = useState<string | null>(null);

  if (!game) {
    return (
      <GradientBackground>
        <View style={[styles.root, { justifyContent: 'center', alignItems: 'center' }]}>
          <Text style={styles.eyebrow}>no active run</Text>
          <Pressable onPress={() => navigation.goBack()}>
            <Text style={styles.cta}>← back</Text>
          </Pressable>
        </View>
      </GradientBackground>
    );
  }

  const meta = MODE_META[game.mode];
  const ticksLeft = game.ticks.length - 1 - game.currentTick;
  const pctLeft = ticksLeft / (game.ticks.length - 1);
  const value = currentValue(game);
  const change = (value - STARTING_CASH) / STARTING_CASH;
  const tick = game.ticks[game.currentTick];
  const date = tick.date;

  function handleEnd() {
    const summary = finalizeRun();
    if (summary) navigation.replace('TradeResult', { summary });
    else navigation.goBack();
  }

  // Auto-finalize when ticks complete
  React.useEffect(() => {
    if (game.currentTick >= game.ticks.length - 1) {
      const t = setTimeout(handleEnd, 600);
      return () => clearTimeout(t);
    }
  }, [game.currentTick, game.ticks.length]);

  const selectedSeries = useMemo(() => {
    return universe.find((u) => u.symbol === selected);
  }, [selected]);

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <View style={styles.topRow}>
          <Pressable
            onPress={() => {
              pauseRun();
              navigation.goBack();
              setTimeout(() => abandon(), 50);
            }}
            style={styles.closeBtn}
          >
            <Text style={styles.closeText}>×</Text>
          </Pressable>
          <View style={{ alignItems: 'center' }}>
            <Text style={styles.eyebrow}>{meta.label} • {date}</Text>
            <Text style={styles.timeLeft}>tick {game.currentTick + 1} / {game.ticks.length}</Text>
          </View>
          <Pressable
            onPress={() => (game.isPaused ? resumeRun() : pauseRun())}
            style={styles.pauseBtn}
          >
            <Text style={styles.pauseIcon}>{game.isPaused ? '▶' : '❚❚'}</Text>
          </Pressable>
        </View>

        <View style={styles.progressBar}>
          <View style={[styles.progressFill, { width: `${(1 - pctLeft) * 100}%` }]} />
        </View>

        <Animated.View entering={FadeIn.duration(300)} style={styles.heroCard}>
          <Text style={styles.label}>portfolio value</Text>
          <Text style={styles.bigValue}>${value.toFixed(2)}</Text>
          <Text style={[styles.bigDelta, { color: change >= 0 ? palette.mintDeep : palette.peachDeep }]}>
            {change >= 0 ? '+' : ''}
            {(change * 100).toFixed(2)}%
          </Text>
          <View style={styles.chartWrap}>
            <PortfolioChart series={game.portfolioHistory} width={SCREEN_W - spacing.xl * 2 - spacing.lg * 2} height={120} />
          </View>
          <View style={styles.miniRow}>
            <View style={styles.miniStat}>
              <Text style={styles.miniLabel}>cash</Text>
              <Text style={styles.miniValue}>${game.cash.toFixed(0)}</Text>
            </View>
            <View style={styles.miniStat}>
              <Text style={styles.miniLabel}>positions</Text>
              <Text style={styles.miniValue}>{Object.keys(game.holdings).length}</Text>
            </View>
            <View style={styles.miniStat}>
              <Text style={styles.miniLabel}>touched</Text>
              <Text style={styles.miniValue}>{game.assetsTouched.size}</Text>
            </View>
          </View>
        </Animated.View>

        <Text style={styles.sectionLabel}>tap to trade</Text>
        <View style={{ gap: spacing.md }}>
          {universe.map((u) => {
            const seriesLen = Math.min(6, game.currentTick + 1);
            const series: number[] = [];
            for (let i = Math.max(0, game.currentTick - seriesLen + 1); i <= game.currentTick; i++) {
              series.push(game.ticks[i].prices[u.symbol]);
            }
            return (
              <AssetCard
                key={u.symbol}
                symbol={u.symbol}
                name={u.name}
                flavor={u.flavor}
                price={tick.prices[u.symbol]}
                series={series}
                holding={game.holdings[u.symbol]}
                onPress={() => setSelected(u.symbol)}
              />
            );
          })}
        </View>

        <View style={{ height: 60 }} />

        <View style={{ alignItems: 'center' }}>
          <Pressable onPress={handleEnd} style={styles.endBtn}>
            <Text style={styles.endText}>end run early</Text>
          </Pressable>
        </View>

        <View style={{ height: 60 }} />
      </ScrollView>

      <TradeModal
        visible={!!selected}
        symbol={selected ?? ''}
        name={selectedSeries?.name ?? ''}
        price={selected ? tick.prices[selected] : 0}
        cash={game.cash}
        holding={selected ? game.holdings[selected] : undefined}
        onClose={() => setSelected(null)}
        onBuy={(dollars) => selected && buy(selected, dollars)}
        onSell={(shares) => selected && sell(selected, shares)}
      />

      {game.isPaused && (
        <View style={styles.pauseOverlay}>
          <Text style={styles.pauseTitle}>paused</Text>
          <Text style={styles.pauseSub}>tap ▶ to resume</Text>
        </View>
      )}
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 70, gap: spacing.lg },
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  closeBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, alignItems: 'center', justifyContent: 'center' },
  closeText: { fontSize: 24, color: palette.ink, lineHeight: 26 },
  pauseBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: palette.ink, alignItems: 'center', justifyContent: 'center' },
  pauseIcon: { color: palette.cream, fontSize: 14, fontWeight: '700' },
  eyebrow: { ...typography.label, color: palette.lavenderDeep },
  timeLeft: { ...typography.caption, color: palette.inkMuted, marginTop: 2 },
  progressBar: { height: 4, borderRadius: 2, backgroundColor: palette.creamDeep, overflow: 'hidden' },
  progressFill: { height: 4, backgroundColor: palette.lavenderDeep },
  heroCard: { padding: spacing.xl, borderRadius: radius.xl, backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, ...shadows.glow },
  label: { ...typography.label, color: palette.inkMuted },
  bigValue: { ...typography.display, color: palette.ink, marginTop: 4 },
  bigDelta: { ...typography.h3, marginTop: 2 },
  chartWrap: { marginTop: spacing.md, alignItems: 'center' },
  miniRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: spacing.lg },
  miniStat: { alignItems: 'center', flex: 1 },
  miniLabel: { ...typography.caption, color: palette.inkMuted },
  miniValue: { ...typography.h3, color: palette.ink, marginTop: 2 },
  sectionLabel: { ...typography.label, color: palette.inkMuted, marginLeft: 4 },
  endBtn: { paddingHorizontal: spacing.xl, paddingVertical: spacing.md, borderRadius: radius.pill, backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder },
  endText: { ...typography.caption, color: palette.inkSoft, fontWeight: '700' },
  cta: { ...typography.body, color: palette.lavenderDeep, marginTop: spacing.lg },
  pauseOverlay: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(253,251,247,0.92)', alignItems: 'center', justifyContent: 'center' },
  pauseTitle: { ...typography.display, color: palette.ink },
  pauseSub: { ...typography.body, color: palette.inkMuted, marginTop: spacing.md },
});
