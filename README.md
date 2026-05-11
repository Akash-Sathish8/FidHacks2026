# Money Moves

An iOS-first money confidence app for first-year college women. Built for FidHacks 2026.

> Make your first money moves. A pocket coach for the moves that compound — your first paycheck, your first negotiation, your first invested dollar.

## What it is

A reimagining of the BudQuest concept (Tamagotchi + budgeting) that ties **money habits to career growth**, with:

- **Career Quests** — bite-sized lessons across five pillars: Budget, Invest, Negotiate, Side Hustle, Benefits
- **AI Negotiation Simulator** — role-play a salary negotiation with a Claude-powered "hiring manager" that adapts to your replies and gives a coach note at the end
- **Future Self visualizer** — slide a weekly investment amount and see what compounds at 25, 35, 65
- **Buddy + streak system** — your buddy levels up with you. XP, coins, customization
- **Squad mode** — group challenges with friends, privacy-preserving leaderboard
- **Money screen** — categorized spending with AI-flagged over-budget alerts + investment tracker

Design: **soft neo-futurism** — pastel gradients, frosted glass cards, floating buddy mascot, smooth spring animations.

## Stack

- Expo SDK 54 + React Native + TypeScript
- React Navigation (stack + bottom tabs)
- Reanimated for spring animations
- Expo LinearGradient + BlurView for the glass aesthetic
- Anthropic SDK for Claude Sonnet 4.6 — powering the lesson generator and negotiation simulator

## Running it

You don't need a Mac. Develop on Windows/Linux and run on your iPhone via Expo Go.

```bash
npm install
cp .env.example .env
# Add your ANTHROPIC API key — get one at console.anthropic.com
# Edit .env and set EXPO_PUBLIC_ANTHROPIC_API_KEY=sk-ant-...
npm start
```

Then either:
- Press `i` in the terminal to open the iOS simulator (Mac only), or
- Install **Expo Go** on your iPhone, scan the QR code, and run it on your device

Without the API key, the AI features fall back to scripted demo responses so the app still runs.

## Project structure

```
src/
  components/    Buddy, GlassCard, GradientButton, ProgressBar, Chip
  data/          Quest catalog, spending seed data, squad members, shop items
  lib/           Claude SDK wrapper with offline mock
  navigation/    Stack + bottom tabs (Home / Quests / Money / Squad / Buddy)
  screens/       11 screens (onboarding flow + tabs + modal flows)
  state/         AppProvider context with coins/XP/quests/accessories
  theme/         Design tokens (palette, gradients, type, radius, shadow)
```

## How this answers the prompt

The hackathon brief asked for tech that helps first-year college women:
1. **Understand & grow money** — budget, invest, negotiate, side hustle, benefits → mapped 1:1 to five quest pillars
2. **Use tech** (apps, AI, games) → AI-powered negotiation role-play, gamified quests, buddy XP
3. **Feel relevant, empowering, accessible** → soft-futuristic design that's not finance-bro, AI in the user's voice, no bank-account linking required to start

The differentiator vs. typical budgeting apps: it connects today's money decisions to **future career outcomes** through the Future Self visualizer and Career Quests, not just spend-tracking.
