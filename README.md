# svg-motion-cookbook

> Recipes for hand-authoring small **animated SVGs that play on GitHub** — README headers, status badges, walkthrough diagrams. Pure SMIL, no JS, no CSS, no toolchain.

Born out of building [cc-hud](https://github.com/WaterTian/cc-hud)'s animated README header. The same patterns reuse cleanly across other projects, so this cookbook collects them in one place.

## Why these constraints

GitHub renders `<img src="*.svg">` in README and sanitizes the SVG. That means:

- ❌ `<script>` — stripped
- ❌ CSS `@keyframes` / external stylesheets — stripped
- ❌ Web Animations API — needs JS
- ✅ **SMIL** (`<animate>`, `<animateTransform>`, `<set>`) — preserved and plays in the browser

So if you want animation to actually move on a GitHub-hosted README — SMIL is the path. This cookbook focuses on SMIL exclusively.

## Quick tour

```bash
# View any example directly in your browser
open examples/01-loop-bar.svg

# Render a single frame at t=2000ms (for thumbnails / fallback PNGs)
./scripts/render.sh examples/01-loop-bar.svg 2000 /tmp/out.png

# Snapshot multiple frames across one cycle for visual verification
./scripts/render-frames.sh examples/compound-statusline.svg
```

Both scripts shell out to **headless Chrome** with `--virtual-time-budget` — the key flag that lets you advance the SMIL clock to an exact moment and capture that frame.

## What's inside

### Patterns ([patterns.md](patterns.md))

Eight reusable recipes. Each entry lists when to use it, the minimal code, and links to a runnable example.

| # | Pattern | Minimal example |
|---|---|---|
| 1 | Loop with hold phase                    | [01-loop-bar.svg](examples/01-loop-bar.svg) |
| 2 | Staggered begin (multi-element rhythm)  | [02-staggered-bars.svg](examples/02-staggered-bars.svg) |
| 3 | Clip-path reveal (ASCII-block animation) | [03-clip-reveal-text.svg](examples/03-clip-reveal-text.svg) |
| 4 | Text-content swap via opacity overlay   | [04-text-swap.svg](examples/04-text-swap.svg) |
| 5 | tspan pulse with `fill-opacity`         | [05-pulse-glyph.svg](examples/05-pulse-glyph.svg) |
| 6 | Color shimmer (`fill` interpolation)    | [06-color-shimmer.svg](examples/06-color-shimmer.svg) |
| 7 | Discrete blink (terminal cursor feel)   | [07-cursor-blink.svg](examples/07-cursor-blink.svg) |
| 8 | Once-per-cycle heartbeat                | [08-heartbeat.svg](examples/08-heartbeat.svg) |
| ★ | Composition of all of the above         | [compound-statusline.svg](examples/compound-statusline.svg) |

### Other docs

- **[gotchas.md](gotchas.md)** — pitfalls that cost me time: whitespace collapse, `tspan` `opacity` flakiness, `calcMode` semantics, monospace alignment in SVG, etc.
- **[github-readme.md](github-readme.md)** — how to embed in a README: `<picture>` for light/dark, raw URL requirements, PNG fallback strategy.

## Compatibility

| Renderer | SMIL plays | Notes |
|---|---|---|
| Chrome / Edge / Safari / Firefox | ✅ | All modern desktop browsers |
| GitHub README (`<img src="*.svg">`) | ✅ | Animations play; sanitizer keeps SMIL |
| npm package page | ✅ | Renders README via GitHub raw URL |
| VS Code Markdown preview | ✅ | Plays via embedded Webview |
| RSS readers / static-site previewers | ⚠️ | Many fall back to static first frame; ship a PNG inside `<picture>` |
| Image proxies that re-encode (rare) | ❌ | Some converters flatten SVG → PNG and lose animation |

## License

MIT. Copy, fork, remix.
