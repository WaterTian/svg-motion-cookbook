# Patterns

Eight building blocks. Each pattern is self-contained — copy the snippet, adjust constants, you're done. Examples live in `examples/`; open them in any browser to see motion.

---

## 1. Loop with hold phase

**What it does.** Animates an attribute through fill → hold → empty cycles forever. The trick is two adjacent `values` entries that are identical — that range becomes a held frame.

**When to use.** Progress bars, loaders, anything that should "fill, dwell, reset, repeat."

```xml
<rect x="20" y="20" width="0" height="14" fill="#a6e3a1" rx="2">
  <animate attributeName="width"
           values="0;160;160;0"
           keyTimes="0;0.22;0.85;1"
           dur="6s"
           repeatCount="indefinite"/>
</rect>
```

**Reading the timeline:**
- `0 → 0.22` (0s → 1.32s): fill from 0 to 160
- `0.22 → 0.85` (1.32s → 5.1s): hold at 160 (no movement)
- `0.85 → 1` (5.1s → 6s): empty back to 0
- Loops

Runnable: [examples/01-loop-bar.svg](examples/01-loop-bar.svg).

---

## 2. Staggered begin

**What it does.** Multiple instances of the same animation, each delayed by a different `begin`, so they fall out of lockstep and feel orchestrated.

**When to use.** Lists of bars / dots / cards that share one motion but shouldn't move in unison.

```xml
<g><rect ...><animate ... begin="0.2s" dur="6s" repeatCount="indefinite"/></rect></g>
<g><rect ...><animate ... begin="0.5s" dur="6s" repeatCount="indefinite"/></rect></g>
<g><rect ...><animate ... begin="0.8s" dur="6s" repeatCount="indefinite"/></rect></g>
<g><rect ...><animate ... begin="1.1s" dur="6s" repeatCount="indefinite"/></rect></g>
```

Pick offsets that are **smaller than the cycle but not divisors of it** — divisors create accidental phase locks.

Runnable: [examples/02-staggered-bars.svg](examples/02-staggered-bars.svg).

---

## 3. Clip-path reveal

**What it does.** Animates a `<clipPath>`'s rect width to "wipe" a visual into view, instead of animating the visual itself.

**When to use.** Whenever the thing you want to reveal is **not a single primitive** — for example, a string of Unicode block characters (`██████████`), an image, or a complex group. The clip wipe preserves the source aesthetic perfectly.

```xml
<defs>
  <clipPath id="reveal">
    <rect x="20" y="40" width="0" height="20">
      <animate attributeName="width"
               values="0;200;200;0"
               keyTimes="0;0.22;0.85;1"
               dur="6s" repeatCount="indefinite"/>
    </rect>
  </clipPath>
</defs>

<!-- Always-visible "track" underneath -->
<text x="20" y="55" fill="#45475a" font-family="monospace" font-size="18">░░░░░░░░░░</text>

<!-- Foreground revealed by the clip -->
<text x="20" y="55" fill="#a6e3a1" font-family="monospace" font-size="18"
      clip-path="url(#reveal)">██████████</text>
```

The track + clipped foreground composition is what gives cc-hud's progress bar its chunky look while still animating smoothly.

Runnable: [examples/03-clip-reveal-text.svg](examples/03-clip-reveal-text.svg).

---

## 4. Text-content swap via opacity overlay

**What it does.** Cycles through different `<text>` values in place — useful for tickers / counters. SMIL cannot animate text content directly; this works around the limitation by stacking N text elements at the same position and rotating their `opacity` with `calcMode="discrete"`.

**When to use.** Anywhere a number, label, or word should periodically update — counters, status indicators, value carousels.

```xml
<!-- Three values at the same x/y; each visible for 1/3 of the 3s cycle. -->
<text x="40" y="40" fill="#f9e2af" font-family="monospace" font-size="20">
  62%<animate attributeName="opacity" calcMode="discrete"
              values="1;0;1" keyTimes="0;0.33;1"
              dur="3s" repeatCount="indefinite"/>
</text>
<text x="40" y="40" fill="#f9e2af" font-family="monospace" font-size="20" opacity="0">
  63%<animate attributeName="opacity" calcMode="discrete"
              values="0;1;0;1;0" keyTimes="0;0.33;0.34;0.66;0.67"
              dur="3s" repeatCount="indefinite"/>
</text>
<text x="40" y="40" fill="#f9e2af" font-family="monospace" font-size="20" opacity="0">
  64%<animate attributeName="opacity" calcMode="discrete"
              values="0;1" keyTimes="0;0.66"
              dur="3s" repeatCount="indefinite"/>
</text>
```

