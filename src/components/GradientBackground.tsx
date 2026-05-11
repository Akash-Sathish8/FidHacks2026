import React from 'react';
import { StyleSheet, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { gradients, palette } from '../theme/tokens';

interface Props {
  children: React.ReactNode;
  variant?: keyof typeof gradients;
}

export function GradientBackground({ children, variant = 'app' }: Props) {
  return (
    <View style={styles.root}>
      <LinearGradient colors={gradients[variant] as any} style={StyleSheet.absoluteFill} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} />
      <View style={styles.blob1} />
      <View style={styles.blob2} />
      <View style={styles.blob3} />
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: palette.cream },
  blob1: {
    position: 'absolute',
    width: 360,
    height: 360,
    borderRadius: 360,
    backgroundColor: palette.lavender,
    opacity: 0.35,
    top: -120,
    right: -120,
  },
  blob2: {
    position: 'absolute',
    width: 320,
    height: 320,
    borderRadius: 320,
    backgroundColor: palette.peach,
    opacity: 0.3,
    bottom: -100,
    left: -100,
  },
  blob3: {
    position: 'absolute',
    width: 240,
    height: 240,
    borderRadius: 240,
    backgroundColor: palette.mint,
    opacity: 0.28,
    top: '40%',
    right: -80,
  },
});
