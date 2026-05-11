import React from 'react';
import { StyleSheet, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { palette, radius } from '../theme/tokens';

interface Props {
  value: number; // 0 - 1
  height?: number;
  colors?: readonly [string, string];
}

export function ProgressBar({ value, height = 10, colors = ['#A78BFA', '#FF9E7D'] }: Props) {
  const clamped = Math.max(0, Math.min(1, value));
  return (
    <View style={[styles.track, { height }]}>
      <View style={{ flex: clamped, height }}>
        <LinearGradient
          colors={colors as any}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={[StyleSheet.absoluteFill, { borderRadius: height / 2 }]}
        />
      </View>
      <View style={{ flex: 1 - clamped }} />
    </View>
  );
}

const styles = StyleSheet.create({
  track: {
    flexDirection: 'row',
    backgroundColor: palette.creamDeep,
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
});
