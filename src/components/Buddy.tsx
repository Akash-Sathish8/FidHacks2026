import React, { useEffect } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Animated, { useSharedValue, useAnimatedStyle, withRepeat, withTiming, Easing } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { palette, radius, shadows } from '../theme/tokens';

export type BuddyKind = 'panda' | 'dino' | 'koala' | 'bunny' | 'fox';

const emojiMap: Record<BuddyKind, string> = {
  panda: '🐼',
  dino: '🦖',
  koala: '🐨',
  bunny: '🐰',
  fox: '🦊',
};

const auraMap: Record<BuddyKind, readonly [string, string]> = {
  panda: ['#E0D4FF', '#C4B5FD'],
  dino: ['#D4F0E5', '#6FE3B3'],
  koala: ['#E6F4FC', '#7BC4F0'],
  bunny: ['#FDECF1', '#EA9AB2'],
  fox: ['#FFE5D4', '#FF9E7D'],
};

interface Props {
  kind: BuddyKind;
  size?: number;
  floating?: boolean;
  accessory?: string;
}

export function Buddy({ kind, size = 140, floating = true, accessory }: Props) {
  const offset = useSharedValue(0);

  useEffect(() => {
    if (!floating) return;
    offset.value = withRepeat(
      withTiming(1, { duration: 2400, easing: Easing.inOut(Easing.quad) }),
      -1,
      true
    );
  }, [floating]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: -offset.value * 8 }, { scale: 1 + offset.value * 0.02 }],
  }));

  return (
    <Animated.View style={[{ width: size, height: size }, animatedStyle]}>
      <LinearGradient
        colors={auraMap[kind] as any}
        style={[StyleSheet.absoluteFill, { borderRadius: size / 2 }, shadows.glow]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />
      <View style={[styles.inner, { borderRadius: size / 2 }]}>
        <Text style={{ fontSize: size * 0.55 }}>{emojiMap[kind]}</Text>
        {accessory && (
          <Text style={[styles.accessory, { fontSize: size * 0.25 }]}>{accessory}</Text>
        )}
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  inner: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: palette.glass,
    margin: 8,
    borderWidth: 1,
    borderColor: palette.glassBorder,
  },
  accessory: {
    position: 'absolute',
    top: 4,
    transform: [{ translateY: -8 }],
  },
});
