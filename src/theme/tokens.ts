export const palette = {
  cream: '#FDFBF7',
  creamDeep: '#F4EFE6',
  ink: '#1A1726',
  inkSoft: '#4A4459',
  inkMuted: '#8B8499',
  white: '#FFFFFF',

  lavender: '#C4B5FD',
  lavenderDeep: '#A78BFA',
  lavenderSoft: '#EDE9FE',

  peach: '#FFD4B8',
  peachDeep: '#FF9E7D',
  peachSoft: '#FFF1E6',

  mint: '#B5E8D5',
  mintDeep: '#6FE3B3',
  mintSoft: '#E6FAF1',

  rose: '#F9C5D1',
  roseDeep: '#EA9AB2',
  roseSoft: '#FDECF1',

  sky: '#BEE3F8',
  skyDeep: '#7BC4F0',
  skySoft: '#E6F4FC',

  shadow: 'rgba(26, 23, 38, 0.08)',
  shadowDeep: 'rgba(26, 23, 38, 0.16)',
  glass: 'rgba(255, 255, 255, 0.55)',
  glassBorder: 'rgba(255, 255, 255, 0.7)',
};

export const gradients = {
  hero: [palette.lavender, palette.rose, palette.peach] as const,
  mint: [palette.mintSoft, palette.mint] as const,
  peach: [palette.peachSoft, palette.peach] as const,
  lavender: [palette.lavenderSoft, palette.lavender] as const,
  rose: [palette.roseSoft, palette.rose] as const,
  sky: [palette.skySoft, palette.sky] as const,
  app: [palette.cream, '#F6EEF8', '#EEF1FA'] as const,
  buddy: ['#FFE5D4', '#E0D4FF', '#D4F0E5'] as const,
};

export const radius = {
  sm: 12,
  md: 18,
  lg: 24,
  xl: 32,
  pill: 999,
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 48,
};

export const typography = {
  display: { fontSize: 40, fontWeight: '700' as const, letterSpacing: -1.2, lineHeight: 44 },
  h1: { fontSize: 30, fontWeight: '700' as const, letterSpacing: -0.6, lineHeight: 36 },
  h2: { fontSize: 22, fontWeight: '700' as const, letterSpacing: -0.3, lineHeight: 28 },
  h3: { fontSize: 18, fontWeight: '600' as const, letterSpacing: -0.2, lineHeight: 24 },
  body: { fontSize: 15, fontWeight: '400' as const, lineHeight: 22 },
  bodyBold: { fontSize: 15, fontWeight: '600' as const, lineHeight: 22 },
  caption: { fontSize: 12, fontWeight: '500' as const, letterSpacing: 0.4, lineHeight: 16 },
  label: { fontSize: 11, fontWeight: '700' as const, letterSpacing: 1.2, lineHeight: 14, textTransform: 'uppercase' as const },
};

export const shadows = {
  soft: {
    shadowColor: palette.ink,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.06,
    shadowRadius: 24,
    elevation: 4,
  },
  card: {
    shadowColor: palette.ink,
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.08,
    shadowRadius: 32,
    elevation: 6,
  },
  glow: {
    shadowColor: palette.lavenderDeep,
    shadowOffset: { width: 0, height: 16 },
    shadowOpacity: 0.25,
    shadowRadius: 36,
    elevation: 10,
  },
};
