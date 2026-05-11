import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, TextInput, View, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GradientButton } from '../components/GradientButton';
import { GlassCard } from '../components/GlassCard';
import { Buddy, BuddyKind } from '../components/Buddy';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { useApp } from '../state/AppState';

const OPTIONS: { kind: BuddyKind; vibe: string }[] = [
  { kind: 'panda', vibe: 'soft, steady, savings-focused' },
  { kind: 'dino', vibe: 'bold, risk-savvy, investor energy' },
  { kind: 'koala', vibe: 'patient, calm, long-term mindset' },
  { kind: 'bunny', vibe: 'curious, hustle-ready, quick mover' },
  { kind: 'fox', vibe: 'clever, negotiator, knows their worth' },
];

export default function BuddyPickerScreen() {
  const navigation = useNavigation<any>();
  const { setUser } = useApp();
  const [selected, setSelected] = useState<BuddyKind>('panda');
  const [name, setName] = useState('Mochi');

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Animated.View entering={FadeInDown.duration(500)} style={styles.heading}>
          <Text style={styles.eyebrow}>Step 2 of 2</Text>
          <Text style={styles.title}>Pick your buddy.</Text>
          <Text style={styles.sub}>Your buddy levels up as your money habits do. Choose the vibe that fits.</Text>
        </Animated.View>

        <Animated.View entering={FadeInDown.duration(500).delay(120)} style={styles.preview}>
          <Buddy kind={selected} size={180} />
        </Animated.View>

        <View style={styles.row}>
          {OPTIONS.map((o) => (
            <Pressable
              key={o.kind}
              onPress={() => setSelected(o.kind)}
              style={[styles.card, selected === o.kind && styles.cardActive]}
            >
              <Buddy kind={o.kind} size={60} floating={false} />
              <Text style={[styles.cardName, selected === o.kind && styles.cardNameActive]}>{o.kind}</Text>
            </Pressable>
          ))}
        </View>

        <GlassCard>
          <Text style={styles.fieldLabel}>Name your buddy</Text>
          <TextInput style={styles.input} value={name} onChangeText={setName} placeholderTextColor={palette.inkMuted} />
          <Text style={styles.vibe}>vibe: {OPTIONS.find((o) => o.kind === selected)?.vibe}</Text>
        </GlassCard>

        <View style={{ alignItems: 'center', marginTop: spacing.xl }}>
          <GradientButton
            label={`Let's go, ${name || 'buddy'}`}
            onPress={() => {
              setUser((u) => ({ ...u, buddyKind: selected, buddyName: name || 'Buddy' }));
              navigation.replace('Main');
            }}
          />
        </View>
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 90, paddingBottom: 100, gap: spacing.xl },
  heading: { gap: spacing.sm },
  eyebrow: { ...typography.label, color: palette.mintDeep },
  title: { ...typography.display, color: palette.ink },
  sub: { ...typography.body, color: palette.inkSoft, maxWidth: 320 },
  preview: { alignItems: 'center', paddingVertical: spacing.lg },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.md, justifyContent: 'center' },
  card: {
    width: 96,
    paddingVertical: spacing.md,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    alignItems: 'center',
    ...shadows.soft,
  },
  cardActive: {
    backgroundColor: palette.ink,
    borderColor: palette.ink,
  },
  cardName: { ...typography.caption, color: palette.inkSoft, marginTop: 4, textTransform: 'capitalize' },
  cardNameActive: { color: palette.white },
  fieldLabel: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.sm },
  input: {
    ...typography.h2,
    color: palette.ink,
    paddingVertical: spacing.sm,
    borderBottomWidth: 2,
    borderBottomColor: palette.mint,
  },
  vibe: { ...typography.caption, color: palette.inkMuted, marginTop: spacing.md },
});
