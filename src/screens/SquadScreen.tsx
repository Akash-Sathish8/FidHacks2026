import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { squadMembers } from '../data/seed';
import { useApp } from '../state/AppState';

export default function SquadScreen() {
  const { user } = useApp();
  const sorted = [...squadMembers].sort((a, b) => b.streak - a.streak);

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.eyebrow}>your squad</Text>
          <Text style={styles.title}>Quest together.</Text>
          <Text style={styles.sub}>Your numbers stay private. Only streaks, levels, and high-fives are shared.</Text>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(80)}>
          <GlassCard>
            <Text style={styles.label}>this week</Text>
            <Text style={styles.bigNumber}>3 of 5</Text>
            <Text style={styles.sub}>squad members hit their streak</Text>
          </GlassCard>
        </Animated.View>

        <View style={{ gap: spacing.md }}>
          {sorted.map((m, i) => (
            <Animated.View key={m.name} entering={FadeInUp.duration(400).delay(60 * i)}>
              <View style={[styles.row, m.you && styles.rowYou]}>
                <View style={styles.left}>
                  <Text style={styles.rank}>{String(i + 1).padStart(2, '0')}</Text>
                  <Text style={styles.emoji}>{m.emoji}</Text>
                  <View>
                    <Text style={[styles.name, m.you && styles.nameYou]}>{m.name}</Text>
                    <Text style={styles.meta}>level {m.level}</Text>
                  </View>
                </View>
                <Text style={styles.streak}>🔥 {m.streak}</Text>
              </View>
            </Animated.View>
          ))}
        </View>

        <Animated.View entering={FadeInUp.duration(500).delay(400)}>
          <GlassCard>
            <Text style={styles.label}>group challenge</Text>
            <Text style={styles.h2}>Negotiation Week</Text>
            <Text style={styles.sub}>Everyone runs the AI negotiation simulator once. Squad wins +500 bonus coins each.</Text>
            <View style={styles.progress}>
              <View style={[styles.progressFill, { width: '60%' }]} />
            </View>
            <Text style={styles.progressLabel}>3 / 5 completed</Text>
          </GlassCard>
        </Animated.View>

        <View style={{ height: 120 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.xl },
  eyebrow: { ...typography.label, color: palette.roseDeep },
  title: { ...typography.display, color: palette.ink },
  sub: { ...typography.body, color: palette.inkSoft, marginTop: 4 },
  label: { ...typography.label, color: palette.inkMuted },
  bigNumber: { ...typography.display, color: palette.ink, marginTop: 4 },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: spacing.lg,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    ...shadows.soft,
  },
  rowYou: { backgroundColor: palette.ink, borderColor: palette.ink },
  left: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  rank: { ...typography.label, color: palette.inkMuted, width: 28 },
  emoji: { fontSize: 24 },
  name: { ...typography.h3, color: palette.ink },
  nameYou: { color: palette.cream },
  meta: { ...typography.caption, color: palette.inkMuted },
  streak: { ...typography.bodyBold, color: palette.peachDeep },
  h2: { ...typography.h2, color: palette.ink, marginTop: 6 },
  progress: { marginTop: spacing.lg, height: 8, backgroundColor: palette.creamDeep, borderRadius: 4, overflow: 'hidden' },
  progressFill: { height: 8, backgroundColor: palette.roseDeep },
  progressLabel: { ...typography.caption, color: palette.inkMuted, marginTop: 6 },
});
