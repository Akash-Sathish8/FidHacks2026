import React from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { Buddy } from '../components/Buddy';
import { ProgressBar } from '../components/ProgressBar';
import { Chip } from '../components/Chip';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { useApp } from '../state/AppState';
import { quests } from '../data/seed';

const accessoryEmoji = (a: string | null) => {
  switch (a) {
    case 'crown': return '👑';
    case 'glasses': return '🕶️';
    case 'headphones': return '🎧';
    case 'flower': return '🌸';
    case 'cap': return '🧢';
    case 'sparkle': return '✨';
    default: return undefined;
  }
};

const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

export default function HomeScreen() {
  const navigation = useNavigation<any>();
  const { user } = useApp();
  const xpInLevel = user.xp % 500;
  const nextQuest = quests.find((q) => !user.completedQuests.includes(q.id))!;

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)} style={styles.topRow}>
          <View>
            <Text style={styles.greeting}>good morning,</Text>
            <Text style={styles.name}>{user.username} ✦</Text>
          </View>
          <View style={styles.coinPill}>
            <Text style={styles.coinEmoji}>◐</Text>
            <Text style={styles.coinAmount}>{user.coins.toLocaleString()}</Text>
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(80)} style={styles.heroCard}>
          <LinearGradient
            colors={['#FFE5D4', '#E0D4FF', '#D4F0E5']}
            style={StyleSheet.absoluteFill}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          />
          <View style={styles.heroInner}>
            <Buddy kind={user.buddyKind} size={150} accessory={accessoryEmoji(user.accessory)} />
            <View style={styles.heroInfo}>
              <Text style={styles.buddyName}>{user.buddyName}</Text>
              <Text style={styles.buddyLevel}>Level {user.level} • {user.streak}🔥 day streak</Text>
              <View style={{ marginTop: 12 }}>
                <ProgressBar value={xpInLevel / 500} />
                <Text style={styles.xpLabel}>{xpInLevel} / 500 XP to level {user.level + 1}</Text>
              </View>
            </View>
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(160)}>
          <View style={styles.weekRow}>
            {days.map((d, i) => {
              const active = i < (new Date().getDay() === 0 ? 7 : new Date().getDay());
              return (
                <View key={i} style={[styles.dayChip, active && styles.dayChipActive]}>
                  <Text style={[styles.dayLetter, active && styles.dayLetterActive]}>{d}</Text>
                  <Text style={styles.dayDot}>{active ? '✦' : '·'}</Text>
                </View>
              );
            })}
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(220)}>
          <Pressable onPress={() => navigation.navigate('QuestDetail', { questId: nextQuest.id })}>
            <GlassCard>
              <View style={styles.questHeader}>
                <Text style={styles.label}>Today's quest</Text>
                <Text style={styles.questEmoji}>{nextQuest.emoji}</Text>
              </View>
              <Text style={styles.questTitle}>{nextQuest.title}</Text>
              <Text style={styles.questBlurb}>{nextQuest.blurb}</Text>
              <View style={styles.questFooter}>
                <Chip label={nextQuest.duration} emoji="◴" />
                <Chip label={`+${nextQuest.reward.coins} ◐`} />
                <Chip label={`+${nextQuest.reward.xp} XP`} />
              </View>
            </GlassCard>
          </Pressable>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(280)} style={styles.shortcutRow}>
          <Pressable style={styles.shortcut} onPress={() => navigation.navigate('FutureSelf')}>
            <Text style={styles.shortcutEmoji}>🔮</Text>
            <Text style={styles.shortcutLabel}>Future self</Text>
          </Pressable>
          <Pressable style={styles.shortcut} onPress={() => navigation.navigate('Negotiation', { questId: 'negotiate-internship' })}>
            <Text style={styles.shortcutEmoji}>💬</Text>
            <Text style={styles.shortcutLabel}>AI coach</Text>
          </Pressable>
          <Pressable style={styles.shortcut} onPress={() => navigation.getParent()?.navigate('Money')}>
            <Text style={styles.shortcutEmoji}>◐</Text>
            <Text style={styles.shortcutLabel}>Budget</Text>
          </Pressable>
        </Animated.View>

        <View style={{ height: 100 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.xl },
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  greeting: { ...typography.caption, color: palette.inkMuted },
  name: { ...typography.h1, color: palette.ink, textTransform: 'lowercase' },
  coinPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
    backgroundColor: palette.ink,
    ...shadows.soft,
  },
  coinEmoji: { color: palette.peachDeep, fontSize: 14 },
  coinAmount: { ...typography.bodyBold, color: palette.white },
  heroCard: {
    borderRadius: radius.xl,
    overflow: 'hidden',
    ...shadows.glow,
  },
  heroInner: { flexDirection: 'row', padding: spacing.xl, gap: spacing.lg, alignItems: 'center' },
  heroInfo: { flex: 1 },
  buddyName: { ...typography.h2, color: palette.ink },
  buddyLevel: { ...typography.caption, color: palette.inkSoft, marginTop: 4, letterSpacing: 0.2 },
  xpLabel: { ...typography.caption, color: palette.inkMuted, marginTop: 6 },
  weekRow: { flexDirection: 'row', gap: spacing.sm, justifyContent: 'space-between' },
  dayChip: {
    flex: 1,
    aspectRatio: 0.8,
    borderRadius: radius.md,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
  },
  dayChipActive: { backgroundColor: palette.ink, borderColor: palette.ink },
  dayLetter: { ...typography.caption, color: palette.inkMuted, fontWeight: '700' },
  dayLetterActive: { color: palette.white },
  dayDot: { color: palette.peachDeep, fontSize: 10 },
  questHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  questEmoji: { fontSize: 28 },
  label: { ...typography.label, color: palette.lavenderDeep },
  questTitle: { ...typography.h2, color: palette.ink, marginTop: 6 },
  questBlurb: { ...typography.body, color: palette.inkSoft, marginTop: 6 },
  questFooter: { flexDirection: 'row', gap: 8, marginTop: spacing.lg, flexWrap: 'wrap' },
  shortcutRow: { flexDirection: 'row', gap: spacing.md },
  shortcut: {
    flex: 1,
    padding: spacing.lg,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    alignItems: 'center',
    gap: 6,
    ...shadows.soft,
  },
  shortcutEmoji: { fontSize: 24 },
  shortcutLabel: { ...typography.caption, color: palette.inkSoft },
});
