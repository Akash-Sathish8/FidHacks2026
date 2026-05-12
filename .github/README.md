# CI

## iOS Preview

Workflow: [`workflows/ios-preview.yml`](workflows/ios-preview.yml)

**What it does:** Every push (any branch) builds Budget Bloom on a macOS runner, boots an iPhone 17 Pro simulator, and screenshots key app states. The PNGs are uploaded as a downloadable artifact on the workflow run.

**How to use it (no Xcode required):**

1. Push your branch
2. Open the repo on github.com → **Actions** tab
3. Click the most recent **iOS Preview** run for your branch
4. Scroll to the bottom → **Artifacts** section
5. Download `ios-preview-<branch>-<run-number>.zip`
6. Unzip → you'll see `01-splash.png`, `02-home.png`, etc.

**Runtime:** ~3-5 minutes per push.

**Cost:** Free for public repos. ~$0.08/run for private (macOS minutes).

## How to add more screenshots

Edit `workflows/ios-preview.yml`. Each screenshot is a step like:

```yaml
- name: Capture <screen>
  run: |
    # (optional) seed UserDefaults to land on the screen you want
    xcrun simctl spawn booted defaults write "$BUNDLE_ID" mm.route.v1 -string "main"
    xcrun simctl launch booted "$BUNDLE_ID"
    sleep 4
    xcrun simctl io booted screenshot screenshots/NN-name.png
    xcrun simctl terminate booted "$BUNDLE_ID" || true
```

To navigate deeper than the launch screen (other tabs, modals), seed the relevant `mm.*.v1` UserDefaults keys to put the app in the right state before launching. The keys are defined in `MoneyMoves/State/AppState.swift`:

- `mm.user.v1` — JSON-encoded `User` (name, buddyId, coins, etc.)
- `mm.route.v1` — String, set to `"main"` to skip onboarding
- `mm.goals.v1` — JSON array of `SavingGoal`
- `mm.cats.v1` — JSON array of `SpendCategory`
- `mm.bests.v1` — JSON dict of trade bests
- `mm.deposits.v1` — JSON array of `GoalDeposit`

For *interactive* states (mid-game in the paper trader, modal sheets, etc.), the cleanest extension is to add a UI test target (`XCUITest`) and have it drive the screens before screenshotting. That's a future addition.
