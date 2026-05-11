import React, { createContext, useContext, useMemo, useState } from 'react';
import { BuddyKind } from '../components/Buddy';
import type { Mode } from './TradeState';

export type Accessory = 'crown' | 'glasses' | 'headphones' | 'flower' | 'cap' | 'sparkle' | null;

export interface TradeBest {
  finalReturn: number;
  date: string;
  diversifierBadge: boolean;
}

export interface UserState {
  username: string;
  buddyKind: BuddyKind;
  buddyName: string;
  accessory: Accessory;
  coins: number;
  xp: number;
  level: number;
  streak: number;
  completedQuests: string[];
  unlockedAccessories: Accessory[];
  owned: string[];
  tradeBests?: Partial<Record<Mode, TradeBest>>;
  tradeStreak?: number;
}

const defaultUser: UserState = {
  username: 'chels',
  buddyKind: 'panda',
  buddyName: 'Mochi',
  accessory: 'sparkle',
  coins: 1240,
  xp: 320,
  level: 4,
  streak: 12,
  completedQuests: ['budget-set-up'],
  unlockedAccessories: ['sparkle'],
  owned: [],
  tradeBests: {},
  tradeStreak: 0,
};

interface Ctx {
  user: UserState;
  setUser: React.Dispatch<React.SetStateAction<UserState>>;
  addCoins: (n: number) => void;
  addXP: (n: number) => void;
  completeQuest: (id: string, reward: { coins: number; xp: number }) => void;
  equipAccessory: (a: Accessory) => void;
  buyAccessory: (a: Accessory, cost: number) => boolean;
}

const AppContext = createContext<Ctx | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserState>(defaultUser);

  const value = useMemo<Ctx>(
    () => ({
      user,
      setUser,
      addCoins: (n) => setUser((u) => ({ ...u, coins: Math.max(0, u.coins + n) })),
      addXP: (n) =>
        setUser((u) => {
          const xp = u.xp + n;
          const level = Math.floor(xp / 500) + 1;
          return { ...u, xp, level };
        }),
      completeQuest: (id, reward) =>
        setUser((u) =>
          u.completedQuests.includes(id)
            ? u
            : {
                ...u,
                completedQuests: [...u.completedQuests, id],
                coins: u.coins + reward.coins,
                xp: u.xp + reward.xp,
              }
        ),
      equipAccessory: (a) => setUser((u) => ({ ...u, accessory: a })),
      buyAccessory: (a, cost) => {
        if (!a) return false;
        let bought = false;
        setUser((u) => {
          if (u.coins < cost) return u;
          if (u.unlockedAccessories.includes(a)) return u;
          bought = true;
          return {
            ...u,
            coins: u.coins - cost,
            unlockedAccessories: [...u.unlockedAccessories, a],
            accessory: a,
          };
        });
        return bought;
      },
    }),
    [user]
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used inside AppProvider');
  return ctx;
}
