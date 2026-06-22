# Embedding in a GitHub README

How to wire an animated SVG into a README so it actually plays.

## The minimum that works

```markdown
![demo](https://raw.githubusercontent.com/USER/REPO/main/preview.svg)
```

Or, more controllably:

```html
<p align="center">
  <img src="https://raw.githubusercontent.com/USER/REPO/main/preview.svg"
       alt="preview" width="900" />
</p>
```

Two requirements:
1. **Use the `raw.githubusercontent.com` URL**, not the `github.com/.../blob/...` URL. The blob URL serves an HTML page; the raw URL serves the SVG as `image/svg+xml`, which lets the browser play SMIL.
2. **No `<script>` or external CSS in the SVG.** GitHub's sanitizer strips both. SMIL `<animate>` is preserved.

## Light / dark theme variants

If you want different palettes for GitHub light vs dark themes, ship two SVGs and use `<picture>`:

```html
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)"  srcset="https://raw.githubusercontent.com/USER/REPO/main/preview-dark.svg" />
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/USER/REPO/main/preview-light.svg" />
    <img src="https://raw.githubusercontent.com/USER/REPO/main/preview-dark.svg" alt="preview" width="900" />
  </picture>
</p>
```

The `<img>` inside `<picture>` is the fallback for any browser that doesn't understand `<source media>` — pick the variant that looks decent on either theme as the default.

## PNG fallback (for non-SVG viewers)

Some renderers don't load `*.svg` — old RSS readers, certain markdown previewers, npm's older renderer. To stay covered, ship a PNG snapshot alongside and put it inside `<picture>` as the ultimate fallback:

```html
<picture>
  <source srcset="https://raw.githubusercontent.com/USER/REPO/main/preview.svg"
          type="image/svg+xml" />
  <img src="https://raw.githubusercontent.com/USER/REPO/main/preview.png"
       alt="preview" width="900" />
</picture>
```

The `type="image/svg+xml"` on the `<source>` lets clients that don't support SVG skip straight to the PNG `<img>`.

Generate the PNG with the cookbook's render script — pick a virtual-time-budget that captures the animation at a representative moment:

```bash
./scripts/render.sh preview.svg 3500 preview.png
```

## Caching

GitHub caches images aggressively via its image proxy. After a push, the live SVG may take **a few minutes to refresh** in the README view, and pre-warmed image caches in clients (browser, OS, even some markdown previews) may serve the previous file longer.

Cache-bust by appending a query string:

```html
<img src="https://raw.githubusercontent.com/USER/REPO/main/preview.svg?v=2" />
```

Bump `v` on each significant update.

## Size limits

| Limit | Why |
|---|---|
| **~200 KB** | Above this, GitHub's image proxy sometimes flattens to PNG, losing animation |
| **5 MB** | Hard ceiling for `raw.githubusercontent.com` — beyond this the response 404s |
| **~5–10 KB ideal** | Real-world cookbook SVGs land here; loads instantly |

Compressing SMIL SVGs by hand is awkward (minifiers can break `keyTimes` attributes). The right knob is **fewer animated elements** — every `<animate>` is overhead.

## npm package page

npm's README renderer reads from your GitHub raw URL. Animated SVGs **play on the npm package page** the same way they do on GitHub, with no extra configuration. Same `<picture>` / fallback logic applies.

## What doesn't work

- Local-relative paths (`./preview.svg`) — npm and certain renderers can't resolve them. Always use absolute `raw.githubusercontent.com` URLs.
- SVG embedded as a data URL — GitHub re-encodes and may break it. Always link to a file.
- `<iframe>` — GitHub Markdown strips iframes entirely.
