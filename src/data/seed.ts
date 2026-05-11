export interface Quest {
  id: string;
  title: string;
  pillar: 'budget' | 'invest' | 'negotiate' | 'side-hustle' | 'benefits';
  difficulty: 'starter' | 'core' | 'boss';
  reward: { coins: number; xp: number };
  blurb: string;
  emoji: string;
  duration: string;
  kind: 'lesson' | 'simulator' | 'tracker';
}

export const quests: Quest[] = [
  {
    id: 'first-paycheck',
    title: 'Decode Your First Paycheck',
    pillar: 'budget',
    difficulty: 'starter',
    reward: { coins: 80, xp: 120 },
    blurb: 'Gross vs net, FICA, federal, state — where your money actually goes before it hits your account.',
    emoji: '💸',
    duration: '5 min',
    kind: 'lesson',
  },
  {
    id: 'negotiate-internship',
    title: 'Negotiate Your Internship Offer',
    pillar: 'negotiate',
    difficulty: 'boss',
    reward: { coins: 250, xp: 400 },
    blurb: "Role-play with an AI hiring manager. Practice anchoring, counter-offers, and silence — without the stakes.",
    emoji: '👑',
    duration: '10 min',
    kind: 'simulator',
  },
  {
    id: 'unpack-benefits',
    title: 'Unpack a Benefits Package',
    pillar: 'benefits',
    difficulty: 'core',
    reward: { coins: 180, xp: 280 },
    blurb: "401(k) match, RSUs, healthcare premiums — learn what they're actually worth in dollars.",
    emoji: '🎁',
    duration: '8 min',
    kind: 'lesson',
  },
  {
    id: 'invest-first-100',
    title: 'Invest Your First $100',
    pillar: 'invest',
    difficulty: 'core',
    reward: { coins: 200, xp: 300 },
    blurb: 'ETF, index fund, individual stock — pick a path and simulate one year of compounding.',
    emoji: '📈',
    duration: '12 min',
    kind: 'lesson',
  },
  {
    id: 'side-hustle-launch',
    title: 'Launch a Side Hustle in 7 Days',
    pillar: 'side-hustle',
    difficulty: 'core',
    reward: { coins: 220, xp: 320 },
    blurb: 'From idea to first dollar — pricing, taxes, and how to know if it’s worth your time.',
    emoji: '⚡',
    duration: '7 days',
    kind: 'tracker',
  },
  {
    id: 'ask-for-raise',
    title: 'Ask for a Raise',
    pillar: 'negotiate',
    difficulty: 'boss',
    reward: { coins: 300, xp: 450 },
    blurb: 'Build the case, time it right, and run the conversation. AI plays your boss.',
    emoji: '🔥',
    duration: '15 min',
    kind: 'simulator',
  },
];

export interface SpendingCategory {
  name: string;
  spent: number;
  budget: number;
  color: string;
  emoji: string;
}

export const spending: SpendingCategory[] = [
  { name: 'Food', spent: 410, budget: 350, color: '#FF9E7D', emoji: '🍜' },
  { name: 'Transport', spent: 86, budget: 120, color: '#7BC4F0', emoji: '🚇' },
  { name: 'Fun', spent: 145, budget: 150, color: '#EA9AB2', emoji: '🎟️' },
  { name: 'Subs', spent: 38, budget: 50, color: '#A78BFA', emoji: '🎧' },
  { name: 'Savings', spent: 200, budget: 200, color: '#6FE3B3', emoji: '🪴' },
];

export const stocks = [
  { symbol: 'NVDA', name: 'NVIDIA', delta: '+1.38%', positive: true },
  { symbol: 'AAPL', name: 'Apple', delta: '+0.46%', positive: true },
  { symbol: 'TSLA', name: 'Tesla', delta: '-0.19%', positive: false },
  { symbol: 'VTI', name: 'Vanguard Total', delta: '+0.32%', positive: true },
];

export const squadMembers = [
  { name: 'Maya', emoji: '🌸', level: 6, streak: 21, you: false },
  { name: 'You', emoji: '✨', level: 4, streak: 12, you: true },
  { name: 'Priya', emoji: '🌿', level: 5, streak: 18, you: false },
  { name: 'Zoe', emoji: '🌊', level: 3, streak: 7, you: false },
  { name: 'Lena', emoji: '🍯', level: 4, streak: 9, you: false },
];

export const shopItems: { id: string; label: string; emoji: string; cost: number }[] = [
  { id: 'crown', label: 'Crown', emoji: '👑', cost: 250 },
  { id: 'glasses', label: 'Glasses', emoji: '🕶️', cost: 120 },
  { id: 'headphones', label: 'Headphones', emoji: '🎧', cost: 180 },
  { id: 'flower', label: 'Flower Crown', emoji: '🌸', cost: 200 },
  { id: 'cap', label: 'Cap', emoji: '🧢', cost: 90 },
  { id: 'sparkle', label: 'Sparkle Aura', emoji: '✨', cost: 60 },
];
