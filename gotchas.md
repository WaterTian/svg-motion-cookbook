# Gotchas

Pitfalls discovered while authoring real animated SVGs for GitHub READMEs. Each costs at least 15 minutes the first time.

---

## Whitespace inside `<text>` collapses by default

`<text>A   B</text>` renders as `A B` — the three spaces collapse to one. To preserve literal whitespace:

```xml
<text xml:space="preserve">A   B</text>
```

`xml:space="preserve"` on the parent `<text>` propagates to all child `<tspan>`. Without it, leading/trailing whitespace is also stripped, which silently shifts alignment in monospace layouts.

`xml:space` is technically deprecated in favor of the CSS `white-space` property — but `white-space` isn't a presentation attribute in SVG 1.1, so `xml:space="preserve"` is still the most portable option.

---

## `opacity` on `<tspan>` is unreliable — use `fill-opacity`

```xml
<!-- ❌ Sometimes ignored (notably older Firefox) -->
<tspan opacity="0">hidden</tspan>

<!-- ✅ Works everywhere -->
<tspan fill-opacity="0">hidden</tspan>
```

`opacity` on the parent `<text>` works fine. Only `<tspan>` has the issue. When animating, prefer `attributeName="fill-opacity"` for the same reason.

---

## `calcMode` changes the meaning of `values`

- **`linear` (default)** — interpolates linearly between adjacent `values`. Good for bars, colors, fades.
- **`discrete`** — snaps to each value at its keyTime, no interpolation. Required for content-swap patterns and crisp blink effects.
- **`paced`** — distributes values evenly along the timeline regardless of `keyTimes`. Rarely useful.
- **`spline`** — Bezier easing. Needs `keySplines` (4 control points per segment). Powerful but verbose.

Most cookbook patterns use `linear`. The text-swap and cursor-blink patterns use `discrete`. **Mixing modes within one animation is impossible** — it's all-or-nothing per `<animate>`.

---

## `keyTimes` must be monotonically non-decreasing — and start at 0, end at 1

```xml
<!-- ❌ Out of order — animation is undefined -->
keyTimes="0;0.5;0.3;1"

<!-- ✅ Two adjacent identical keyTimes are legal — creates an instant jump -->
keyTimes="0;0.5;0.5;1"
```

Two adjacent identical keyTimes with different `values` produce a step transition at that point. This is how you do "hold then snap":

```xml
values="0;100;100;0"
keyTimes="0;0.4;0.4;1"
<!-- 0 → 0.4: rise to 100; instant snap to 100 at 0.4; hold; back to 0 over rest -->
```

If `keyTimes` doesn't begin at exactly `0` and end at exactly `1`, behavior is implementation-defined. Always include both endpoints.

---

## SMIL `<animate>` must be a **child** of the animated element

```xml
<!-- ❌ Standalone animate is silently ignored -->
<rect id="bar" width="0"/>
<animate xlink:href="#bar" attributeName="width" .../>

<!-- ✅ Inside the target -->
<rect width="0">
  <animate attributeName="width" .../>
</rect>
```

The `xlink:href` form exists in SMIL spec but **GitHub's sanitizer strips it**. Always inline `<animate>` inside the target element.

---

## Monospace alignment in SVG

When laying out terminal-style text, eyeball character widths can be off enough to break alignment. Approximate widths for common monospace fonts (rendered in browsers, font-size in px):

| Font | Char width ratio | At 13px | At 15px | At 16px |
|---|---|---|---|---|
| SF Mono | 0.61 | 7.9 | 9.2 | 9.8 |
| Menlo | 0.61 | 7.9 | 9.2 | 9.8 |
| Cascadia Mono | 0.60 | 7.8 | 9.0 | 9.6 |
| ui-monospace (system fallback) | 0.59–0.62 | varies | varies | varies |

For pixel-perfect alignment across renderers, **pad with leading spaces** so all swap-targets share the same character count, instead of pixel-positioning each variant separately.

---

## GitHub strips `<script>` and CSS

The README image sanitizer removes any `<script>`, external stylesheet `<link>`, `style` elements with `@import`, and event-handler attributes (`onclick`, `onload`). Inline `style` attributes are kept. SMIL `<animate>` is kept. So if your SVG plays standalone in the browser but goes static on GitHub, suspect a stripped element first.

`<filter>` and `<linearGradient>` are kept and very useful for richness without animation cost.

---

## File size matters past ~200KB

GitHub serves SVGs through its image proxy (`camo.githubusercontent.com`). Empirically, SVGs under 200KB load reliably; above that, proxy occasionally returns a static thumbnail instead of the live SVG. Keep the file lean — most of the cookbook examples are under 4KB; the compound example is under 10KB.

---

## "Snapshot for fallback PNG" is harder than it looks

If you ship `<picture><source srcset="x.svg"><img src="x.png"></picture>`, the PNG fallback should look reasonable on its own. Choose a virtual-time-budget that captures all animated elements at their "filled" or "informative" state, not in the middle of a transition. For the cookbook patterns, **`--virtual-time-budget=3500`** (3.5s into a 6s cycle) usually catches everything past its initial reveal.

```bash
./scripts/render.sh examples/compound-statusline.svg 3500 out.png
```

---

## Animations don't restart on browser tab change

Modern browsers pause SMIL animations when a tab is backgrounded and resume from where they paused. This is correct behavior but can confuse "is my animation broken?" testing. Always open a fresh tab if motion seems stuck.
