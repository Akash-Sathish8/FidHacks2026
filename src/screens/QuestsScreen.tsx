import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { Chip } from '../components/Chip';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { quests, Quest } from '../data/seed';
import { useApp } from '../state/AppState';

const PILLARS: { id: Quest['pillar'] | 'all'; label: string; emoji: string }[] = [
  { id: 'all', label: 'All', emoji: '✦' },
  { id: 'negotiate', label: 'Negotiate', emoji: '👑' },
  { id: 'invest', label: 'Invest', emoji: '📈' },
  { id: 'budget', label: 'Budget', emoji: '💸' },
  { id: 'benefits', label: 'Benefits', emoji: '🎁' },
  { id: 'side-hustle', label: 'Hustle', emoji: '⚡' },
];

export default function QuestsScreen() {
  const navigation = useNavigation<any>();
  const { user } = useApp();
  const [filter, setFilter] = useState<Quest['pillar'] | 'all'>('all');

  const filtered = filter === 'all' ? quests : quests.filter((q) => q.pillar === filter);

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.eyebrow}>career quests</Text>
          <Text style={styles.title}>Money Moves{'\n'}that matter.</Text>
          <Text style={styles.sub}>Each quest is one real-life money move. AI walks you through it.</Text>
        </Animated.View>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chipRow}>
          {PILLARS.map((p) => (
            <Chip key={p.id} label={p.label} emoji={p.emoji} active={filter === p.id} onPress={() => setFilter(p.id)} />
          ))}
        </ScrollView>

        <View style={{ gap: spacing.lg }}>
          {filtered.map((q, i) => {
            const done = user.completedQuests.includes(q.id);
            return (
              <Animated.View key={q.id} entering={FadeInUp.duration(400).delay(60 * i)}>
                <Pressable
                  onPress={() => {
                    if (q.kind === 'simulator') navigation.navigate('Negotiation', { questId: q.id });
                    else navigation.navigate('QuestDetail', { questId: q.id });
                  }}
                >
                  <GlassCard>
                    <View style={styles.cardTop}>
                      <View style={styles.cardLeft}>
                        <View style={[styles.diffPill, diffStyle(q.difficulty)]}>
                          <Text style={styles.diffText}>{q.difficulty}</Text>
                        </View>
                        <Text style={styles.cardTitle}>{q.title}</Text>
                      </View>
                      <Text style={styles.cardEmoji}>{q.emoji}</Text>
                    </View>
                    <Text style={styles.blurb}>{q.blurb}</Text>
                    <View style={styles.footer}>
                      <View style={styles.footerLeft}>
                        <Text style={styles.tag}>◴ {q.duration}</Text>
                        <Text style={styles.tag}>+{q.reward.coins} ◐</Text>
                        <Text style={styles.tag}>+{q.reward.xp} XP</Text>
                      </View>
                      {done ? <Text style={styles.done}>✓ done</Text> : <Text style={styles.go}>open →</Text>}
                    </View>
                  </GlassCard>
                </Pressable>
              </Animated.View>
            );
          })}
        </View>

        <View style={{ height: 120 }} />
      </ScrollView>
    </GradientBackground>
  );
}

function diffStyle(d: Quest['difficulty']) {
  if (d === 'starter') return { backgroundColor: palette.mintSoft };
  if (d === 'core') return { backgroundColor: palette.lavenderSoft };
  return { backgroundColor: palette.peachSoft };
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.lg },
  eyebrow: { ...typography.label, color: palette.lavenderDeep },
  title: { ...typography.display, color: palette.ink },
  sub: { ...typography.body, color: palette.inkSoft, marginTop: 6 },
  chipRow: { gap: spacing.sm, paddingVertical: spacing.md, paddingRight: spacing.xl },
  cardTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' },
  cardLeft: { flex: 1, gap: spacing.sm },
  diffPill: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: radius.pill, alignSelf: 'flex-start' },
  diffText: { ...typography.caption, color: palette.ink, textTransform: 'uppercase', letterSpacing: 0.8 },
  cardTitle: { ...typography.h2, color: palette.ink },
  cardEmoji: { fontSize: 32 },
  blurb: { ...typography.body, color: palette.inkSoft, marginTop: spacing.sm },
  footer: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: spacing.lg },
  footerLeft: { flexDirection: 'row', gap: spacing.md },
  tag: { ...typography.caption, color: palette.inkMuted },
  done: { ...typography.bodyBold, color: palette.mintDeep },
  go: { ...typography.bodyBold, color: palette.lavenderDeep },
});
