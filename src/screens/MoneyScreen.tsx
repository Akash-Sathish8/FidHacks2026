import React from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { ProgressBar } from '../components/ProgressBar';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { spending, stocks } from '../data/seed';

export default function MoneyScreen() {
  const navigation = useNavigation<any>();
  const totalSpent = spending.reduce((s, c) => s + c.spent, 0);
  const totalBudget = spending.reduce((s, c) => s + c.budget, 0);
  const overCategory = spending.find((c) => c.spent > c.budget);

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.eyebrow}>your money</Text>
          <Text style={styles.title}>this month</Text>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(80)}>
          <GlassCard>
            <Text style={styles.label}>Spent so far</Text>
            <Text style={styles.bigNumber}>${totalSpent.toLocaleString()}</Text>
            <Text style={styles.sub}>of ${totalBudget.toLocaleString()} planned</Text>
            <View style={{ marginTop: spacing.md }}>
              <ProgressBar value={totalSpent / totalBudget} colors={['#A78BFA', '#FF9E7D']} />
            </View>
            {overCategory && (
              <View style={styles.alert}>
                <Text style={styles.alertEmoji}>{overCategory.emoji}</Text>
                <Text style={styles.alertText}>
                  Heads up — {overCategory.name} is ${overCategory.spent - overCategory.budget} over plan.
                </Text>
              </View>
            )}
          </GlassCard>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(140)}>
          <Text style={styles.sectionLabel}>Categories</Text>
          <View style={{ gap: spacing.md }}>
            {spending.map((c) => {
              const pct = Math.min(1, c.spent / c.budget);
              const over = c.spent > c.budget;
              return (
                <View key={c.name} style={styles.row}>
                  <View style={styles.rowTop}>
                    <View style={styles.rowLeft}>
                      <Text style={styles.rowEmoji}>{c.emoji}</Text>
                      <Text style={styles.rowName}>{c.name}</Text>
                    </View>
                    <Text style={[styles.rowAmount, over && { color: palette.peachDeep }]}>
                      ${c.spent} / ${c.budget}
                    </Text>
                  </View>
                  <ProgressBar value={pct} height={6} colors={[c.color, c.color]} />
                </View>
              );
            })}
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(200)}>
          <Pressable onPress={() => navigation.navigate('FutureSelf')}>
            <GlassCard>
              <Text style={styles.label}>Future self</Text>
              <Text style={styles.h2}>If you invest $50/wk{'\n'}starting now…</Text>
              <Text style={styles.sub}>See what your money becomes at 25, 35, and 65.</Text>
              <View style={styles.ctaRow}>
                <Text style={styles.ctaText}>Open visualizer →</Text>
              </View>
            </GlassCard>
          </Pressable>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(260)}>
          <Text style={styles.sectionLabel}>Investments</Text>
          <GlassCard>
            <View style={{ gap: spacing.md }}>
              {stocks.map((s) => (
                <View key={s.symbol} style={styles.stockRow}>
                  <View>
                    <Text style={styles.stockSym}>{s.symbol}</Text>
                    <Text style={styles.stockName}>{s.name}</Text>
                  </View>
                  <Text style={[styles.stockDelta, { color: s.positive ? palette.mintDeep : palette.peachDeep }]}>
                    {s.delta}
                  </Text>
                </View>
              ))}
            </View>
          </GlassCard>
        </Animated.View>

        <View style={{ height: 120 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.xl },
  eyebrow: { ...typography.label, color: palette.mintDeep },
  title: { ...typography.display, color: palette.ink },
  label: { ...typography.label, color: palette.inkMuted },
  sectionLabel: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.md, marginLeft: 4 },
  bigNumber: { ...typography.display, color: palette.ink, marginTop: 4 },
  sub: { ...typography.body, color: palette.inkSoft },
  alert: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginTop: spacing.lg,
    padding: spacing.md,
    borderRadius: radius.md,
    backgroundColor: palette.peachSoft,
  },
  alertEmoji: { fontSize: 20 },
  alertText: { ...typography.caption, color: palette.inkSoft, flex: 1 },
  row: {
    padding: spacing.md,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    gap: spacing.sm,
    ...shadows.soft,
  },
  rowTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  rowLeft: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  rowEmoji: { fontSize: 18 },
  rowName: { ...typography.bodyBold, color: palette.ink },
  rowAmount: { ...typography.caption, color: palette.inkSoft },
  h2: { ...typography.h2, color: palette.ink, marginTop: 6 },
  ctaRow: { marginTop: spacing.md },
  ctaText: { ...typography.bodyBold, color: palette.lavenderDeep },
  stockRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  stockSym: { ...typography.h3, color: palette.ink },
  stockName: { ...typography.caption, color: palette.inkMuted },
  stockDelta: { ...typography.bodyBold },
});
