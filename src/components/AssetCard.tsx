import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { MiniChart } from './MiniChart';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { Holding } from '../state/TradeState';

interface Props {
  symbol: string;
  name: string;
  flavor: string;
  price: number;
  series: number[];
  holding?: Holding;
  onPress: () => void;
}

export function AssetCard({ symbol, name, price, series, holding, onPress }: Props) {
  const prev = series.length >= 2 ? series[series.length - 2] : price;
  const dayChange = prev > 0 ? (price - prev) / prev : 0;
  const positionValue = holding ? holding.shares * price : 0;
  const positionPnl = holding ? (price - holding.avgCost) * holding.shares : 0;

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [styles.wrap, pressed && { transform: [{ scale: 0.98 }] }, shadows.soft]}
    >
      <View style={styles.left}>
        <View style={styles.row}>
          <Text style={styles.sym}>{symbol}</Text>
          <Text style={[styles.delta, { color: dayChange >= 0 ? palette.mintDeep : palette.peachDeep }]}>
            {dayChange >= 0 ? '+' : ''}
            {(dayChange * 100).toFixed(1)}%
          </Text>
        </View>
        <Text style={styles.name} numberOfLines={1}>{name}</Text>
        <Text style={styles.price}>${price.toFixed(2)}</Text>
        {holding && (
          <Text style={styles.position}>
            {holding.shares.toFixed(2)} sh • ${positionValue.toFixed(0)} {positionPnl >= 0 ? '↑' : '↓'} ${Math.abs(positionPnl).toFixed(0)}
          </Text>
        )}
      </View>
      <View style={styles.right}>
        <MiniChart values={series} width={70} height={36} />
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: 'row',
    padding: spacing.md,
    borderRadius: radius.lg,
    backgroundColor: palette.glass,
    borderWidth: 1,
    borderColor: palette.glassBorder,
    alignItems: 'center',
    gap: spacing.md,
    minHeight: 86,
  },
  left: { flex: 1, gap: 2 },
  right: { width: 70, alignItems: 'flex-end' },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  sym: { ...typography.h3, color: palette.ink },
  delta: { ...typography.caption, fontWeight: '700' },
  name: { ...typography.caption, color: palette.inkMuted },
  price: { ...typography.bodyBold, color: palette.ink, marginTop: 2 },
  position: { ...typography.caption, color: palette.lavenderDeep, marginTop: 2 },
});
