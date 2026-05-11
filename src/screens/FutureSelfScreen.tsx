import React, { useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, View, Pressable } from 'react-native';
import Slider from '@react-native-community/slider';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';

function compound(weekly: number, years: number, annualRate = 0.08) {
  const weeks = years * 52;
  const r = annualRate / 52;
  return weekly * ((Math.pow(1 + r, weeks) - 1) / r);
}

const ages = [25, 35, 65];

export default function FutureSelfScreen() {
  const navigation = useNavigation<any>();
  const [weekly, setWeekly] = useState(50);
  const startAge = 19;

  const results = useMemo(
    () => ages.map((age) => ({ age, total: compound(weekly, age - startAge) })),
    [weekly]
  );

  return (
    <GradientBackground>
      <ScrollView contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
        <Pressable onPress={() => navigation.goBack()} style={styles.close}>
          <Text style={styles.closeText}>×</Text>
        </Pressable>

        <Animated.View entering={FadeInUp.duration(500)}>
          <Text style={styles.eyebrow}>future self</Text>
          <Text style={styles.title}>What your{'\n'}money becomes.</Text>
          <Text style={styles.sub}>Set a weekly investment. We'll show what compounds.</Text>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(100)}>
          <GlassCard>
            <Text style={styles.label}>Weekly investment</Text>
            <Text style={styles.bigAmount}>${weekly}</Text>
            <Slider
              minimumValue={10}
              maximumValue={300}
              step={5}
              value={weekly}
              onValueChange={setWeekly}
              minimumTrackTintColor={palette.lavenderDeep}
              maximumTrackTintColor={palette.creamDeep}
              thumbTintColor={palette.lavenderDeep}
              style={{ marginTop: spacing.sm }}
            />
            <View style={styles.rangeRow}>
              <Text style={styles.rangeText}>$10</Text>
              <Text style={styles.rangeText}>$300</Text>
            </View>
          </GlassCard>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(160)}>
          <Text style={styles.sectionLabel}>At these ages</Text>
          <View style={{ gap: spacing.md }}>
            {results.map((r, i) => (
              <View key={r.age} style={[styles.ageCard, i === 2 && styles.ageCardFinale]}>
                <View>
                  <Text style={styles.ageLabel}>Age {r.age}</Text>
                  <Text style={[styles.ageSub, i === 2 && { color: palette.cream }]}>
                    {r.age - startAge} years compounding
                  </Text>
                </View>
                <Text style={[styles.ageAmount, i === 2 && { color: palette.cream }]}>
                  ${Math.round(r.total).toLocaleString()}
                </Text>
              </View>
            ))}
          </View>
        </Animated.View>

        <Animated.View entering={FadeInUp.duration(500).delay(220)}>
          <GlassCard>
            <Text style={styles.label}>The compounding cost of waiting</Text>
            <Text style={styles.tip}>
              If you start at 19 instead of 29, you end up with roughly 2× more by 65 — even putting the same dollars in. Time matters more than amount.
            </Text>
          </GlassCard>
        </Animated.View>

        <View style={{ height: 80 }} />
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 80, gap: spacing.xl },
  close: { position: 'absolute', top: 60, right: spacing.xl, width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, zIndex: 10 },
  closeText: { fontSize: 24, color: palette.ink, lineHeight: 26 },
  eyebrow: { ...typography.label, color: palette.lavenderDeep },
  title: { ...typography.display, color: palette.ink },
  sub: { ...typography.body, color: palette.inkSoft, marginTop: 6 },
  label: { ...typography.label, color: palette.inkMuted },
  bigAmount: { ...typography.display, color: palette.ink, marginTop: 4 },
  rangeRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 4 },
  rangeText: { ...typography.caption, color: palette.inkMuted },
  sectionLabel: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.md, marginLeft: 4 },
  ageCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: spacing.xl,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    ...shadows.soft,
  },
  ageCardFinale: { backgroundColor: palette.ink, borderColor: palette.ink, ...shadows.glow },
  ageLabel: { ...typography.h2, color: palette.ink },
  ageSub: { ...typography.caption, color: palette.inkMuted, marginTop: 2 },
  ageAmount: { ...typography.h1, color: palette.lavenderDeep },
  tip: { ...typography.body, color: palette.inkSoft, marginTop: spacing.sm },
});
