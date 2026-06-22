<p align="right"><a href="README.md">English</a> · <strong>中文</strong></p>

<p align="center">
  <img src="https://raw.githubusercontent.com/WaterTian/svg-motion-cookbook/main/examples/hero.svg" alt="svg-motion-cookbook" width="900"/>
</p>

> 手工编写**能在 GitHub 上播放的小型动画 SVG**的食谱 —— README 头图、状态徽章、流程图示。纯 SMIL，零 JS，零 CSS，零 toolchain。

> **关于上面这个 banner。** 那不是截图，而是一个 5KB 以内的 SVG 文件，把八个模式同时跑起来。字标用 `clipPath` 揭示（模式 3）、在相邻调色板色之间渐变（6）、光标离散闪烁（7）；八根柱子错峰启动（2）、每根跑一个带保持的循环（1）；右侧标签用 opacity 叠加切换文本（4）；tagline 里的 `plays` 在 `tspan` 上脉冲（5）；右上角小绿点每 6 秒心跳一次（8）。打开 [`examples/hero.svg`](examples/hero.svg) 看源码 —— 全程都是纯 SMIL，没有一行 JS 或 CSS。

---

## 30 秒上手

```bash
git clone https://github.com/WaterTian/svg-motion-cookbook
open svg-motion-cookbook/examples/01-loop-bar.svg
```

或者直接点下面表格里的任意示例 —— 每个都能在 GitHub 上原生播放。

## 为什么是这些约束

GitHub 在 README 里渲染 `<img src="*.svg">` 时会清洗 SVG，被剥掉的有：

- ❌ `<script>` — 剥
- ❌ CSS `@keyframes` / 外部样式表 — 剥
- ❌ Web Animations API — 需要 JS
- ✅ **SMIL**（`<animate>`、`<animateTransform>`、`<set>`）— 保留，浏览器照常播

想让动画真正在 GitHub README 里动起来 —— SMIL 是唯一可行的路。本食谱只讲 SMIL。

## 食谱目录

### 📘 [`patterns.md`](patterns.md) — 八个可复用模式

每个模式都给出：什么时候用、最小代码、可跑示例链接。

| # | 模式 | 示例 |
|---|---|---|
| 1 | 带保持的循环                             | [01-loop-bar.svg](examples/01-loop-bar.svg) |
| 2 | 错峰启动（多元素节奏感）                 | [02-staggered-bars.svg](examples/02-staggered-bars.svg) |
| 3 | clip-path 揭示（ASCII 块动画）           | [03-clip-reveal-text.svg](examples/03-clip-reveal-text.svg) |
| 4 | 通过 opacity 叠加切换文本内容            | [04-text-swap.svg](examples/04-text-swap.svg) |
| 5 | tspan + `fill-opacity` 脉冲              | [05-pulse-glyph.svg](examples/05-pulse-glyph.svg) |
| 6 | 颜色变换（`fill` 插值）                  | [06-color-shimmer.svg](examples/06-color-shimmer.svg) |
| 7 | 离散闪烁（终端光标手感）                 | [07-cursor-blink.svg](examples/07-cursor-blink.svg) |
| 8 | 单次周期心跳                             | [08-heartbeat.svg](examples/08-heartbeat.svg) |
| ★ | 八个模式组合（状态栏形式）               | [compound-statusline.svg](examples/compound-statusline.svg) |
| ★ | 八个模式组合（banner 形式）              | [hero.svg](examples/hero.svg) |

### ⚠️ [`gotchas.md`](gotchas.md) — 每个至少坑过我 15 分钟

空白折叠 · `tspan` 上 opacity 不可靠 · `calcMode` 语义 · `keyTimes` 单调性 · `<animate>` 必须是子元素 · 等宽对齐 · 清洗器规则 · 文件大小阈值。

### 📦 [`github-readme.md`](github-readme.md) — 嵌入指南

`raw.githubusercontent.com` URL 强制要求 · `<picture>` 实现亮/暗主题 · PNG 回退策略 · 缓存清除 query string · 图片代理的大小限制。

## 渲染与截图

```bash
# 在 t=2000ms 抓一帧（用作缩略图 / PNG 回退）
./scripts/render.sh examples/01-loop-bar.svg 2000 /tmp/out.png

# 在一个周期内抓多帧（可视化校对）
./scripts/render-frames.sh examples/compound-statusline.svg
```

两个脚本都基于 **headless Chrome 的 `--virtual-time-budget`** —— 这是把 SMIL 时钟推进到精确时刻、抓取那一帧的关键开关。[`examples/hero.svg`](examples/hero.svg) 的设计和校对就靠这套工具完成。

## 兼容性

| 渲染场景 | SMIL 能播 | 备注 |
|---|---|---|
| Chrome / Edge / Safari / Firefox | ✅ | 现代桌面浏览器全支持 |
| GitHub README（`<img src="*.svg">`） | ✅ | 动画照常播，清洗器保留 SMIL |
| npm 包页面 | ✅ | npm 直接读 GitHub raw URL |
| VS Code Markdown 预览 | ✅ | 内嵌 Webview 播放 |
| RSS 阅读器 / 静态站预览器 | ⚠️ | 常回退成静态首帧；建议套 `<picture>` 加 PNG 兜底 |
| 重编码的图片代理（少见） | ❌ | 某些转换器把 SVG 拍扁成 PNG，动画丢失 |

## 案例展示

用上这套模式的项目：

- **[cc-hud](https://github.com/WaterTian/cc-hud)** — Claude Code 的终端风格状态栏。它的动画 README 头图同时用到了带保持的循环、错峰启动、clip-reveal、文本切换、颜色变换、光标闪烁多个模式。

如果你在自己的项目里用上了，欢迎来一条链接，我把它加进来。

## License

MIT，随便复制、fork、改。