**Two gotchas:**
1. `calcMode="discrete"` is essential — without it you get fades, which look like ghosts during overlap.
2. If the swapped values have different widths and they live inside flowing text, layout shifts. Pad with leading spaces (` 6%`, `13%`, `41%`) so each value is the same character width.

Runnable: [examples/04-text-swap.svg](examples/04-text-swap.svg).

---

## 5. tspan pulse with `fill-opacity`

**What it does.** Pulses a single inline glyph (inside a `<tspan>`) without affecting siblings.

**When to use.** Indicators inside a flowing line of text — a status dot, a "live" marker, an icon glyph that should breathe.

```xml
<text x="20" y="40" font-family="monospace" font-size="16" fill="#cdd6f4">
  status:
  <tspan fill="#94e2d5">◐
    <animate attributeName="fill-opacity"
             values="1;0.4;1" dur="1.6s" repeatCount="indefinite"/>
  </tspan>
  running
</text>
```

**Use `fill-opacity`, not `opacity`.** Animating `opacity` on a `<tspan>` is unreliable across renderers — Firefox in particular has historically ignored it. `fill-opacity` paints only the glyph fill and works everywhere.

Runnable: [examples/05-pulse-glyph.svg](examples/05-pulse-glyph.svg).

---

## 6. Color shimmer

**What it does.** Smoothly interpolates a `fill` (or `stroke`) between colors.

**When to use.** Brand text, headers, accent elements that should feel "alive" without distracting motion.

```xml
<text x="40" y="40" font-size="32" font-weight="600" font-family="ui-monospace,monospace"
      fill="#cba6f7">
  brand
  <animate attributeName="fill"
           values="#cba6f7;#e8d4ff;#cba6f7"
           dur="4s" repeatCount="indefinite"/>
</text>
```

Default `calcMode="linear"` interpolates RGB channels, so the transition is smooth. Pick palette neighbors — two distant colors interpolate through a muddy midpoint.

Runnable: [examples/06-color-shimmer.svg](examples/06-color-shimmer.svg).

---

## 7. Discrete blink

**What it does.** Snaps opacity between 1 and 0 at a fixed cadence — no fade, no easing.

**When to use.** Terminal cursors, "recording" indicators, anything that should look mechanical, not soft.

```xml
<text x="40" y="40" font-family="monospace" font-size="20" fill="#cdd6f4">
  ▎<animate attributeName="opacity"
            calcMode="discrete"
            values="1;0" keyTimes="0;0.5"
            dur="1.06s" repeatCount="indefinite"/>
</text>
```

**Why 1.06s?** That's the cadence of the macOS terminal cursor — anything in the 1.0–1.2s range reads as "terminal-like." Faster feels frantic, slower feels broken.

Runnable: [examples/07-cursor-blink.svg](examples/07-cursor-blink.svg).

---

## 8. Once-per-cycle heartbeat

**What it does.** Stays invisible most of the time, then flashes bright briefly. Pairs well with a longer cycle (e.g. `6s`).

**When to use.** "Live" / "alive" indicators that shouldn't dominate but should reassure the viewer that something is updating.

```xml
<circle cx="40" cy="40" r="4" fill="#a6e3a1" opacity="0">
  <animate attributeName="opacity"
           values="0;0;1;0.6;0"
           keyTimes="0;0.92;0.95;0.98;1"
           dur="6s" repeatCount="indefinite"/>
</circle>
```

The keyTimes pattern `0;LONG-HIDE;PEAK;DECAY;END` is the heartbeat shape: long silence → fast rise → slow fall.

Runnable: [examples/08-heartbeat.svg](examples/08-heartbeat.svg).

---

## Compound example

[compound-statusline.svg](examples/compound-statusline.svg) composes all eight patterns into a single terminal-style header — the architecture cc-hud uses. Open it side-by-side with this file to see how the individual recipes combine.
