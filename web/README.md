# Paper Trader — drop-in HTML/CSS/JS mini-game

A self-contained paper trading game. Rewind real market history, compress 6mo / 1yr / 10yr into 45s / 90s / 3min, try to beat a diversified ETF baseline. End-of-round reveal scores your portfolio against VTI buy-and-hold and the best single stock.

No framework, no build step, no bundler. Three files:

```
trader.css     # styles (all classes prefixed .pt-)
trader.js      # game logic + DOM rendering
data.js        # bundled price data — 10y of OHLC for 8 tickers (~170KB)
```

## Files in this folder

| File | Purpose |
|---|---|
| `index.html` | Standalone demo — open it directly or serve it |
| `trader.css` | All game styles. Soft neo-futurism palette. |
| `trader.js` | Game logic, DOM rendering. Defines `window.PaperTrader`. |
| `data.js` | Pre-fetched market data. Defines `window.PAPER_TRADER_DATA`. |

## Plug into your host HTML/CSS app

```html
<!-- in your <head> -->
<link rel="stylesheet" href="path/to/trader.css" />

<!-- anywhere you want the game to live -->
<div id="trader-mount" style="min-height: 100vh;"></div>

<!-- at end of <body> -->
<script src="path/to/data.js"></script>
<script src="path/to/trader.js"></script>
<script>
  PaperTrader.mount('#trader-mount', {
    onComplete: (summary) => {
      // Called when a run finishes. Wire to your host app's reward system.
      // summary.beatBenchmark  → true if user beat VTI
      // summary.diversifierBadge → true if user held ≥4 distinct assets
      // summary.finalReturn    → e.g. 0.18 = +18%
      // summary.maxConcentration → 0-1 = how much was in one asset at the end
      // summary.assetsTouched   → array of tickers
      // summary.portfolioSeries → array of portfolio value per tick
      // summary.vtiSeries       → VTI baseline series, same length
      // (full shape below)
      myApp.grantCoins(summary.beatBenchmark ? 100 : 0);
      myApp.grantXP(summary.beatBenchmark ? 200 : 50);
      if (summary.diversifierBadge) myApp.grantBadge('diversifier');
    },
  });
</script>
```

That's it. No CSS resets clash because every class is `.pt-` prefixed.

## What the user sees

1. **Lobby:** Enter a starting balance (input, with $100 / $1k / $10k / $100k preset chips — persists in `localStorage`). Pick Sprint / Standard / Epic. Each shows best-ever return.
2. **Game:** Real historical prices tick forward. Tap any asset card to open a buy/sell bottom sheet with a slider. HUD shows portfolio value, cash, positions, animated chart.
3. **Result:** Three-way comparison (You / VTI / Best Single Stock) + diversification scorecard + coach note + Play Again button.

## Settings & customization

### Refresh prices

The data is a snapshot. To refresh:

```bash
# In the parent project (FidHacks2026):
npx tsx scripts/fetch-history.ts
# Then regenerate the web bundle:
node --experimental-strip-types -e "
const { marketHistory } = require('./src/data/marketHistory.ts');
require('fs').writeFileSync('web/data.js', 'window.PAPER_TRADER_DATA = ' + JSON.stringify(marketHistory) + ';');
"
```

### Change the asset universe

Edit the `TICKERS` array in `scripts/fetch-history.ts`, rerun, regenerate `data.js`.

### Change durations or default starting cash

In `trader.js`:

```js
const MODES = { ... };                  // edit ticks/tickMs/granularity per mode
const DEFAULT_STARTING_CASH = 10000;    // initial value of the balance input
const MIN_STARTING_CASH = 1;            // clamp lower bound
const MAX_STARTING_CASH = 100_000_000;  // clamp upper bound
```

The user enters their own balance at runtime; these only set defaults and the valid range.

### Style overrides

Override any of the `:root`-level CSS variables on `.pt-root`:

```css
.pt-root {
  --pt-lavender-deep: #ff00ff;   /* your accent */
  font-family: "Your Font", sans-serif;
}
```

## Summary shape passed to `onComplete`

```ts
{
  mode: 'sprint' | 'standard' | 'epic',
  startDate: string,            // YYYY-MM-DD
  endDate: string,
  startingCash: number,         // the user-input starting balance
  finalValue: number,           // dollars at end of run
  finalReturn: number,          // pct as decimal, e.g. 0.18 = +18%
  vtiReturn: number,            // baseline pct
  bestSingleSymbol: string,
  bestSingleReturn: number,
  maxDrawdown: number,          // 0-1
  assetsTouched: string[],
  maxConcentration: number,     // 0-1
  diversifierBadge: boolean,    // ≥4 assets held
  beatBenchmark: boolean,
  portfolioSeries: number[],    // value at each tick
  vtiSeries: number[],
  durationMs: number,
}
```

## Browser support

Modern Chrome/Safari/Firefox/Edge. Uses CSS `backdrop-filter` for the frosted glass — Safari needs `-webkit-backdrop-filter` (already included). Falls back to solid white where unsupported.

Mobile-first responsive. Tested at 375px width and up.

## License

Yours. Built for FidHacks 2026 / Money Moves. Use it however.
