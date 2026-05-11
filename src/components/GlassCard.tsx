import React from 'react';
import { View, ViewProps, StyleSheet } from 'react-native';
import { BlurView } from 'expo-blur';
import { palette, radius, shadows, spacing } from '../theme/tokens';

interface Props extends ViewProps {
  intensity?: number;
  padded?: boolean;
  tint?: 'light' | 'default';
}

export function GlassCard({ children, style, intensity = 40, padded = true, tint = 'light', ...rest }: Props) {
  return (
    <View style={[styles.wrap, shadows.card, style]} {...rest}>
      <BlurView intensity={intensity} tint={tint} style={StyleSheet.absoluteFill} />
      <View style={[styles.overlay, padded && styles.padded]}>{children}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    borderRadius: radius.xl,
    overflow: 'hidden',
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
  },
  overlay: {
    width: '100%',
  },
  padded: {
    padding: spacing.xl,
  },
});
