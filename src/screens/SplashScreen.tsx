import React, { useEffect } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Animated, { FadeIn, FadeInDown } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GradientButton } from '../components/GradientButton';
import { Buddy } from '../components/Buddy';
import { palette, spacing, typography } from '../theme/tokens';

export default function SplashScreen() {
  const navigation = useNavigation<any>();

  return (
    <GradientBackground>
      <View style={styles.root}>
        <Animated.View entering={FadeIn.duration(800)} style={styles.heroBuddy}>
          <Buddy kind="panda" size={200} accessory="✨" />
        </Animated.View>

        <Animated.View entering={FadeInDown.duration(600).delay(200)} style={styles.copy}>
          <Text style={styles.eyebrow}>Money Moves</Text>
          <Text style={styles.title}>Make your first{'\n'}money moves.</Text>
          <Text style={styles.body}>
            A pocket coach for the moves that compound — your first paycheck, your first negotiation, your first invested dollar.
          </Text>
        </Animated.View>

        <Animated.View entering={FadeInDown.duration(600).delay(400)} style={styles.cta}>
          <GradientButton label="Begin your quest" onPress={() => navigation.replace('Login')} />
          <Text style={styles.footnote}>For the women writing their own financial story.</Text>
        </Animated.View>
      </View>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, paddingHorizontal: spacing.xl, paddingTop: 100, paddingBottom: 60, justifyContent: 'space-between' },
  heroBuddy: { alignItems: 'center', marginTop: spacing.xxxl },
  copy: { gap: spacing.md },
  eyebrow: { ...typography.label, color: palette.lavenderDeep },
  title: { ...typography.display, color: palette.ink },
  body: { ...typography.body, color: palette.inkSoft, maxWidth: 340 },
  cta: { gap: spacing.lg, alignItems: 'center' },
  footnote: { ...typography.caption, color: palette.inkMuted, textAlign: 'center' },
});
