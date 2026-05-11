import React, { useRef, useState } from 'react';
import { KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View, ActivityIndicator } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import Animated, { FadeIn, FadeInUp } from 'react-native-reanimated';
import { GradientBackground } from '../components/GradientBackground';
import { GlassCard } from '../components/GlassCard';
import { GradientButton } from '../components/GradientButton';
import { palette, radius, shadows, spacing, typography } from '../theme/tokens';
import { ChatMessage, sendMessage, isAIConnected } from '../lib/claude';
import { quests } from '../data/seed';
import { useApp } from '../state/AppState';
import { RootStackParamList } from '../navigation';

type Route = RouteProp<RootStackParamList, 'Negotiation'>;

const SYSTEM_PROMPT = `You are playing the role of "Jordan", a friendly but firm hiring manager at a mid-sized tech company, in a coaching simulator for a first-year college woman practicing salary negotiation.

Rules:
- Stay in character as Jordan. Don't break the fourth wall unless the user explicitly asks for coaching.
- Open with a realistic internship/entry offer ($X base, brief benefits) ONLY in your first message, then react naturally to whatever the user says.
- After the user makes 4 exchanges, end with a private "🌱 Coach note" (italicized) of 2-3 sentences naming what they did well and one specific thing to try next time. Then ask if they want to replay.
- Keep replies to 2-3 short paragraphs max. Voice is warm, professional, and just slightly testing — like a real recruiter who's open but watching the budget.
- Never invent or quote real companies, real people, or specific salary surveys. Use plausible round numbers.`;

