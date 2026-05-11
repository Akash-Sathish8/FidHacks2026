import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable, ActivityIndicator } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { GradientButton } from '../components/GradientButton';
import { palette, radius, spacing, typography } from '../theme/tokens';
import { quests } from '../data/seed';
import { useApp } from '../state/AppState';
import { sendMessage } from '../lib/claude';
import { RootStackParamList } from '../navigation';

type Route = RouteProp<RootStackParamList, 'QuestDetail'>;

export default function QuestDetailScreen() {
  const navigation = useNavigation<any>();
  const route = useRoute<Route>();
  const { completeQuest, user } = useApp();
  const quest = quests.find((q) => q.id === route.params.questId)!;
  const [lesson, setLesson] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const completed = user.completedQuests.includes(quest.id);

  async function generateLesson() {
    setLoading(true);
    try {
      const text = await sendMessage({
        system: `You are a financial coach for first-year college women. Use a warm, direct, Gen Z-fluent voice — no jargon without translation, no condescension. Each lesson should give a punchy 4-step walkthrough with one tactical action they can take today. Keep it under 220 words.`,
        messages: [{ role: 'user', content: `Walk me through: ${quest.title}. Context: ${quest.blurb}` }],
        maxTokens: 500,
      });
      setLesson(text);
    } finally {
      setLoading(false);
    }
  }

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root}>
        <Pressable onPress={() => navigation.goBack()} style={styles.close}>
          <Text style={styles.closeText}>×</Text>
        </Pressable>

        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.emoji}>{quest.emoji}</Text>
          <Text style={styles.eyebrow}>{quest.pillar.replace('-', ' ')} • {quest.difficulty}</Text>
          <Text style={styles.title}>{quest.title}</Text>
          <Text style={styles.blurb}>{quest.blurb}</Text>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(80)}>
          <GlassCard>
            <Text style={styles.label}>What you'll unlock</Text>
            <View style={styles.rewardRow}>
              <View style={styles.rewardItem}>
                <Text style={styles.rewardEmoji}>◐</Text>
                <Text style={styles.rewardAmount}>+{quest.reward.coins}</Text>
                <Text style={styles.rewardLabel}>coins</Text>
              </View>
              <View style={styles.rewardItem}>
                <Text style={styles.rewardEmoji}>✦</Text>
                <Text style={styles.rewardAmount}>+{quest.reward.xp}</Text>
                <Text style={styles.rewardLabel}>XP</Text>
              </View>
              <View style={styles.rewardItem}>
                <Text style={styles.rewardEmoji}>◴</Text>
                <Text style={styles.rewardAmount}>{quest.duration}</Text>
                <Text style={styles.rewardLabel}>length</Text>
              </View>
            </View>
          </GlassCard>
        </Animated.View>

        {!lesson && (
          <Animated.View entering={FadeInUp.duration(500).delay(140)} style={{ alignItems: 'center' }}>
            <GradientButton
              label={loading ? 'Loading…' : "Start lesson"}
              disabled={loading}
              onPress={generateLesson}
            />
            {loading && <ActivityIndicator color={palette.lavenderDeep} style={{ marginTop: spacing.lg }} />}
          </Animated.View>
        )}

        {lesson && (
          <Animated.View entering={FadeInUp.duration(500)}>
            <GlassCard>
              <Text style={styles.label}>your lesson</Text>
              <Text style={styles.lessonText}>{lesson}</Text>
            </GlassCard>
            {!completed && (
              <View style={{ alignItems: 'center', marginTop: spacing.xl }}>
                <GradientButton
                  variant="mint"
                  label={`Mark complete  +${quest.reward.coins}◐`}
                  onPress={() => {
                    completeQuest(quest.id, quest.reward);
                    navigation.goBack();
                  }}
                />
              </View>
            )}
          </Animated.View>
        )}

        <View style={{ height: 80 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 90, gap: spacing.xl, paddingBottom: spacing.xxxl },
  close: { position: 'absolute', top: 60, right: spacing.xl, width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, zIndex: 10 },
  closeText: { fontSize: 24, color: palette.ink, lineHeight: 26 },
  emoji: { fontSize: 56 },
  eyebrow: { ...typography.label, color: palette.lavenderDeep, marginTop: spacing.md },
  title: { ...typography.display, color: palette.ink, marginTop: 4 },
  blurb: { ...typography.body, color: palette.inkSoft, marginTop: spacing.sm },
  label: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.md },
  rewardRow: { flexDirection: 'row', justifyContent: 'space-between' },
  rewardItem: { alignItems: 'center', gap: 4, flex: 1 },
  rewardEmoji: { fontSize: 22, color: palette.lavenderDeep },
  rewardAmount: { ...typography.h3, color: palette.ink },
  rewardLabel: { ...typography.caption, color: palette.inkMuted },
  lessonText: { ...typography.body, color: palette.ink, marginTop: spacing.sm },
});
