import React from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { Mode, MODE_META, useTrade } from '../state/TradeState';
import { useApp } from '../state/AppState';
import { squadMembers } from '../data/seed';

const MODE_COLORS: Record<Mode, readonly [string, string]> = {
  sprint: ['#FFE5D4', '#FF9E7D'],
  standard: ['#E0D4FF', '#A78BFA'],
  epic: ['#D4F0E5', '#6FE3B3'],
};

export default function TradeScreen() {
  const navigation = useNavigation<any>();
  const { startRun } = useTrade();
  const { user } = useApp();

  const bests = user.tradeBests;

  // Mock leaderboard returns per squad member
  const mockBoard = [
    { name: 'Maya', emoji: '🌸', ret: 0.42 },
    { name: 'You', emoji: '✨', ret: bests?.standard?.finalReturn ?? 0 },
    { name: 'Priya', emoji: '🌿', ret: 0.31 },
    { name: 'Zoe', emoji: '🌊', ret: 0.14 },
    { name: 'Lena', emoji: '🍯', ret: -0.05 },
  ].sort((a, b) => b.ret - a.ret);

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.eyebrow}>paper trading</Text>
          <Text style={styles.title}>Time Travel{'\n'}Trader.</Text>
          <Text style={styles.sub}>
            Rewind real market history. Compress months into minutes. Try to beat the diversified baseline. Practice for free, learn for life.
          </Text>
        </Animated.View>

        <View style={{ gap: spacing.md }}>
          {(Object.keys(MODE_META) as Mode[]).map((mode, i) => {
            const meta = MODE_META[mode];
            const best = bests?.[mode];
            const colors = MODE_COLORS[mode];
            return (
              <Animated.View key={mode} entering={FadeInUp.duration(500).delay(80 + i * 60)}>
                <Pressable
                  onPress={() => {
                    startRun(mode);
                    navigation.navigate('TradeGame');
                  }}
                  style={({ pressed }) => [pressed && { transform: [{ scale: 0.98 }] }]}
                >
                  <View style={[styles.modeCard, shadows.glow]}>
                    <LinearGradient
                      colors={colors as any}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={StyleSheet.absoluteFill}
                    />
                    <View style={styles.modeTop}>
                      <View>
                        <Text style={styles.modeLabel}>{meta.label}</Text>
                        <Text style={styles.modeSpan}>{meta.span} • ~{Math.round((meta.ticks * meta.tickMs) / 1000)}s</Text>
                      </View>
                      <Text style={styles.modeEmoji}>{meta.emoji}</Text>
                    </View>
                    <Text style={styles.modeDesc}>{meta.description}</Text>
                    <View style={styles.modeFooter}>
                      {best ? (
                        <Text style={styles.bestText}>
                          best: {(best.finalReturn * 100).toFixed(1)}%
                          {best.diversifierBadge ? ' • 🛡 diversifier' : ''}
                        </Text>
                      ) : (
                        <Text style={styles.bestText}>no run yet</Text>
                      )}
                      <Text style={styles.playText}>play →</Text>
                    </View>
                  </View>
                </Pressable>
              </Animated.View>
            );
          })}
        </View>

        <Animated.View entering={FadeInUp.duration(500).delay(280)}>
          <Text style={styles.sectionLabel}>squad — best 1yr returns</Text>
          <GlassCard>
            <View style={{ gap: spacing.md }}>
              {mockBoard.map((p, i) => (
                <View key={p.name} style={[styles.row, p.name === 'You' && styles.rowYou]}>
                  <View style={styles.rowLeft}>
                    <Text style={styles.rank}>{String(i + 1).padStart(2, '0')}</Text>
                    <Text style={styles.rowEmoji}>{p.emoji}</Text>
                    <Text style={[styles.rowName, p.name === 'You' && { color: palette.cream }]}>{p.name}</Text>
                  </View>
                  <Text style={[styles.rowReturn, { color: p.ret >= 0 ? palette.mintDeep : palette.peachDeep }, p.name === 'You' && { color: palette.cream }]}>
                    {p.ret >= 0 ? '+' : ''}
                    {(p.ret * 100).toFixed(1)}%
                  </Text>
                </View>
              ))}
            </View>
          </GlassCard>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(360)}>
          <GlassCard>
            <Text style={styles.label}>how it works</Text>
            <Text style={styles.tip}>
              You start with $10,000 of fake cash. The clock runs through real historical prices. Tap any stock to buy or sell. At the end, you'll see how your portfolio's risk and return stacked up against a boring-but-mighty diversified ETF.
            </Text>
            <Text style={styles.tip}>
              The lesson lands at the end. Promise.
            </Text>
          </GlassCard>
        </Animated.View>

        <View style={{ height: 140 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.xl },
  eyebrow: { ...typography.label, color: palette.mintDeep },
  title: { ...typography.display, color: palette.ink },
  sub: { ...typography.body, color: palette.inkSoft, marginTop: 6 },
  sectionLabel: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.md, marginLeft: 4 },
  modeCard: {
    borderRadius: radius.xl,
    padding: spacing.xl,
    overflow: 'hidden',
    minHeight: 140,
    justifyContent: 'space-between',
    gap: spacing.md,
  },
  modeTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' },
  modeLabel: { ...typography.h1, color: palette.ink },
  modeSpan: { ...typography.caption, color: palette.inkSoft, marginTop: 2 },
  modeEmoji: { fontSize: 38 },
  modeDesc: { ...typography.body, color: palette.inkSoft },
  modeFooter: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  bestText: { ...typography.caption, color: palette.inkSoft, fontWeight: '600' },
  playText: { ...typography.bodyBold, color: palette.ink },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: spacing.md, borderRadius: radius.md },
  rowYou: { backgroundColor: palette.ink },
  rowLeft: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  rank: { ...typography.label, color: palette.inkMuted, width: 22 },
  rowEmoji: { fontSize: 18 },
  rowName: { ...typography.bodyBold, color: palette.ink },
  rowReturn: { ...typography.bodyBold },
  label: { ...typography.label, color: palette.inkMuted },
  tip: { ...typography.body, color: palette.inkSoft, marginTop: spacing.sm },
});
