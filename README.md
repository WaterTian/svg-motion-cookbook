<p align="right"><strong>English</strong> · <a href="README.zh.md">中文</a></p>

<p align="center">
  <img src="https://raw.githubusercontent.com/WaterTian/svg-motion-cookbook/main/examples/hero.svg" alt="svg-motion-cookbook" width="900"/>
</p>

> Recipes for hand-authoring small **animated SVGs that play on GitHub** — README headers, status badges, walkthrough diagrams. Pure SMIL, no JS, no CSS, no toolchain.

> **About the banner above.** It's not a screenshot — it's a single SVG file under 5KB that composes all 8 cookbook patterns. The wordmark wipes in with `clipPath` (pattern 3), shimmers through palette neighbors (6), the cursor blinks discretely (7); the eight bars stagger (2) through a loop-with-hold cycle (1); the right-hand label rotates via opacity overlay (4); `plays` pulses on a `tspan` (5); the green dot heartbeats once per 6s cycle (8). Read [`examples/hero.svg`](examples/hero.svg) — the entire show is plain SMIL.

---

## Try it in 30 seconds

```bash
git clone https://github.com/WaterTian/svg-motion-cookbook
open svg-motion-cookbook/examples/01-loop-bar.svg
```

Or just hit any link in the table below — every example renders directly on GitHub.

## Why these constraints

GitHub renders `<img src="*.svg">` in READMEs and sanitizes the SVG. That means:

- ❌ `<script>` — stripped
- ❌ CSS `@keyframes` / external stylesheets — stripped
- ❌ Web Animations API — needs JS
- ✅ **SMIL** (`<animate>`, `<animateTransform>`, `<set>`) — preserved and plays in the browser

If you want animation to actually move on a GitHub-hosted README, SMIL is the path. This cookbook focuses on SMIL exclusively.

## What's inside

### 📘 [`patterns.md`](patterns.md) — eight reusable recipes

Each entry has: when to use it, the minimal code, and a runnable example.

| # | Pattern | Example |
|---|---|---|
| 1 | Loop with hold phase                     | [01-loop-bar.svg](examples/01-loop-bar.svg) |
| 2 | Staggered begin (multi-element rhythm)   | [02-staggered-bars.svg](examples/02-staggered-bars.svg) |
| 3 | Clip-path reveal (ASCII-block animation) | [03-clip-reveal-text.svg](examples/03-clip-reveal-text.svg) |
| 4 | Text-content swap via opacity overlay    | [04-text-swap.svg](examples/04-text-swap.svg) |
| 5 | tspan pulse with `fill-opacity`          | [05-pulse-glyph.svg](examples/05-pulse-glyph.svg) |
| 6 | Color shimmer (`fill` interpolation)     | [06-color-shimmer.svg](examples/06-color-shimmer.svg) |
| 7 | Discrete blink (terminal cursor feel)    | [07-cursor-blink.svg](examples/07-cursor-blink.svg) |
| 8 | Once-per-cycle heartbeat                 | [08-heartbeat.svg](examples/08-heartbeat.svg) |
| ★ | All eight composed                       | [compound-statusline.svg](examples/compound-statusline.svg) |
| ★ | All eight composed (banner form)         | [hero.svg](examples/hero.svg) |

### ⚠️ [`gotchas.md`](gotchas.md) — pitfalls that cost me 15+ minutes each

Whitespace collapse · `tspan` opacity flakiness · `calcMode` semantics · `keyTimes` monotonicity · `<animate>` element placement · monospace alignment · sanitizer rules · file-size thresholds.

### 📦 [`github-readme.md`](github-readme.md) — embedding guide

`raw.githubusercontent.com` URL requirement · `<picture>` for light/dark themes · PNG fallback strategy · cache-busting query strings · size limits at the image proxy.

## Render & snapshot

```bash
# Render a single frame at t=2000ms (for thumbnails / PNG fallbacks)
./scripts/render.sh examples/01-loop-bar.svg 2000 /tmp/out.png

# Snapshot multiple frames across one cycle (for visual verification)
./scripts/render-frames.sh examples/compound-statusline.svg
```

Both scripts shell out to **headless Chrome with `--virtual-time-budget`** — the flag that advances the SMIL clock to an exact moment and captures that frame. The same technique was used to design and verify [`examples/hero.svg`](examples/hero.svg).

## Compatibility

| Renderer | SMIL plays | Notes |
|---|---|---|
| Chrome / Edge / Safari / Firefox | ✅ | All modern desktop browsers |
| GitHub README (`<img src="*.svg">`) | ✅ | Animations play; sanitizer keeps SMIL |
| npm package page | ✅ | Renders README via GitHub raw URL |
| VS Code Markdown preview | ✅ | Plays via embedded Webview |
| RSS readers / static-site previewers | ⚠️ | Many fall back to static first frame; ship a PNG inside `<picture>` |
| Image proxies that re-encode (rare) | ❌ | Some converters flatten SVG → PNG and lose animation |

## Showcase

Projects shipping animated SVGs built with these patterns:

- **[cc-hud](https://github.com/WaterTian/cc-hud)** — a terminal-style statusline for Claude Code. Its animated README header composes the loop+hold, staggered, clip-reveal, text-swap, color-shimmer, and cursor-blink patterns at once.
- **[SintBot](https://github.com/WaterTian/sintbot)** — a self-hosted daemon that puts Claude Code and Codex in your team's group chat. Its README banner, flow diagram and Slack-thread demo combine loop-with-hold timelines, staggered steps, opacity text swaps, color shimmer and a once-per-cycle heartbeat, plus a stroke draw-in for the arrows. Only color, opacity and stroke progress change, and all text is outlined to paths so the typography matches the website on every OS.

If you ship one of these in your own project, drop a link — I'd love to add it here.

## License

MIT. Copy, fork, remix.