export default function NegotiationScreen() {
  const navigation = useNavigation<any>();
  const route = useRoute<Route>();
  const { completeQuest, user } = useApp();
  const quest = quests.find((q) => q.id === route.params.questId)!;
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const scrollRef = useRef<ScrollView>(null);
  const completed = user.completedQuests.includes(quest.id);

  async function start() {
    setLoading(true);
    try {
      const text = await sendMessage({
        system: SYSTEM_PROMPT,
        messages: [{ role: 'user', content: '[start the simulation by introducing yourself and presenting the offer]' }],
        maxTokens: 500,
      });
      setMessages([{ role: 'assistant', content: text }]);
    } finally {
      setLoading(false);
    }
  }

  async function send() {
    const userText = input.trim();
    if (!userText) return;
    const next: ChatMessage[] = [...messages, { role: 'user', content: userText }];
    setMessages(next);
    setInput('');
    setLoading(true);
    try {
      const text = await sendMessage({
        system: SYSTEM_PROMPT,
        messages: next,
        maxTokens: 500,
      });
      setMessages([...next, { role: 'assistant', content: text }]);
      setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 80);
    } finally {
      setLoading(false);
    }
  }

  return (
    <GradientBackground>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView ref={scrollRef} contentContainerStyle={styles.root} showsVerticalScrollIndicator={false}>
          <Pressable onPress={() => navigation.goBack()} style={styles.close}>
            <Text style={styles.closeText}>×</Text>
          </Pressable>

          <Animated.View entering={FadeIn.duration(400)}>
            <Text style={styles.eyebrow}>simulator • {quest.pillar}</Text>
            <Text style={styles.title}>{quest.title}</Text>
            <Text style={styles.sub}>
              You're meeting with Jordan, a hiring manager. Try anchoring, counter-offers, and silence. The stakes are zero.
            </Text>
            {!isAIConnected() && (
              <View style={styles.offlineBanner}>
                <Text style={styles.offlineText}>Offline demo mode — set EXPO_PUBLIC_ANTHROPIC_API_KEY in .env for live AI.</Text>
              </View>
            )}
          </Animated.View>

          {messages.length === 0 && !loading && (
            <Animated.View entering={FadeInUp.duration(400)} style={{ alignItems: 'center', marginTop: spacing.xxl }}>
              <GradientButton label="Begin negotiation" onPress={start} />
            </Animated.View>
          )}

          <View style={{ gap: spacing.md, marginTop: spacing.lg }}>
            {messages.map((m, i) => (
              <Animated.View key={i} entering={FadeInUp.duration(300)}>
                {m.role === 'assistant' ? (
                  <View style={styles.botBubble}>
                    <Text style={styles.botName}>Jordan ✦</Text>
                    <Text style={styles.botText}>{m.content}</Text>
                  </View>
                ) : (
                  <View style={styles.userBubble}>
                    <Text style={styles.userText}>{m.content}</Text>
                  </View>
                )}
              </Animated.View>
            ))}
            {loading && (
              <View style={styles.botBubble}>
                <ActivityIndicator color={palette.lavenderDeep} />
              </View>
            )}
          </View>

          {messages.length >= 6 && !completed && (
            <View style={{ alignItems: 'center', marginTop: spacing.xl }}>
              <GradientButton
                variant="mint"
                label={`Claim reward  +${quest.reward.coins}◐`}
                onPress={() => {
                  completeQuest(quest.id, quest.reward);
                }}
              />
            </View>
          )}

          <View style={{ height: 140 }} />
        </ScrollView>

        {messages.length > 0 && (
          <View style={styles.inputDock}>
            <TextInput
              style={styles.input}
              value={input}
              onChangeText={setInput}
              placeholder="Say something to Jordan…"
              placeholderTextColor={palette.inkMuted}
              multiline
            />
            <Pressable style={styles.sendBtn} onPress={send} disabled={loading || !input.trim()}>
              <Text style={styles.sendText}>↑</Text>
            </Pressable>
          </View>
        )}
      </KeyboardAvoidingView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  root: { paddingHorizontal: spacing.xl, paddingTop: 90, paddingBottom: spacing.xxl },
  close: { position: 'absolute', top: 60, right: spacing.xl, width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', backgroundColor: palette.glass, borderWidth: 1, borderColor: palette.glassBorder, zIndex: 10 },
  closeText: { fontSize: 24, color: palette.ink, lineHeight: 26 },
  eyebrow: { ...typography.label, color: palette.lavenderDeep },
  title: { ...typography.h1, color: palette.ink, marginTop: 4 },
  sub: { ...typography.body, color: palette.inkSoft, marginTop: spacing.sm },
  offlineBanner: { marginTop: spacing.md, padding: spacing.md, backgroundColor: palette.peachSoft, borderRadius: radius.md },
  offlineText: { ...typography.caption, color: palette.peachDeep },
  botBubble: {
    backgroundColor: palette.glass,
    borderColor: palette.glassBorder,
    borderWidth: 1,
    borderRadius: radius.lg,
    borderTopLeftRadius: 4,
    padding: spacing.lg,
    alignSelf: 'flex-start',
    maxWidth: '88%',
    ...shadows.soft,
  },
  botName: { ...typography.label, color: palette.lavenderDeep, marginBottom: 4 },
  botText: { ...typography.body, color: palette.ink },
  userBubble: {
    backgroundColor: palette.ink,
    borderRadius: radius.lg,
    borderTopRightRadius: 4,
    padding: spacing.lg,
    alignSelf: 'flex-end',
    maxWidth: '88%',
    ...shadows.soft,
  },
  userText: { ...typography.body, color: palette.cream },
  inputDock: {
    position: 'absolute',
    bottom: 32,
    left: spacing.xl,
    right: spacing.xl,
    flexDirection: 'row',
    gap: 8,
    alignItems: 'flex-end',
    backgroundColor: palette.glass,
    borderColor: palette.glassBorder,
    borderWidth: 1,
    borderRadius: radius.pill,
    paddingLeft: spacing.lg,
    paddingRight: 6,
    paddingVertical: 6,
    ...shadows.card,
  },
  input: { ...typography.body, color: palette.ink, flex: 1, maxHeight: 100, paddingVertical: 10 },
  sendBtn: { width: 44, height: 44, borderRadius: 22, alignItems: 'center', justifyContent: 'center', backgroundColor: palette.ink },
  sendText: { color: palette.white, fontSize: 22, fontWeight: '700', marginTop: -2 },
});
