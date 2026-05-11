import React from 'react';
import { Pressable, Text, StyleSheet, ViewStyle, StyleProp } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import { gradients, palette, radius, shadows, spacing, typography } from '../theme/tokens';

interface Props {
  label: string;
  onPress?: () => void;
  variant?: 'primary' | 'mint' | 'peach' | 'rose';
  style?: StyleProp<ViewStyle>;
  disabled?: boolean;
  size?: 'md' | 'lg';
}

const variantMap = {
  primary: ['#A78BFA', '#EA9AB2', '#FF9E7D'] as const,
  mint: gradients.mint,
  peach: gradients.peach,
  rose: gradients.rose,
};

export function GradientButton({ label, onPress, variant = 'primary', style, disabled, size = 'lg' }: Props) {
  return (
    <Pressable
      onPress={() => {
        if (disabled) return;
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => {});
        onPress?.();
      }}
      style={({ pressed }) => [
        styles.wrap,
        size === 'md' && styles.wrapMd,
        shadows.glow,
        disabled && styles.disabled,
        pressed && styles.pressed,
        style,
      ]}
    >
      <LinearGradient
        colors={variantMap[variant] as any}
        style={StyleSheet.absoluteFill}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />
      <Text style={[styles.label, size === 'md' && styles.labelMd]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  wrap: {
    height: 58,
    borderRadius: radius.pill,
    overflow: 'hidden',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.xxl,
  },
  wrapMd: { height: 44, paddingHorizontal: spacing.xl },
  label: { ...typography.h3, color: palette.white, letterSpacing: 0.2 },
  labelMd: { ...typography.bodyBold, color: palette.white },
  pressed: { transform: [{ scale: 0.97 }], opacity: 0.95 },
  disabled: { opacity: 0.4 },
});
