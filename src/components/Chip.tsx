import React from 'react';
import { Pressable, Text, StyleSheet, ViewStyle, StyleProp } from 'react-native';
import { palette, radius, spacing, typography } from '../theme/tokens';

interface Props {
  label: string;
  emoji?: string;
  onPress?: () => void;
  active?: boolean;
  style?: StyleProp<ViewStyle>;
}

export function Chip({ label, emoji, onPress, active, style }: Props) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.chip,
        active && styles.active,
        pressed && { opacity: 0.7 },
        style,
      ]}
    >
      {emoji && <Text style={styles.emoji}>{emoji}</Text>}
      <Text style={[styles.label, active && styles.activeLabel]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    backgroundColor: palette.glass,
    borderColor: palette.glassBorder,
    borderWidth: 1,
    borderRadius: radius.pill,
    gap: 6,
  },
  active: {
    backgroundColor: palette.ink,
    borderColor: palette.ink,
  },
  emoji: { fontSize: 14 },
  label: { ...typography.caption, color: palette.inkSoft, letterSpacing: 0.6 },
  activeLabel: { color: palette.white },
});
