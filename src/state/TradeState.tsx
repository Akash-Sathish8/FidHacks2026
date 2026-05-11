import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { marketHistory, PricePoint, TickerSeries } from '../data/marketHistory';

export type Mode = 'sprint' | 'standard' | 'epic';
export type Ticker = string;

export const MODE_META: Record<Mode, { label: string; span: string; ticks: number; tickMs: number; granularity: 'weekly' | 'monthly'; emoji: string; description: string }> = {
  sprint: { label: 'Sprint', span: '6 months', ticks: 26, tickMs: 1700, granularity: 'weekly', emoji: '⚡', description: '6 months in ~45 seconds. Quick reflexes.' },
  standard: { label: 'Standard', span: '1 year', ticks: 52, tickMs: 1700, granularity: 'weekly', emoji: '☀', description: '1 year in ~90 seconds. Read the trend.' },
  epic: { label: 'Epic', span: '10 years', ticks: 120, tickMs: 1500, granularity: 'monthly', emoji: '✦', description: '10 years in ~3 minutes. Crashes, booms, the works.' },
};

export const STARTING_CASH = 10000;

export interface Holding {
  shares: number;
  avgCost: number;
}

export interface RunSummary {
  mode: Mode;
  startDate: string;
  endDate: string;
  finalValue: number;
  finalReturn: number; // pct e.g. 0.18 = +18%
  vtiReturn: number;
  bestSingleSymbol: string;
  bestSingleReturn: number;
  maxDrawdown: number;
  assetsTouched: string[];
  maxConcentration: number; // 0-1
  diversifierBadge: boolean;
  beatBenchmark: boolean;
  portfolioSeries: number[];
  vtiSeries: number[];
  durationMs: number;
}

interface ActiveGame {
  mode: Mode;
  granularity: 'weekly' | 'monthly';
  startIdx: number;
  ticks: TickSnapshot[];   // pre-sliced data for this run
  currentTick: number;
  isPaused: boolean;
  cash: number;
  holdings: Record<Ticker, Holding>;
  portfolioHistory: number[];
  assetsTouched: Set<Ticker>;
  maxValueSoFar: number;
  maxDrawdown: number;
  startedAt: number;
}

export interface TickSnapshot {
  date: string;
  prices: Record<Ticker, number>;
}

interface Ctx {
  game: ActiveGame | null;
  startRun: (mode: Mode) => void;
  pauseRun: () => void;
  resumeRun: () => void;
  buy: (ticker: Ticker, dollars: number) => void;
  sell: (ticker: Ticker, shares: number) => void;
  abandon: () => void;
  finalizeRun: () => RunSummary | null;
  universe: TickerSeries[];
}

const TradeContext = createContext<Ctx | null>(null);

function sliceRun(mode: Mode): { startIdx: number; ticks: TickSnapshot[]; granularity: 'weekly' | 'monthly' } {
  const meta = MODE_META[mode];
  const granularity = meta.granularity;
  // We want every asset to have data for the chosen window.
  // Find the smallest length across the universe at this granularity.
  const lengths = marketHistory.map((s) => (granularity === 'weekly' ? s.weekly.length : s.monthly.length));
  const minLen = Math.min(...lengths);
  const ticksNeeded = meta.ticks;
  const maxStart = minLen - ticksNeeded - 1;
  if (maxStart < 0) {
    throw new Error(`not enough data for mode ${mode}; need ${ticksNeeded}, have ${minLen}`);
  }
  // The earliest tickers (COIN) IPO'd in 2021. So weekly start range is from when COIN had ≥ticksNeeded entries onward.
  const startIdx = Math.floor(Math.random() * (maxStart + 1));
  const ticks: TickSnapshot[] = [];
  for (let i = 0; i < ticksNeeded; i++) {
    const idx = startIdx + i;
    const prices: Record<Ticker, number> = {};
    for (const series of marketHistory) {
      const arr = granularity === 'weekly' ? series.weekly : series.monthly;
      // Offset arr to match — different tickers may have different start dates.
      // We anchor to the shortest series, so use its date as the reference.
      const refSeries = marketHistory.reduce((a, b) => {
        const aLen = granularity === 'weekly' ? a.weekly.length : a.monthly.length;
        const bLen = granularity === 'weekly' ? b.weekly.length : b.monthly.length;
        return aLen < bLen ? a : b;
      });
      const refArr = granularity === 'weekly' ? refSeries.weekly : refSeries.monthly;
      const refDate = refArr[idx]?.date;
      if (!refDate) continue;
      // find closest date in arr (linear search, dataset is small)
      let nearest: PricePoint | null = null;
      for (let j = arr.length - 1; j >= 0; j--) {
        if (arr[j].date <= refDate) {
          nearest = arr[j];
          break;
        }
      }
      prices[series.symbol] = nearest?.close ?? arr[0]?.close ?? 0;
    }
    const refSeries = marketHistory.reduce((a, b) => {
      const aLen = granularity === 'weekly' ? a.weekly.length : a.monthly.length;
      const bLen = granularity === 'weekly' ? b.weekly.length : b.monthly.length;
      return aLen < bLen ? a : b;
    });
    const refArr = granularity === 'weekly' ? refSeries.weekly : refSeries.monthly;
    ticks.push({ date: refArr[idx].date, prices });
  }
  return { startIdx, ticks, granularity };
}

