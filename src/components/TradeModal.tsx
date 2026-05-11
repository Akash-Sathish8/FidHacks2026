import React, { useMemo, useState } from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import Slider from '@react-native-community/slider';
import { GradientButton } from './GradientButton';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { Holding } from '../state/TradeState';

interface Props {
  visible: boolean;
  symbol: string;
  name: string;
  price: number;
  cash: number;
  holding?: Holding;
  onClose: () => void;
  onBuy: (dollars: number) => void;
  onSell: (shares: number) => void;
}

type Side = 'buy' | 'sell';

export function TradeModal({ visible, symbol, name, price, cash, holding, onClose, onBuy, onSell }: Props) {
  const [side, setSide] = useState<Side>('buy');
  const [dollars, setDollars] = useState(0);

  const max = side === 'buy' ? cash : holding ? holding.shares * price : 0;
  const shares = price > 0 ? dollars / price : 0;

  // reset when modal opens
  React.useEffect(() => {
    if (visible) {
      setSide(holding ? 'buy' : 'buy');
      setDollars(0);
    }
  }, [visible]);

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <View style={[styles.sheet, shadows.glow]}>
        <View style={styles.handle} />

        <View style={styles.header}>
          <Text style={styles.sym}>{symbol}</Text>
          <Text style={styles.name}>{name}</Text>
          <Text style={styles.price}>${price.toFixed(2)} / share</Text>
        </View>

        <View style={styles.toggleRow}>
          <Pressable
            style={[styles.toggle, side === 'buy' && styles.toggleActive]}
            onPress={() => {
              setSide('buy');
              setDollars(0);
            }}
          >
            <Text style={[styles.toggleText, side === 'buy' && styles.toggleTextActive]}>BUY</Text>
          </Pressable>
          <Pressable
            style={[styles.toggle, side === 'sell' && styles.toggleActive, !holding && styles.toggleDisabled]}
            onPress={() => {
              if (!holding) return;
              setSide('sell');
              setDollars(0);
            }}
          >
            <Text style={[styles.toggleText, side === 'sell' && styles.toggleTextActive]}>SELL</Text>
          </Pressable>
        </View>

        <View style={styles.bigAmountWrap}>
          <Text style={styles.bigAmount}>${dollars.toFixed(0)}</Text>
          <Text style={styles.shares}>≈ {shares.toFixed(2)} shares</Text>
        </View>

        <Slider
          minimumValue={0}
          maximumValue={max}
          step={1}
          value={dollars}
          onValueChange={setDollars}
          minimumTrackTintColor={side === 'buy' ? palette.mintDeep : palette.peachDeep}
          maximumTrackTintColor={palette.creamDeep}
          thumbTintColor={palette.ink}
          style={{ marginTop: spacing.md }}
        />
        <View style={styles.rangeRow}>
          <Pressable onPress={() => setDollars(0)}><Text style={styles.rangeText}>$0</Text></Pressable>
          <Pressable onPress={() => setDollars(max * 0.25)}><Text style={styles.rangeText}>25%</Text></Pressable>
          <Pressable onPress={() => setDollars(max * 0.5)}><Text style={styles.rangeText}>50%</Text></Pressable>
          <Pressable onPress={() => setDollars(max)}><Text style={styles.rangeText}>max</Text></Pressable>
        </View>

        <View style={styles.summary}>
          <Text style={styles.summaryLabel}>{side === 'buy' ? 'cash' : 'position'}</Text>
          <Text style={styles.summaryValue}>
            ${side === 'buy' ? cash.toFixed(0) : (holding?.shares ?? 0).toFixed(2)} {side === 'sell' ? 'sh' : ''}
          </Text>
        </View>

        <GradientButton
          label={side === 'buy' ? `Buy $${dollars.toFixed(0)}` : `Sell ${shares.toFixed(2)} sh`}
          variant={side === 'buy' ? 'mint' : 'peach'}
          disabled={dollars <= 0 || dollars > max}
          onPress={() => {
            if (side === 'buy') onBuy(dollars);
            else onSell(shares);
            onClose();
          }}
          style={{ marginTop: spacing.xl }}
        />
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(26,23,38,0.4)' },
  sheet: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: palette.cream,
    borderTopLeftRadius: 32,
    borderTopRightRadius: 32,
    padding: spacing.xl,
    paddingBottom: spacing.xxxl,
    gap: spacing.md,
  },
  handle: { alignSelf: 'center', width: 48, height: 5, borderRadius: 3, backgroundColor: palette.creamDeep, marginBottom: spacing.md },
  header: { gap: 2 },
  sym: { ...typography.h1, color: palette.ink },
  name: { ...typography.caption, color: palette.inkMuted },
  price: { ...typography.h3, color: palette.inkSoft, marginTop: 4 },
  toggleRow: { flexDirection: 'row', gap: spacing.sm, marginTop: spacing.lg },
  toggle: { flex: 1, paddingVertical: spacing.md, borderRadius: radius.pill, backgroundColor: palette.creamDeep, alignItems: 'center' },
  toggleActive: { backgroundColor: palette.ink },
  toggleDisabled: { opacity: 0.4 },
  toggleText: { ...typography.label, color: palette.inkSoft },
  toggleTextActive: { color: palette.cream },
  bigAmountWrap: { alignItems: 'center', marginTop: spacing.lg },
  bigAmount: { ...typography.display, color: palette.ink },
  shares: { ...typography.caption, color: palette.inkMuted, marginTop: 4 },
  rangeRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 4 },
  rangeText: { ...typography.caption, color: palette.inkMuted, fontWeight: '700', padding: 4 },
  summary: { flexDirection: 'row', justifyContent: 'space-between', marginTop: spacing.lg, paddingHorizontal: spacing.sm },
  summaryLabel: { ...typography.label, color: palette.inkMuted },
  summaryValue: { ...typography.bodyBold, color: palette.ink },
});
