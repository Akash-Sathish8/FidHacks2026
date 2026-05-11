/*
 * Paper Trader — drop-in HTML/CSS/JS mini-game
 *
 * Usage:
 *   <link rel="stylesheet" href="trader.css" />
 *   <script src="data.js"></script>     <!-- defines window.PAPER_TRADER_DATA -->
 *   <script src="trader.js"></script>
 *   <div id="trader-mount"></div>
 *   <script>
 *     PaperTrader.mount('#trader-mount', {
 *       onComplete: (summary) => console.log('finished', summary)
 *     });
 *   </script>
 *
 * No external dependencies. No build step. Works in any modern browser.
 */
(function () {
  'use strict';

  if (typeof window === 'undefined') return;

  const MODES = {
    sprint:   { label: 'Sprint',   span: '6 months', ticks: 26,  tickMs: 1700, granularity: 'weekly',  emoji: '⚡', description: '6 months in ~45 seconds. Quick reflexes.' },
    standard: { label: 'Standard', span: '1 year',   ticks: 52,  tickMs: 1700, granularity: 'weekly',  emoji: '☀', description: '1 year in ~90 seconds. Read the trend.' },
    epic:     { label: 'Epic',     span: '10 years', ticks: 120, tickMs: 1500, granularity: 'monthly', emoji: '✦', description: '10 years in ~3 minutes. Crashes, booms, the works.' },
  };

  const DEFAULT_STARTING_CASH = 10000;
  const MIN_STARTING_CASH = 1;
  const MAX_STARTING_CASH = 100_000_000;
  const PREROLL = 5;            // hidden "warm-up" ticks before play starts so sparklines look populated
  const FIRST_TICK_DELAY = 600; // ms before first real tick fires (subsequent ticks use MODES[m].tickMs)
  const STORAGE_KEY = 'paper-trader.bests.v1';
  const BALANCE_KEY = 'paper-trader.balance.v1';

  // -------------------- Data slicing --------------------

  function readBests() {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}'); }
    catch (e) { return {}; }
  }
  function writeBests(bests) {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(bests)); } catch (e) {}
  }

  function sliceRun(mode) {
    const history = window.PAPER_TRADER_DATA;
    if (!history) throw new Error('PAPER_TRADER_DATA not loaded — include data.js before trader.js');
    const meta = MODES[mode];
    const gran = meta.granularity;
    const seriesOf = (s) => gran === 'weekly' ? s.weekly : s.monthly;
    const totalNeeded = meta.ticks + PREROLL;

    // Filter to tickers that have enough history at this granularity for this mode.
    // (e.g. COIN only IPO'd in 2021, so it gets dropped from Epic 10y but kept in Sprint/Standard.)
    const universe = history.filter((s) => seriesOf(s).length >= totalNeeded);
    if (universe.length < 3) {
      throw new Error('not enough assets with ' + meta.span + ' of history for ' + mode + ' mode');
    }

    const refSeries = universe.reduce((a, b) => seriesOf(a).length < seriesOf(b).length ? a : b);
    const refArr = seriesOf(refSeries);
    const maxStart = refArr.length - totalNeeded;
    const startIdx = Math.floor(Math.random() * (maxStart + 1));

    const ticks = [];
    for (let i = 0; i < totalNeeded; i++) {
      const idx = startIdx + i;
      const refDate = refArr[idx].date;
      const prices = {};
      for (const s of universe) {
        const arr = seriesOf(s);
        let nearest = null;
        for (let j = arr.length - 1; j >= 0; j--) {
          if (arr[j].date <= refDate) { nearest = arr[j]; break; }
        }
        prices[s.symbol] = nearest ? nearest.close : (arr[0] ? arr[0].close : 0);
      }
      ticks.push({ date: refDate, prices });
    }
    return { ticks, universeSymbols: universe.map((s) => s.symbol), prerollLen: PREROLL };
  }

  function computeValue(game) {
    const prices = game.ticks[game.currentTick].prices;
    let v = game.cash;
    for (const t in game.holdings) v += (prices[t] || 0) * game.holdings[t].shares;
    return v;
  }

  // -------------------- Charting --------------------

  function svgPath(values, w, h) {
    if (values.length < 2) return { line: '', fill: '' };
    let min = Infinity, max = -Infinity;
    for (const v of values) { if (v < min) min = v; if (v > max) max = v; }
    const range = max - min || 1;
    const stepX = w / (values.length - 1);
    const pts = [];
    for (let i = 0; i < values.length; i++) {
      const x = i * stepX;
      const y = h - ((values[i] - min) / range) * h;
      pts.push(x.toFixed(2) + ',' + y.toFixed(2));
    }
    const line = 'M ' + pts.join(' L ');
    const fill = line + ' L ' + ((values.length - 1) * stepX).toFixed(2) + ',' + h + ' L 0,' + h + ' Z';
    return { line, fill };
  }

  function svgPathDual(main, bench, w, h) {
    const all = bench ? main.concat(bench) : main;
    let min = Infinity, max = -Infinity;
    for (const v of all) { if (v < min) min = v; if (v > max) max = v; }
    const range = max - min || 1;
    const stepX = w / (main.length - 1);
    const proj = (vals) => {
      const pts = [];
      for (let i = 0; i < vals.length; i++) {
        const x = i * stepX;
        const y = h - ((vals[i] - min) / range) * h;
        pts.push(x.toFixed(2) + ',' + y.toFixed(2));
      }
      return 'M ' + pts.join(' L ');
    };
    const line = proj(main);
    const benchLine = bench ? proj(bench.slice(0, main.length)) : null;
    const fill = line + ' L ' + ((main.length - 1) * stepX).toFixed(2) + ',' + h + ' L 0,' + h + ' Z';
    return { line, fill, benchLine };
  }

  function sparkSvg(values, w, h, up) {
    const { line } = svgPath(values, w, h);
    const color = up ? '#6FE3B3' : '#FF9E7D';
    return '<svg width="' + w + '" height="' + h + '">' +
      '<path d="' + line + '" stroke="' + color + '" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  }

  function portfolioSvg(series, w, h, bench) {
    const up = series[series.length - 1] >= series[0];
    const color = up ? '#6FE3B3' : '#FF9E7D';
    const { line, fill, benchLine } = svgPathDual(series, bench, w, h);
    const benchPath = benchLine
      ? '<path d="' + benchLine + '" stroke="#8B8499" stroke-width="1.5" stroke-dasharray="4,4" fill="none"/>'
      : '';
    const gradId = 'pt-grad-' + Math.random().toString(36).slice(2);
    return '<svg width="' + w + '" height="' + h + '" viewBox="0 0 ' + w + ' ' + h + '" preserveAspectRatio="none">' +
      '<defs><linearGradient id="' + gradId + '" x1="0" y1="0" x2="0" y2="1">' +
      '<stop offset="0" stop-color="' + color + '" stop-opacity="0.28"/>' +
      '<stop offset="1" stop-color="' + color + '" stop-opacity="0"/></linearGradient></defs>' +
      '<path d="' + fill + '" fill="url(#' + gradId + ')"/>' +
      benchPath +
      '<path d="' + line + '" stroke="' + color + '" stroke-width="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>' +
      '</svg>';
  }

  // -------------------- DOM helpers --------------------

  function h(tag, props, children) {
    const el = document.createElement(tag);
    if (props) {
      for (const k in props) {
        if (k === 'class') el.className = props[k];
        else if (k === 'html') el.innerHTML = props[k];
        else if (k.startsWith('on') && typeof props[k] === 'function') el.addEventListener(k.slice(2).toLowerCase(), props[k]);
        else if (k === 'style' && typeof props[k] === 'object') Object.assign(el.style, props[k]);
        else if (k === 'dataset' && typeof props[k] === 'object') Object.assign(el.dataset, props[k]);
        else el.setAttribute(k, props[k]);
      }
    }
    if (children) {
      const arr = Array.isArray(children) ? children : [children];
      for (const c of arr) {
        if (c == null || c === false) continue;
        el.appendChild(c instanceof Node ? c : document.createTextNode(String(c)));
      }
    }
    return el;
  }

  function fmt(n, digits = 0) {
    return Number(n).toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
  }

  // -------------------- Game --------------------

  function PaperTraderApp(rootEl, opts) {
    this.root = rootEl;
    this.opts = opts || {};
    this.game = null;
    this.timer = null;
    this.bests = readBests();
    this.startingBalance = readSavedBalance();
    this.universeMeta = window.PAPER_TRADER_DATA.map(s => ({ symbol: s.symbol, name: s.name, flavor: s.flavor, risk: s.risk }));
    this.renderLobby();
  }

  function readSavedBalance() {
    try {
      const n = Number(localStorage.getItem(BALANCE_KEY));
      if (Number.isFinite(n) && n >= MIN_STARTING_CASH && n <= MAX_STARTING_CASH) return n;
    } catch (e) {}
    return DEFAULT_STARTING_CASH;
  }
  function writeSavedBalance(n) {
    try { localStorage.setItem(BALANCE_KEY, String(n)); } catch (e) {}
  }
  function clampBalance(n) {
    if (!Number.isFinite(n)) return DEFAULT_STARTING_CASH;
    return Math.max(MIN_STARTING_CASH, Math.min(MAX_STARTING_CASH, Math.round(n)));
  }

  PaperTraderApp.prototype.startRun = function (mode) {
    this.clearTimer();
    let sliced;
    try {
      sliced = sliceRun(mode);
    } catch (err) {
      console.error('PaperTrader:', err);
      alert("Couldn't start this run — " + (err && err.message ? err.message : 'unknown error') + '. Try a different mode.');
      return;
    }
    const startingCash = clampBalance(this.startingBalance);
    this.startingBalance = startingCash;
    writeSavedBalance(startingCash);
    this.game = {
      mode,
      ticks: sliced.ticks,
      universeSymbols: sliced.universeSymbols,
      prerollLen: sliced.prerollLen,
      currentTick: sliced.prerollLen,
      isPaused: false,
      startingCash,
      cash: startingCash,
      holdings: {},
      history: [startingCash],
      assetsTouched: new Set(),
      maxValue: startingCash,
      maxDrawdown: 0,
      startedAt: Date.now(),
    };
    this.renderGame();
    this.startTimer();
  };

  PaperTraderApp.prototype.advanceTick = function () {
    const g = this.game;
    if (!g) return;
    if (g.isPaused) return;
    if (g.currentTick >= g.ticks.length - 1) return this.endRun();
    g.currentTick += 1;
    const v = computeValue(g);
    g.history.push(v);
    if (v > g.maxValue) g.maxValue = v;
    const dd = g.maxValue > 0 ? (g.maxValue - v) / g.maxValue : 0;
    if (dd > g.maxDrawdown) g.maxDrawdown = dd;
    this.updateGameDOM();
  };

  PaperTraderApp.prototype.startTimer = function () {
    this.clearTimer();
    const tickMs = MODES[this.game.mode].tickMs;
    // First tick fires fast so the player sees motion immediately,
    // then we settle into the mode's normal cadence.
    this.timer = setTimeout(() => {
      this.advanceTick();
      this.timer = setInterval(() => this.advanceTick(), tickMs);
    }, FIRST_TICK_DELAY);
  };

  PaperTraderApp.prototype.clearTimer = function () {
    if (this.timer) {
      clearTimeout(this.timer);
      clearInterval(this.timer);
      this.timer = null;
    }
  };

  PaperTraderApp.prototype.pauseToggle = function () {
    if (!this.game) return;
    this.game.isPaused = !this.game.isPaused;
    this.renderGame();
  };

  PaperTraderApp.prototype.buy = function (sym, dollars) {
    const g = this.game;
    const price = g.ticks[g.currentTick].prices[sym];
    if (!price || dollars <= 0) return;
    const spend = Math.min(dollars, g.cash);
    const shares = spend / price;
    const existing = g.holdings[sym] || { shares: 0, avgCost: 0 };
    const newShares = existing.shares + shares;
    const newAvg = (existing.avgCost * existing.shares + price * shares) / newShares;
    g.holdings[sym] = { shares: newShares, avgCost: newAvg };
    g.cash -= spend;
    g.assetsTouched.add(sym);
    this.updateGameDOM();
  };

  PaperTraderApp.prototype.sell = function (sym, shares) {
    const g = this.game;
    const price = g.ticks[g.currentTick].prices[sym];
    const existing = g.holdings[sym];
    if (!existing || !price) return;
    const s = Math.min(shares, existing.shares);
    if (s <= 0) return;
    g.holdings[sym] = { shares: existing.shares - s, avgCost: existing.avgCost };
    if (g.holdings[sym].shares < 0.0001) delete g.holdings[sym];
    g.cash += s * price;
    this.updateGameDOM();
  };

  PaperTraderApp.prototype.endRun = function () {
    this.clearTimer();
    if (!this.game) return;
    const g = this.game;
    // Baselines should be computed over the player's window only — exclude preroll context ticks.
    const gameStart = g.ticks[g.prerollLen].prices;
    const last = g.ticks[g.ticks.length - 1].prices;
    let final = g.cash;
    for (const t in g.holdings) final += (last[t] || 0) * g.holdings[t].shares;
    const finalReturn = (final - g.startingCash) / g.startingCash;
    const vtiStart = gameStart['VTI'];
    const vtiEnd = last['VTI'];
    const vtiReturn = vtiStart > 0 ? (vtiEnd - vtiStart) / vtiStart : 0;
    const vtiSeries = g.ticks.slice(g.prerollLen).map(t => (t.prices['VTI'] / vtiStart) * g.startingCash);
    let bestSym = 'VTI', bestRet = -Infinity;
    for (const sym in gameStart) {
      const s = gameStart[sym], e = last[sym];
      if (!s || !e) continue;
      const r = (e - s) / s;
      if (r > bestRet) { bestRet = r; bestSym = sym; }
    }
    const concentrations = [];
    for (const t in g.holdings) {
      const v = (last[t] || 0) * g.holdings[t].shares;
      concentrations.push(final > 0 ? v / final : 0);
    }
    const maxConcentration = concentrations.length ? Math.max(...concentrations) : 0;
    const diversifierBadge = g.assetsTouched.size >= 4;
    const beatBenchmark = finalReturn > vtiReturn;

    const summary = {
      mode: g.mode,
      startDate: g.ticks[g.prerollLen].date,
      endDate: g.ticks[g.ticks.length - 1].date,
      startingCash: g.startingCash,
      finalValue: final,
      finalReturn, vtiReturn,
      bestSingleSymbol: bestSym, bestSingleReturn: bestRet,
      maxDrawdown: g.maxDrawdown,
      assetsTouched: [...g.assetsTouched],
      maxConcentration, diversifierBadge, beatBenchmark,
      portfolioSeries: g.history, vtiSeries,
      durationMs: Date.now() - g.startedAt,
    };

    // persist best
    const existing = this.bests[g.mode];
    if (!existing || finalReturn > existing.finalReturn) {
      this.bests[g.mode] = { finalReturn, date: summary.startDate, diversifierBadge };
      writeBests(this.bests);
    }

    if (typeof this.opts.onComplete === 'function') this.opts.onComplete(summary);
    this.game = null;
    this.renderResult(summary);
  };

  PaperTraderApp.prototype.abandon = function () {
    this.clearTimer();
    this.game = null;
    this.renderLobby();
  };

  // -------------------- Renders --------------------

  PaperTraderApp.prototype.renderLobby = function () {
    this.root.className = 'pt-root';
    this.root.innerHTML = '';
    const content = h('div', { class: 'pt-content' });

    const intro = h('div', { class: 'pt-fadeup' }, [
      h('p', { class: 'pt-eyebrow' }, 'paper trading'),
      h('h1', { class: 'pt-display' }, ['Time Travel', h('br'), 'Trader.']),
      h('p', { class: 'pt-body' }, 'Rewind real market history. Compress months into minutes. Try to beat the diversified baseline. Practice for free, learn for life.'),
    ]);
    content.appendChild(intro);

    // Starting balance input
    const self = this;
    const balanceInput = h('input', {
      type: 'number',
      class: 'pt-balance-input',
      value: String(this.startingBalance),
      min: String(MIN_STARTING_CASH),
      max: String(MAX_STARTING_CASH),
      step: '1',
      inputmode: 'numeric',
      'aria-label': 'Starting balance',
    });
    balanceInput.addEventListener('input', (e) => {
      const raw = e.target.value.trim();
      if (raw === '') return; // allow empty mid-edit
      const n = Number(raw);
      if (Number.isFinite(n)) self.startingBalance = n;
    });
    balanceInput.addEventListener('blur', (e) => {
      const n = clampBalance(Number(e.target.value));
      self.startingBalance = n;
      balanceInput.value = String(n);
      writeSavedBalance(n);
    });
    const presetRow = h('div', { class: 'pt-balance-presets' });
    [['$100', 100], ['$1k', 1000], ['$10k', 10000], ['$100k', 100000]].forEach(([label, val]) => {
      const btn = h('button', { type: 'button', class: 'pt-preset-btn' }, label);
      btn.addEventListener('click', () => {
        self.startingBalance = val;
        balanceInput.value = String(val);
        writeSavedBalance(val);
        // visual active state
        presetRow.querySelectorAll('.pt-preset-btn').forEach(b => b.classList.toggle('pt-preset-active', b === btn));
      });
      if (val === this.startingBalance) btn.classList.add('pt-preset-active');
      presetRow.appendChild(btn);
    });

    const balanceCard = h('div', { class: 'pt-card pt-fadeup', style: { animationDelay: '40ms' } }, [
      h('p', { class: 'pt-label' }, 'Input: starting balance'),
      h('div', { class: 'pt-balance-row' }, [
        h('span', { class: 'pt-balance-prefix' }, '$'),
        balanceInput,
      ]),
      h('p', { class: 'pt-caption', style: { marginTop: '8px' } }, "How much do you want to start with? This is what you'll trade with — no real money."),
      presetRow,
    ]);
    content.appendChild(balanceCard);

    Object.keys(MODES).forEach((mode, i) => {
      const m = MODES[mode];
      const best = this.bests[mode];
      const card = h('div', {
        class: 'pt-mode-card pt-fadeup',
        dataset: { mode },
        style: { animationDelay: (80 + i * 60) + 'ms' },
        onclick: () => this.startRun(mode),
      }, [
        h('div', { class: 'pt-mode-top' }, [
          h('div', null, [
            h('div', { class: 'pt-mode-label' }, m.label),
            h('div', { class: 'pt-mode-span' }, m.span + ' • ~' + Math.round((m.ticks * m.tickMs) / 1000) + 's'),
          ]),
          h('div', { class: 'pt-mode-emoji' }, m.emoji),
        ]),
        h('div', { class: 'pt-mode-desc' }, m.description),
        h('div', { class: 'pt-mode-footer' }, [
          h('span', { class: 'pt-mode-best' },
            best ? 'best: ' + (best.finalReturn * 100).toFixed(1) + '%' + (best.diversifierBadge ? ' • 🛡' : '')
                 : 'no run yet'),
          h('span', { class: 'pt-mode-play' }, 'play →'),
        ]),
      ]);
      content.appendChild(card);
    });

    const help = h('div', { class: 'pt-card pt-fadeup', style: { animationDelay: '320ms' } }, [
      h('p', { class: 'pt-label', style: { marginBottom: '8px' } }, 'how it works'),
      h('p', { class: 'pt-body' }, "You start with $10,000 of fake cash. The clock runs through real historical prices. Tap any stock to buy or sell. At the end, you'll see how your portfolio's risk and return stacked up against a boring-but-mighty diversified ETF."),
      h('p', { class: 'pt-body', style: { margin: 0 } }, 'The lesson lands at the end. Promise.'),
    ]);
    content.appendChild(help);

    this.root.appendChild(content);
  };

  PaperTraderApp.prototype.renderGame = function () {
    this.root.className = 'pt-root';
    this.root.innerHTML = '';
    const content = h('div', { class: 'pt-content' });
    content.id = 'pt-game-content';
    this.root.appendChild(content);
    this.updateGameDOM(true);

    if (this.game.isPaused) {
      const pause = h('div', { class: 'pt-paused' }, [
        h('div', { class: 'pt-paused-title' }, 'paused'),
        h('div', { class: 'pt-paused-sub' }, 'tap ▶ to resume'),
      ]);
      this.root.appendChild(pause);
    }
  };

  PaperTraderApp.prototype.updateGameDOM = function (fullRender) {
    const g = this.game;
    if (!g) return;
    const meta = MODES[g.mode];
    const value = computeValue(g);
    const change = (value - g.startingCash) / g.startingCash;
    const tick = g.ticks[g.currentTick];
    const gameTickIdx = g.currentTick - g.prerollLen;     // 0-based within the playable window
    const gameTickCount = g.ticks.length - g.prerollLen;
    const pct = gameTickIdx / Math.max(1, gameTickCount - 1);

    let content = this.root.querySelector('#pt-game-content');
    if (!content || fullRender) {
      if (content) content.innerHTML = '';
      else { content = h('div', { class: 'pt-content' }); content.id = 'pt-game-content'; this.root.appendChild(content); }
    } else {
      content.innerHTML = '';
    }

    // Top row
    const top = h('div', { class: 'pt-game-top' }, [
      h('button', { class: 'pt-icon-btn', onclick: () => this.abandon() }, '×'),
      h('div', { class: 'pt-game-center' }, [
        h('div', { class: 'pt-eyebrow' }, meta.label + ' • ' + tick.date),
        h('div', { class: 'pt-caption' }, 'tick ' + (gameTickIdx + 1) + ' / ' + gameTickCount),
      ]),
      h('button', { class: 'pt-icon-btn pt-icon-btn--ink', onclick: () => this.pauseToggle() }, g.isPaused ? '▶' : '❚❚'),
    ]);
    content.appendChild(top);

    const prog = h('div', { class: 'pt-progress' }, [
      h('div', { class: 'pt-progress-fill', style: { width: (pct * 100) + '%' } }),
    ]);
    content.appendChild(prog);

    // Hero card
    const chartW = Math.min(content.clientWidth || 460, 480) - 48;
    const portfolioMarkup = portfolioSvg(g.history.length > 1 ? g.history : [g.startingCash, g.startingCash], chartW > 0 ? chartW : 320, 120);
    const hero = h('div', { class: 'pt-card pt-hero' });
    hero.innerHTML =
      '<div class="pt-label">portfolio value</div>' +
      '<div class="pt-hero-value">$' + fmt(value, 2) + '</div>' +
      '<div class="pt-hero-delta ' + (change >= 0 ? 'pt-hero-delta--up' : 'pt-hero-delta--down') + '">' +
      (change >= 0 ? '+' : '') + (change * 100).toFixed(2) + '%</div>' +
      '<div class="pt-chart-wrap">' + portfolioMarkup + '</div>' +
      '<div class="pt-mini-stats">' +
        '<div class="pt-mini-stat"><div class="pt-mini-stat-label">cash</div><div class="pt-mini-stat-value">$' + fmt(g.cash) + '</div></div>' +
        '<div class="pt-mini-stat"><div class="pt-mini-stat-label">positions</div><div class="pt-mini-stat-value">' + Object.keys(g.holdings).length + '</div></div>' +
        '<div class="pt-mini-stat"><div class="pt-mini-stat-label">touched</div><div class="pt-mini-stat-value">' + g.assetsTouched.size + '</div></div>' +
      '</div>';
    content.appendChild(hero);

    // Asset list — only iterate over assets this run actually includes
    content.appendChild(h('div', { class: 'pt-label', style: { marginLeft: '4px', marginTop: '24px' } }, 'tap to trade'));
    const list = h('div', { class: 'pt-asset-list' });
    const activeUniverse = this.universeMeta.filter((u) => g.universeSymbols.indexOf(u.symbol) !== -1);
    activeUniverse.forEach((u) => {
      const series = [];
      const len = Math.min(6, g.currentTick + 1);
      for (let i = Math.max(0, g.currentTick - len + 1); i <= g.currentTick; i++) {
        series.push(g.ticks[i].prices[u.symbol]);
      }
      const prev = series.length >= 2 ? series[series.length - 2] : tick.prices[u.symbol];
      const dayChange = prev > 0 ? (tick.prices[u.symbol] - prev) / prev : 0;
      const up = dayChange >= 0;
      const holding = g.holdings[u.symbol];
      const positionVal = holding ? holding.shares * tick.prices[u.symbol] : 0;
      const pnl = holding ? (tick.prices[u.symbol] - holding.avgCost) * holding.shares : 0;
      const spark = sparkSvg(series, 70, 36, up);

      const card = h('div', {
        class: 'pt-asset',
        onclick: () => this.openTradeModal(u.symbol),
      });
      card.innerHTML =
        '<div>' +
          '<div class="pt-asset-top"><div class="pt-asset-sym">' + u.symbol + '</div>' +
          '<div class="pt-asset-delta ' + (up ? 'pt-asset-delta--up' : 'pt-asset-delta--down') + '">' +
          (up ? '+' : '') + (dayChange * 100).toFixed(1) + '%</div></div>' +
          '<div class="pt-asset-name">' + u.name + '</div>' +
          '<div class="pt-asset-price">$' + fmt(tick.prices[u.symbol], 2) + '</div>' +
          (holding
            ? '<div class="pt-asset-position">' + holding.shares.toFixed(2) + ' sh • $' + fmt(positionVal) + ' ' + (pnl >= 0 ? '↑' : '↓') + ' $' + fmt(Math.abs(pnl)) + '</div>'
            : '') +
        '</div>' +
        '<div class="pt-asset-spark">' + spark + '</div>';
      list.appendChild(card);
    });
    content.appendChild(list);

    const endRow = h('div', { class: 'pt-end-row' }, [
      h('button', { class: 'pt-end-btn', onclick: () => this.endRun() }, 'end run early'),
    ]);
    content.appendChild(endRow);
  };

  PaperTraderApp.prototype.openTradeModal = function (sym) {
    const g = this.game;
    if (!g) return;
    const price = g.ticks[g.currentTick].prices[sym];
    const universe = this.universeMeta.find(u => u.symbol === sym);
    let side = 'buy';
    let dollars = 0;

    const backdrop = h('div', { class: 'pt-modal-backdrop pt-open', onclick: (e) => { if (e.target === backdrop) close(); } });
    const sheet = h('div', { class: 'pt-modal-sheet', onclick: (e) => e.stopPropagation() });
    const close = () => { document.body.removeChild(backdrop); };

    const buyBtn = h('button', { class: 'pt-toggle pt-active' }, 'BUY');
    const sellBtn = h('button', { class: 'pt-toggle' }, 'SELL');
    const amountEl = h('div', { class: 'pt-modal-amount-big' }, '$0');
    const sharesEl = h('div', { class: 'pt-modal-amount-sub' }, '≈ 0.00 shares');
    const slider = h('input', { type: 'range', class: 'pt-slider', min: '0', max: '0', step: '1', value: '0' });
    const cta = h('button', { class: 'pt-modal-cta pt-modal-cta--buy', disabled: 'true' }, 'Buy $0');
    const summaryLabel = h('div', { class: 'pt-label' });
    const summaryValue = h('div', null);

    function getMax() {
      if (side === 'buy') return g.cash;
      const holding = g.holdings[sym];
      return holding ? holding.shares * price : 0;
    }
    function syncToggles() {
      buyBtn.classList.toggle('pt-active', side === 'buy');
      sellBtn.classList.toggle('pt-active', side === 'sell');
      if (!g.holdings[sym]) sellBtn.setAttribute('disabled', 'true');
      else sellBtn.removeAttribute('disabled');
      dollars = 0;
      slider.value = '0';
      slider.max = String(getMax());
      updateUI();
    }
    const self = this;
    function updateUI() {
      const shares = price > 0 ? dollars / price : 0;
      amountEl.textContent = '$' + fmt(dollars);
      sharesEl.textContent = '≈ ' + shares.toFixed(2) + ' shares';
      cta.classList.toggle('pt-modal-cta--buy', side === 'buy');
      cta.classList.toggle('pt-modal-cta--sell', side === 'sell');
      cta.textContent = side === 'buy' ? 'Buy $' + fmt(dollars) : 'Sell ' + shares.toFixed(2) + ' sh';
      if (dollars > 0 && dollars <= getMax()) cta.removeAttribute('disabled');
      else cta.setAttribute('disabled', 'true');
      summaryLabel.textContent = side === 'buy' ? 'cash' : 'position';
      summaryValue.textContent = side === 'buy'
        ? '$' + fmt(g.cash)
        : ((g.holdings[sym] && g.holdings[sym].shares.toFixed(2)) || '0') + ' sh';
    }

    buyBtn.addEventListener('click', () => { side = 'buy'; syncToggles(); });
    sellBtn.addEventListener('click', () => { if (g.holdings[sym]) { side = 'sell'; syncToggles(); } });
    slider.addEventListener('input', (e) => { dollars = Number(e.target.value); updateUI(); });

    cta.addEventListener('click', () => {
      const shares = price > 0 ? dollars / price : 0;
      if (side === 'buy') self.buy(sym, dollars);
      else self.sell(sym, shares);
      close();
    });

    sheet.appendChild(h('div', { class: 'pt-modal-handle' }));
    sheet.appendChild(h('div', { class: 'pt-modal-header' }, [
      h('div', { class: 'pt-modal-sym' }, sym),
      h('div', { class: 'pt-modal-name' }, universe ? universe.name : ''),
      h('div', { class: 'pt-modal-price' }, '$' + fmt(price, 2) + ' / share'),
    ]));
    sheet.appendChild(h('div', { class: 'pt-toggle-row' }, [buyBtn, sellBtn]));
    sheet.appendChild(h('div', { class: 'pt-modal-amount' }, [amountEl, sharesEl]));
    sheet.appendChild(slider);
    const quickRow = h('div', { class: 'pt-quick-row' });
    ['0', '25%', '50%', 'max'].forEach((q, i) => {
      const btn = h('button', { class: 'pt-quick-btn' }, q);
      btn.addEventListener('click', () => {
        const max = getMax();
        dollars = i === 0 ? 0 : i === 1 ? max * 0.25 : i === 2 ? max * 0.5 : max;
        slider.value = String(dollars);
        updateUI();
      });
      quickRow.appendChild(btn);
    });
    sheet.appendChild(quickRow);
    sheet.appendChild(h('div', { class: 'pt-summary-row' }, [summaryLabel, summaryValue]));
    sheet.appendChild(cta);
    backdrop.appendChild(sheet);
    document.body.appendChild(backdrop);

    syncToggles();
  };

  PaperTraderApp.prototype.renderResult = function (s) {
    this.root.className = 'pt-root';
    this.root.innerHTML = '';
    const content = h('div', { class: 'pt-content' });

    content.appendChild(h('div', { class: 'pt-fadeup' }, [
      h('p', { class: 'pt-eyebrow' }, 'your run'),
      h('h1', { class: 'pt-display' }, s.beatBenchmark ? 'You beat VTI.' : "You didn't beat VTI."),
      h('p', { class: 'pt-caption' }, '$' + fmt(s.startingCash) + ' → $' + fmt(s.finalValue) + ' • ' + s.startDate + ' → ' + s.endDate),
    ]));

    // Chart card
    const chartW = Math.min(content.clientWidth || 460, 480) - 48;
    const chartMarkup = portfolioSvg(s.portfolioSeries, chartW > 0 ? chartW : 320, 140, s.vtiSeries);
    const chartCard = h('div', { class: 'pt-card pt-fadeup', style: { animationDelay: '80ms' } });
    chartCard.innerHTML =
      '<div class="pt-label">portfolio path</div>' +
      '<div class="pt-chart-wrap" style="margin-top:12px">' + chartMarkup + '</div>' +
      '<div class="pt-legend">' +
        '<div class="pt-legend-item"><span class="pt-legend-dot" style="background:' + (s.finalReturn >= 0 ? '#6FE3B3' : '#FF9E7D') + '"></span>you</div>' +
        '<div class="pt-legend-item"><span class="pt-legend-dot" style="background:#8B8499"></span>VTI buy & hold</div>' +
      '</div>';
    content.appendChild(chartCard);

    // 3-up summary
    const youClass = s.beatBenchmark ? 'pt-three-stat pt-three-stat--win' : 'pt-three-stat';
    const threeUp = h('div', { class: 'pt-three-row pt-fadeup', style: { animationDelay: '140ms' } });
    threeUp.innerHTML =
      '<div class="' + youClass + '"><div class="pt-three-stat-label">YOU</div><div class="pt-three-stat-value">' + (s.finalReturn >= 0 ? '+' : '') + (s.finalReturn * 100).toFixed(1) + '%</div></div>' +
      '<div class="pt-three-stat"><div class="pt-three-stat-label">VTI</div><div class="pt-three-stat-value">' + (s.vtiReturn >= 0 ? '+' : '') + (s.vtiReturn * 100).toFixed(1) + '%</div></div>' +
      '<div class="pt-three-stat"><div class="pt-three-stat-label">BEST ' + s.bestSingleSymbol + '</div><div class="pt-three-stat-value">' + (s.bestSingleReturn >= 0 ? '+' : '') + (s.bestSingleReturn * 100).toFixed(1) + '%</div></div>';
    content.appendChild(threeUp);

    // Scorecard
    const score = h('div', { class: 'pt-card pt-fadeup', style: { animationDelay: '200ms' } });
    score.innerHTML =
      '<div class="pt-label">diversification scorecard</div>' +
      '<div class="pt-score-row"><div class="pt-score-key">assets touched</div><div class="pt-score-val">' + s.assetsTouched.length + ' / 8</div></div>' +
      '<div class="pt-score-row"><div class="pt-score-key">max concentration</div><div class="pt-score-val">' + (s.maxConcentration * 100).toFixed(0) + '%</div></div>' +
      '<div class="pt-score-row"><div class="pt-score-key">max drawdown</div><div class="pt-score-val">−' + (s.maxDrawdown * 100).toFixed(1) + '%</div></div>' +
      '<div class="pt-score-row"><div class="pt-score-key">final value</div><div class="pt-score-val">$' + fmt(s.finalValue) + '</div></div>' +
      (s.diversifierBadge ? '<div class="pt-badge">🛡 Diversifier — held ≥4 assets</div>' : '');
    content.appendChild(score);

    // Coach
    const coach = h('div', { class: 'pt-card pt-fadeup', style: { animationDelay: '260ms' } });
    coach.innerHTML =
      '<div class="pt-label">coach note</div>' +
      '<div class="pt-coach">' + pickReaction(s) + '</div>';
    content.appendChild(coach);

    // Buttons
    const btnRow = h('div', { class: 'pt-fadeup', style: { textAlign: 'center', marginTop: '20px', animationDelay: '320ms' } }, [
      h('button', { class: 'pt-cta', onclick: () => this.startRun(s.mode) }, 'Play again'),
      h('div', { style: { marginTop: '12px' } }, [
        h('button', { class: 'pt-ghost', onclick: () => this.renderLobby() }, '← back to lobby'),
      ]),
    ]);
    content.appendChild(btnRow);

    this.root.appendChild(content);
  };

  function pickReaction(s) {
    const over = s.finalReturn - s.vtiReturn;
    if (s.maxConcentration > 0.7) {
      return 'You ' + (over >= 0 ? 'beat' : 'lost to') + ' VTI by ' + (Math.abs(over) * 100).toFixed(1) + '% — but ' + (s.maxConcentration * 100).toFixed(0) + '% of your portfolio was in a single asset. That\'s a coin flip, not a strategy. Try spreading across ≥4 assets next round.';
    }
    if (s.diversifierBadge && over >= 0) {
      return 'Real move. You held ' + s.assetsTouched.length + ' assets, beat the diversified baseline by ' + (over * 100).toFixed(1) + '%, and kept drawdown manageable. This is what risk-adjusted return looks like.';
    }
    if (s.diversifierBadge && over < 0) {
      return 'You diversified well (' + s.assetsTouched.length + ' assets), but came in ' + (Math.abs(over) * 100).toFixed(1) + '% under VTI. Honestly? Most active traders lose to the index over time. Diversifying and matching the market is the long game.';
    }
    if (s.assetsTouched.length <= 1) {
      return 'You held ' + (s.assetsTouched.length === 0 ? 'no positions' : 'one asset') + '. The market doesn\'t reward sitting out or going all-in on a single bet. Spread it across 4+ next time.';
    }
    return 'Solid run. You held ' + s.assetsTouched.length + ' assets. Diversification is a free lunch — it cuts risk without cutting returns. Keep it up.';
  }

  // -------------------- Public API --------------------

  window.PaperTrader = {
    mount(selectorOrEl, opts) {
      const root = typeof selectorOrEl === 'string' ? document.querySelector(selectorOrEl) : selectorOrEl;
      if (!root) throw new Error('PaperTrader.mount: element not found for ' + selectorOrEl);
      return new PaperTraderApp(root, opts || {});
    },
    MODES,
  };
})();