function computeValue(game: ActiveGame): number {
  const prices = game.ticks[game.currentTick].prices;
  let value = game.cash;
  for (const [t, h] of Object.entries(game.holdings)) {
    value += (prices[t] ?? 0) * h.shares;
  }
  return value;
}

export function TradeProvider({ children }: { children: React.ReactNode }) {
  const [game, setGame] = useState<ActiveGame | null>(null);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const clearTick = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  };

  const startRun = useCallback((mode: Mode) => {
    clearTick();
    const { startIdx, ticks, granularity } = sliceRun(mode);
    const initial: ActiveGame = {
      mode,
      granularity,
      startIdx,
      ticks,
      currentTick: 0,
      isPaused: false,
      cash: STARTING_CASH,
      holdings: {},
      portfolioHistory: [STARTING_CASH],
      assetsTouched: new Set(),
      maxValueSoFar: STARTING_CASH,
      maxDrawdown: 0,
      startedAt: Date.now(),
    };
    setGame(initial);
  }, []);

  useEffect(() => {
    clearTick();
    if (!game || game.isPaused) return;
    if (game.currentTick >= game.ticks.length - 1) return;
    const tickMs = MODE_META[game.mode].tickMs;
    intervalRef.current = setInterval(() => {
      setGame((g) => {
        if (!g) return g;
        if (g.isPaused) return g;
        if (g.currentTick >= g.ticks.length - 1) return g;
        const nextTick = g.currentTick + 1;
        const nextSnap = g.ticks[nextTick];
        let value = g.cash;
        for (const [t, h] of Object.entries(g.holdings)) {
          value += (nextSnap.prices[t] ?? 0) * h.shares;
        }
        const maxValue = Math.max(g.maxValueSoFar, value);
        const drawdown = maxValue > 0 ? (maxValue - value) / maxValue : 0;
        return {
          ...g,
          currentTick: nextTick,
          portfolioHistory: [...g.portfolioHistory, value],
          maxValueSoFar: maxValue,
          maxDrawdown: Math.max(g.maxDrawdown, drawdown),
        };
      });
    }, tickMs);
    return clearTick;
  }, [game?.mode, game?.isPaused, game?.currentTick]);

  const pauseRun = useCallback(() => setGame((g) => (g ? { ...g, isPaused: true } : g)), []);
  const resumeRun = useCallback(() => setGame((g) => (g ? { ...g, isPaused: false } : g)), []);

  const buy = useCallback((ticker: Ticker, dollars: number) => {
    setGame((g) => {
      if (!g) return g;
      const price = g.ticks[g.currentTick].prices[ticker];
      if (!price || price <= 0) return g;
      const spend = Math.min(dollars, g.cash);
      const shares = spend / price;
      if (shares <= 0) return g;
      const existing = g.holdings[ticker] ?? { shares: 0, avgCost: 0 };
      const newShares = existing.shares + shares;
      const newAvg = (existing.avgCost * existing.shares + price * shares) / newShares;
      const nextTouched = new Set(g.assetsTouched);
      nextTouched.add(ticker);
      return {
        ...g,
        cash: g.cash - spend,
        holdings: { ...g.holdings, [ticker]: { shares: newShares, avgCost: newAvg } },
        assetsTouched: nextTouched,
      };
    });
  }, []);

  const sell = useCallback((ticker: Ticker, shares: number) => {
    setGame((g) => {
      if (!g) return g;
      const price = g.ticks[g.currentTick].prices[ticker];
      const existing = g.holdings[ticker];
      if (!existing || !price) return g;
      const sellShares = Math.min(shares, existing.shares);
      if (sellShares <= 0) return g;
      const newShares = existing.shares - sellShares;
      const newHoldings = { ...g.holdings };
      if (newShares < 0.0001) delete newHoldings[ticker];
      else newHoldings[ticker] = { shares: newShares, avgCost: existing.avgCost };
      return {
        ...g,
        cash: g.cash + sellShares * price,
        holdings: newHoldings,
      };
    });
  }, []);

  const abandon = useCallback(() => {
    clearTick();
    setGame(null);
  }, []);

  const finalizeRun = useCallback((): RunSummary | null => {
    clearTick();
    if (!game) return null;
    const lastTick = game.ticks[game.ticks.length - 1];
    let final = game.cash;
    const concentrations: number[] = [];
    for (const [t, h] of Object.entries(game.holdings)) {
      final += (lastTick.prices[t] ?? 0) * h.shares;
    }
    for (const [t, h] of Object.entries(game.holdings)) {
      const value = (lastTick.prices[t] ?? 0) * h.shares;
      concentrations.push(final > 0 ? value / final : 0);
    }
    const maxConcentration = concentrations.length ? Math.max(...concentrations) : 0;

    // Baselines: VTI buy & hold + best single stock.
    const firstTick = game.ticks[0];
    const vtiStart = firstTick.prices['VTI'];
    const vtiEnd = lastTick.prices['VTI'];
    const vtiReturn = vtiStart > 0 ? (vtiEnd - vtiStart) / vtiStart : 0;
    const vtiSeries = game.ticks.map((t) => (t.prices['VTI'] / vtiStart) * STARTING_CASH);

    let bestSym = 'VTI';
    let bestRet = -Infinity;
    for (const sym of Object.keys(firstTick.prices)) {
      const s = firstTick.prices[sym];
      const e = lastTick.prices[sym];
      if (!s || !e) continue;
      const r = (e - s) / s;
      if (r > bestRet) {
        bestRet = r;
        bestSym = sym;
      }
    }

    const finalReturn = (final - STARTING_CASH) / STARTING_CASH;
    const beatBenchmark = finalReturn > vtiReturn;
    const diversifierBadge = game.assetsTouched.size >= 4;

    return {
      mode: game.mode,
      startDate: firstTick.date,
      endDate: lastTick.date,
      finalValue: final,
      finalReturn,
      vtiReturn,
      bestSingleSymbol: bestSym,
      bestSingleReturn: bestRet,
      maxDrawdown: game.maxDrawdown,
      assetsTouched: [...game.assetsTouched],
      maxConcentration,
      diversifierBadge,
      beatBenchmark,
      portfolioSeries: game.portfolioHistory,
      vtiSeries,
      durationMs: Date.now() - game.startedAt,
    };
  }, [game]);

  const value = useMemo<Ctx>(
    () => ({ game, startRun, pauseRun, resumeRun, buy, sell, abandon, finalizeRun, universe: marketHistory }),
    [game, startRun, pauseRun, resumeRun, buy, sell, abandon, finalizeRun]
  );

  return <TradeContext.Provider value={value}>{children}</TradeContext.Provider>;
}

export function useTrade() {
  const ctx = useContext(TradeContext);
  if (!ctx) throw new Error('useTrade must be used inside TradeProvider');
  return ctx;
}

export function currentValue(game: ActiveGame | null): number {
  if (!game) return STARTING_CASH;
  return computeValue(game);
}
