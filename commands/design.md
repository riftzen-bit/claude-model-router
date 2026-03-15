---
name: design
description: Dispatch frontend/UI design tasks to Gemini 3.1 Pro with full project context and anti-slop enforcement. Gemini generates, Opus validates and applies.
---

# Gemini Design Dispatch

Route this frontend/UI task to Gemini 3.1 Pro for high-quality design generation.

## Step 1: Gather Project Context

Before dispatching, scan the project:

**1a. Detect project type:**
- Check package.json for framework (React, Next.js, Vue, Svelte, Astro)
- Check for plain HTML/CSS if no package.json
- Identify CSS approach: tailwind.config.* → Tailwind | *.module.css → CSS Modules | styled-components | plain CSS/Sass

**1b. Read relevant files** (include in Gemini prompt):
- Global styles / theme / design tokens (CSS variables, Tailwind config, theme files)
- Component being redesigned (if applicable)
- Layout/template wrapping the target component
- Any design system docs or style guides

**1c. Identify constraints:**
- Tailwind version: v3 (tailwind.config.js) vs v4 (CSS @theme directives)
- Existing color palette, typography, spacing scale
- Responsive breakpoints
- Dark mode support

## Step 2: Check Gemini Availability

Before building the prompt, verify Gemini is available:
- Run `command -v gemini` — if not found, fall back to Opus immediately
- Log: `[Design] gemini unavailable → opus fallback`
- If falling back: apply the same anti-slop design rules below when generating as Opus

## Step 3: Build Gemini Prompt

Construct a self-contained prompt with ALL context Gemini needs:

```
You are an elite frontend designer creating production-ready code.

AESTHETIC DIRECTION:
[Choose a bold direction — brutally minimal, retro-futuristic, organic/natural, luxury/refined, editorial/magazine, brutalist/raw, art deco/geometric, industrial/utilitarian. NEVER "generic modern".]

PROJECT:
- Framework: [detected framework]
- CSS: [detected CSS approach + version]
- Design tokens: [extracted from theme/config files]

EXISTING CODE:
---[filename]---
[file contents]
---end---

TASK:
[user's design request]

DESIGN RULES (mandatory — violating these is a failure):
- Choose distinctive, characterful fonts — NEVER Inter, Roboto, Arial, or system fonts as primary
- Use CSS variables for cohesive color themes — dominant colors with sharp accents
- Add atmosphere: gradient meshes, noise textures, geometric patterns, layered transparencies, grain overlays
- Animations must be purposeful — one orchestrated page load with staggered reveals, not scattered micro-interactions
- FORBIDDEN: purple/indigo gradients on white, generic 3-card grids, cookie-cutter heroes, predictable layouts, timid palettes
- FORBIDDEN: any pattern that looks "AI generated" or generic
- Use unexpected layouts: asymmetry, overlap, diagonal flow, grid-breaking elements, generous negative space
- WCAG 2.1 AA: 4.5:1 contrast (normal text), 3:1 (large text), semantic HTML, keyboard navigable, focus indicators
- Mobile-first: base styles for mobile, min-width media queries for larger screens
- Touch targets: minimum 44x44px
- All interactive elements must have visible focus indicators and ARIA labels if no visible text

OUTPUT:
- Return complete, ready-to-paste code with all imports
- Use the project's existing CSS approach (don't switch methods)
- Brief inline comments for non-obvious design decisions only
- If creating new files, specify the full file path as a header
```

## Step 4: Dispatch to Gemini

```bash
timeout 180 gemini -m gemini-3.1-pro-preview --sandbox false -p "[constructed prompt]"
```

- 180s timeout (design tasks produce more output than code tasks)
- `--sandbox false` allows Gemini to access project files for additional context
- If Gemini times out or fails: `[Route] design → gemini FAILED → opus fallback`

## Step 5: Opus Validation (before applying)

Review Gemini's output against this checklist:

| Check | Criteria |
|-------|----------|
| Syntax | Valid HTML/CSS/JSX for the target framework? |
| Anti-slop | No Inter/Roboto, no purple gradients, no generic layouts? |
| Accessibility | Semantic elements, 4.5:1 contrast (normal) / 3:1 (large), focus indicators, ARIA? |
| Responsive | Mobile-first, no fixed widths, no horizontal scroll potential? |
| Framework match | Uses project's CSS approach, not a different one? |
| Imports | All packages/fonts actually exist? No hallucinated dependencies? |
| Consistency | Matches existing design tokens/theme? |

If issues found: fix them directly — don't re-dispatch to Gemini.

## Step 6: Apply & Report

1. Write validated code to the correct file paths
2. Log: `[Design] user request → gemini (180s) → opus-validated → applied to [files]`
3. Remind user: "Check rendered output for visual verification — layout issues are silent"

## Fallback Behavior

Gemini may fail for several reasons:
- **Not installed**: `command -v gemini` fails → detected in Step 2
- **Auth expired**: OAuth token invalid → Gemini returns auth error
- **Timeout**: 180s exceeded → `timeout` kills process
- **Rate limited**: 429 response → retry after backoff or fall back

All failures → fall back to Opus. Log: `[Design] gemini [reason] → opus fallback`
Apply the same anti-slop design rules when generating as Opus.
