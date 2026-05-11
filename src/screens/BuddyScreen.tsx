import React from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { Buddy } from '../components/Buddy';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { shopItems } from '../data/seed';
import { useApp, Accessory } from '../state/AppState';

const accessoryEmoji = (a: string | null) => shopItems.find((i) => i.id === a)?.emoji;

export default function BuddyScreen() {
  const { user, equipAccessory, buyAccessory } = useApp();

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInUp.duration(500)} style={styles.top}>
          <View>
            <Text style={styles.eyebrow}>your buddy</Text>
            <Text style={styles.title}>{user.buddyName}</Text>
          </View>
          <View style={styles.coinPill}>
            <Text style={styles.coinEmoji}>◐</Text>
            <Text style={styles.coinAmount}>{user.coins.toLocaleString()}</Text>
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(80)} style={styles.stage}>
          <LinearGradient
            colors={['#FFE5D4', '#E0D4FF', '#D4F0E5']}
            style={[StyleSheet.absoluteFill, { borderRadius: radius.xl }]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          />
          <Buddy kind={user.buddyKind} size={200} accessory={accessoryEmoji(user.accessory)} />
          <View style={styles.tag}>
            <Text style={styles.tagText}>Level {user.level} • {user.streak}🔥</Text>
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(140)}>
          <Text style={styles.sectionLabel}>Wardrobe</Text>
          <View style={styles.grid}>
            {shopItems.map((item) => {
              const owned = user.unlockedAccessories.includes(item.id as Accessory);
              const equipped = user.accessory === item.id;
              return (
                <Pressable
                  key={item.id}
                  style={[styles.itemCard, equipped && styles.itemCardActive]}
                  onPress={() => {
                    if (owned) {
                      equipAccessory(item.id as Accessory);
                    } else {
                      buyAccessory(item.id as Accessory, item.cost);
                    }
                  }}
                >
                  <Text style={styles.itemEmoji}>{item.emoji}</Text>
                  <Text style={[styles.itemLabel, equipped && { color: palette.cream }]}>{item.label}</Text>
                  {equipped ? (
                    <Text style={styles.itemBadge}>equipped</Text>
                  ) : owned ? (
                    <Text style={styles.itemBadgeOwned}>tap to wear</Text>
                  ) : (
                    <Text style={styles.itemCost}>◐ {item.cost}</Text>
                  )}
                </Pressable>
              );
            })}
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(220)}>
          <GlassCard>
            <Text style={styles.label}>buddy stats</Text>
            <View style={styles.statRow}>
              <Stat label="Level" value={user.level} />
              <Stat label="XP" value={user.xp} />
              <Stat label="Streak" value={user.streak} />
            </View>
          </GlassCard>
        </Animated.View>

        <View style={{ height: 120 }} />
      </ScrollView>
    </GradientBackground>
  );
}

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <View style={{ flex: 1, alignItems: 'center' }}>
      <Text style={statStyles.value}>{value}</Text>
      <Text style={statStyles.label}>{label}</Text>
    </View>
  );
}

const statStyles = StyleSheet.create({
  value: { ...typography.h1, color: palette.ink },
  label: { ...typography.caption, color: palette.inkMuted, marginTop: 4 },
});

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.xl },
  top: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  eyebrow: { ...typography.label, color: palette.peachDeep },
  title: { ...typography.display, color: palette.ink },
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
  stage: {
    height: 260,
    borderRadius: radius.xl,
    overflow: 'hidden',
    alignItems: 'center',
    justifyContent: 'center',
    ...shadows.glow,
  },
  tag: {
    position: 'absolute',
    bottom: spacing.lg,
    paddingHorizontal: spacing.lg,
    paddingVertical: 6,
    borderRadius: radius.pill,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
  },
  tagText: { ...typography.caption, color: palette.ink, fontWeight: '700' },
  sectionLabel: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.md, marginLeft: 4 },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.md },
  itemCard: {
    width: '31%',
    aspectRatio: 0.9,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderColor: palette.glassBorder,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 4,
    ...shadows.soft,
  },
  itemCardActive: { backgroundColor: palette.ink, borderColor: palette.ink },
  itemEmoji: { fontSize: 32 },
  itemLabel: { ...typography.caption, color: palette.inkSoft, fontWeight: '600' },
  itemBadge: { ...typography.caption, color: palette.mintDeep },
  itemBadgeOwned: { ...typography.caption, color: palette.lavenderDeep },
  itemCost: { ...typography.caption, color: palette.inkMuted },
  label: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.md },
  statRow: { flexDirection: 'row' },
});
