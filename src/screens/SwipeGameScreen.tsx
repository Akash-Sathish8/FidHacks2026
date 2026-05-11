import React, { useState, useRef, useMemo } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  Pressable,
  Dimensions,
  Modal,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Swiper from 'react-native-deck-swiper';
import Animated, { FadeIn, FadeInDown, FadeOut } from 'react-native-reanimated';
import { BlurView } from 'expo-blur';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { PURCHASE_CARDS, PurchaseCard } from '../data/purchaseCards';
import * as Haptics from 'expo-haptics';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

type GameState = 'input' | 'playing' | 'summary';

export default function SwipeGameScreen() {
  const navigation = useNavigation();
  const [gameState, setGameState] = useState<GameState>('input');
  const [budget, setBudget] = useState('2000');
  const [currentCards, setCurrentCards] = useState<PurchaseCard[]>([]);
  const [purchased, setPurchased] = useState<PurchaseCard[]>([]);
  const [swipedCount, setSwipedCount] = useState(0);
  
  const swiperRef = useRef<Swiper<PurchaseCard>>(null);

  const startGame = () => {
    // Pick 3 random cards
    const shuffled = [...PURCHASE_CARDS].sort(() => 0.5 - Math.random());
    setCurrentCards(shuffled.slice(0, 3));
    setPurchased([]);
    setSwipedCount(0);
    setGameState('playing');
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  };

  const handleSwipeRight = (index: number) => {
    const card = currentCards[index];
    setPurchased((prev) => [...prev, card]);
    setSwipedCount((prev) => prev + 1);
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    if (swipedCount + 1 >= 3) {
      setTimeout(() => setGameState('summary'), 500);
    }
  };

  const handleSwipeLeft = () => {
    setSwipedCount((prev) => prev + 1);
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    if (swipedCount + 1 >= 3) {
      setTimeout(() => setGameState('summary'), 500);
    }
  };

  const totalSpent = purchased.reduce((sum, card) => sum + card.price, 0);
  const remainingBudget = parseInt(budget || '0') - totalSpent;
  const wants = purchased.filter((c) => c.type === 'want');
  const needs = purchased.filter((c) => c.type === 'need');

  return (
    <GradientBackground>
      <View style={styles.container}>
        <Pressable style={styles.closeButton} onPress={() => navigation.goBack()}>
          <Text style={styles.closeButtonText}>✕</Text>
        </Pressable>
        {gameState === 'input' && (
          <Animated.View entering={FadeInDown} style={styles.inputCard}>
            <Text style={styles.title}>Set Your Budget</Text>
            <Text style={styles.subtitle}>How much do you have for this month's simulation?</Text>
            
            <View style={styles.inputContainer}>
              <Text style={styles.currencySymbol}>$</Text>
              <TextInput
                style={styles.textInput}
                value={budget}
                onChangeText={setBudget}
                keyboardType="numeric"
                placeholder="2000"
                placeholderTextColor={palette.inkMuted}
                autoFocus
              />
            </View>

            <Pressable style={styles.startButton} onPress={startGame}>
              <Text style={styles.startButtonText}>Start Simulation</Text>
            </Pressable>
          </Animated.View>
        )}

        {gameState === 'playing' && currentCards.length > 0 && (
          <View style={styles.swiperContainer}>
            <View style={styles.statsHeader}>
              <View>
                <Text style={styles.statLabel}>Budget Left</Text>
                <Text style={styles.statValue}>${parseInt(budget || '0') - purchased.reduce((s, c) => s + c.price, 0)}</Text>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={styles.statLabel}>Items</Text>
                <Text style={styles.statValue}>{swipedCount}/3</Text>
              </View>
            </View>

            <Swiper
              ref={swiperRef}
              cards={currentCards}
              renderCard={(card) => (
                <View style={styles.cardWrapper}>
                  <GlassCard style={styles.swipeCard}>
                    <Text style={styles.cardEmoji}>{card.emoji}</Text>
                    <Text style={styles.cardTitle}>{card.title}</Text>
                    <Text style={styles.cardPrice}>${card.price}</Text>
                    <View style={styles.swipeInstructions}>
                      <Text style={styles.swipeText}>← Skip</Text>
                      <Text style={styles.swipeText}>Buy →</Text>
                    </View>
                  </GlassCard>
                </View>
              )}
              onSwipedLeft={handleSwipeLeft}
              onSwipedRight={handleSwipeRight}
              cardIndex={0}
              backgroundColor={'transparent'}
              stackSize={3}
              verticalSwipe={false}
              overlayLabels={{
                left: {
                  title: 'SKIP',
                  style: {
                    label: {
                      backgroundColor: palette.roseDeep,
                      borderColor: palette.roseDeep,
                      color: 'white',
                      borderWidth: 1
                    },
                    wrapper: {
                      flexDirection: 'column',
                      alignItems: 'flex-end',
                      justifyContent: 'flex-start',
                      marginTop: 30,
                      marginLeft: -30
                    }
                  }
                },
                right: {
                  title: 'BUY',
                  style: {
                    label: {
                      backgroundColor: palette.mintDeep,
                      borderColor: palette.mintDeep,
                      color: 'white',
                      borderWidth: 1
                    },
                    wrapper: {
                      flexDirection: 'column',
                      alignItems: 'flex-start',
                      justifyContent: 'flex-start',
                      marginTop: 30,
                      marginLeft: 30
                    }
                  }
                }
              }}
            />
          </View>
        )}

        <Modal visible={gameState === 'summary'} transparent animationType="fade">
          <BlurView intensity={60} tint="dark" style={StyleSheet.absoluteFill}>
            <View style={styles.modalContent}>
              <Animated.View entering={FadeInDown.springify()} style={styles.summaryCard}>
                <Text style={styles.summaryTitle}>Game Over!</Text>
                
                <View style={styles.summaryStats}>
                  <Text style={styles.summaryText}>
                    You bought <Text style={styles.highlight}>{purchased.length}</Text> things.
                  </Text>
                  <Text style={styles.summaryText}>
                    <Text style={styles.highlight}>{wants.length}</Text> were wants.
                  </Text>
                  <Text style={styles.summaryText}>
                    <Text style={styles.highlight}>{needs.length}</Text> were needs.
                  </Text>
                  
                  <View style={styles.divider} />
                  
                  <Text style={styles.summaryText}>Total Spent: <Text style={styles.highlight}>${totalSpent}</Text></Text>
                  <Text style={styles.summaryText}>
                    Remaining: <Text style={[styles.highlight, remainingBudget < 0 && { color: palette.roseDeep }]}>
                      ${remainingBudget}
                    </Text>
                  </Text>
                  
                  {remainingBudget < 400 && (
                    <Text style={styles.warningText}>
                      ⚠️ Careful! You'd have less than $400 left for rent.
                    </Text>
                  )}
                </View>

                <Pressable style={styles.restartButton} onPress={() => setGameState('input')}>
                  <Text style={styles.restartButtonText}>Play Again</Text>
                </Pressable>
              </Animated.View>
            </View>
          </BlurView>
        </Modal>
      </View>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingHorizontal: spacing.xl, paddingTop: 100 },
  inputCard: {
    backgroundColor: palette.white,
    padding: spacing.xl,
    borderRadius: radius.xl,
    ...shadows.card,
  },
  title: { ...typography.h1, color: palette.ink, textAlign: 'center' },
  subtitle: { ...typography.body, color: palette.inkSoft, textAlign: 'center', marginTop: 8 },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: spacing.xxl,
    borderBottomWidth: 2,
    borderBottomColor: palette.lavender,
    paddingBottom: spacing.sm,
  },
  currencySymbol: { ...typography.display, color: palette.lavenderDeep },
  textInput: {
    ...typography.display,
    color: palette.ink,
    minWidth: 100,
    textAlign: 'center',
  },
  startButton: {
    backgroundColor: palette.ink,
    paddingVertical: spacing.lg,
    borderRadius: radius.pill,
    alignItems: 'center',
  },
  startButtonText: { ...typography.bodyBold, color: palette.white },
  swiperContainer: { flex: 1, marginTop: -40 },
  statsHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.sm,
    marginBottom: spacing.xxl,
  },
  statLabel: { ...typography.label, color: palette.inkMuted },
  statValue: { ...typography.h2, color: palette.ink },
  cardWrapper: {
    height: 450,
    justifyContent: 'center',
  },
  swipeCard: {
    height: 400,
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
  },
  cardEmoji: { fontSize: 80, marginBottom: spacing.xl },
  cardTitle: { ...typography.h1, color: palette.ink, textAlign: 'center' },
  cardPrice: { ...typography.display, color: palette.lavenderDeep, marginTop: spacing.md },
  swipeInstructions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    marginTop: spacing.xxxl,
  },
  swipeText: { ...typography.caption, color: palette.inkMuted, fontWeight: '700' },
  modalContent: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: spacing.xl },
  summaryCard: {
    backgroundColor: palette.white,
    width: '100%',
    padding: spacing.xxl,
    borderRadius: radius.xl,
    ...shadows.glow,
  },
  summaryTitle: { ...typography.h1, color: palette.ink, textAlign: 'center', marginBottom: spacing.xl },
  summaryStats: { gap: spacing.md, marginBottom: spacing.xxl },
  summaryText: { ...typography.h3, color: palette.inkSoft },
  highlight: { color: palette.ink, fontWeight: '700' },
  divider: { height: 1, backgroundColor: palette.creamDeep, marginVertical: spacing.md },
  warningText: { ...typography.bodyBold, color: palette.roseDeep, marginTop: spacing.md, textAlign: 'center' },
  restartButton: {
    backgroundColor: palette.lavenderDeep,
    paddingVertical: spacing.lg,
    borderRadius: radius.pill,
    alignItems: 'center',
  },
  restartButtonText: { ...typography.bodyBold, color: palette.white },
  closeButton: {
    position: 'absolute',
    top: 50,
    right: 20,
    zIndex: 10,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: palette.glass,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: palette.glassBorder,
  },
  closeButtonText: { fontSize: 20, color: palette.ink },
});
