import React, { useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GradientButton } from '../components/GradientButton';
import { GlassCard } from '../components/GlassCard';
import { palette, radius, spacing, typography } from '../theme/tokens';
import { useApp } from '../state/AppState';

export default function LoginScreen() {
  const navigation = useNavigation<any>();
  const { setUser } = useApp();
  const [name, setName] = useState('');

  return (
    <GradientBackground>
      <View style={styles.root}>
        <Animated.View entering={FadeInDown.duration(500)} style={styles.heading}>
          <Text style={styles.eyebrow}>Welcome in</Text>
          <Text style={styles.title}>What should{'\n'}we call you?</Text>
          <Text style={styles.sub}>One name. We don't ask for last names, schools, or bank logins to get you started.</Text>
        </Animated.View>

        <Animated.View entering={FadeInDown.duration(500).delay(120)}>
          <GlassCard>
            <Text style={styles.fieldLabel}>First name</Text>
            <TextInput
              style={styles.input}
              placeholder="e.g. Chelsea"
              placeholderTextColor={palette.inkMuted}
              value={name}
              onChangeText={setName}
              autoCapitalize="words"
              autoCorrect={false}
            />
            <Text style={styles.tinyNote}>This stays on your device.</Text>
          </GlassCard>
        </Animated.View>

        <View style={styles.bottom}>
          <GradientButton
            label="Continue"
            disabled={name.trim().length === 0}
            onPress={() => {
              setUser((u) => ({ ...u, username: name.trim() }));
              navigation.replace('BuddyPicker');
            }}
          />
        </View>
      </View>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, paddingHorizontal: spacing.xl, paddingTop: 100, paddingBottom: 60, gap: spacing.xxl, justifyContent: 'space-between' },
  heading: { gap: spacing.sm },
  eyebrow: { ...typography.label, color: palette.peachDeep },
  title: { ...typography.display, color: palette.ink },
  sub: { ...typography.body, color: palette.inkSoft, maxWidth: 320 },
  fieldLabel: { ...typography.label, color: palette.inkMuted, marginBottom: spacing.sm },
  input: {
    ...typography.h2,
    color: palette.ink,
    paddingVertical: spacing.md,
    paddingHorizontal: 0,
    borderBottomWidth: 2,
    borderBottomColor: palette.lavender,
  },
  tinyNote: { ...typography.caption, color: palette.inkMuted, marginTop: spacing.md },
  bottom: { alignItems: 'center' },
});
