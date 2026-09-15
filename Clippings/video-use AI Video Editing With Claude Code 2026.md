---
title: "video-use: AI Video Editing With Claude Code 2026"
source: "https://explainx.ai/blog/video-use-claude-code-ai-video-editor-guide-2026"
author:
  - "[[Yash Thakker]]"
published: 2026-06-29
created: 2026-09-15
description: "video-use turns Claude Code into a video editor — no Premiere Pro needed. Drop footage in a folder, describe the cut, get final.mp4. Full setup guide."
tags:
  - "clippings"
---
Adobe Premiere Pro costs $60/month and takes hundreds of hours to master. DaVinci Resolve is free but has a steep learning curve. Final Cut Pro is Mac-only and $300 upfront.

For a large class of video editing tasks — cutting filler words, removing dead air, color grading, burning subtitles, combining multiple takes into a launch video — none of that complexity is necessary anymore.

**video-use** is an open-source tool from the [browser-use](https://github.com/browser-use?ref=explainx) team that turns Claude Code into a video editor. You drop raw footage in a folder, describe what you want, and get `edit/final.mp4` back. No timeline. No menus. No NLE.

11.6k GitHub stars in roughly two months. MIT license. Here is how it works and how to set it up.

## What video-use Actually Does

video-use is a **skill** — a self-contained plugin that registers with Claude Code (or Codex, Hermes, Openclaw) and gives it video editing capabilities via shell access.

It handles:

- **Filler word removal** — cuts "umm", "uh", false starts, and dead space between takes with 30ms audio fades at every cut so there is no pop
- **Auto color grading** — warm cinematic, neutral punch, or any custom ffmpeg chain applied per segment
- **Subtitle generation** — burned in your style (2-word UPPERCASE chunks by default, fully configurable)
- **Animation overlays** — generates HyperFrames, Remotion, Manim, or PIL animations in parallel sub-agents, one per animation block
- **Self-evaluation** — renders, checks every cut boundary against the source, fixes issues and re-renders before showing you anything (max 3 tries)
- **Session memory** — writes `project.md` so next week's session picks up exactly where it left off

The output lands in `<your_videos_dir>/edit/` — the skill directory stays clean.

## The Core Insight: Read Video as Text

The LLM **never watches the video**. It reads it. For open-ended video Q&A (not editing), see **[Can LLMs Watch a Video?](https://explainx.ai/blog/can-llms-watch-video-claude-gemini-solutions-2026)** — scene-aware frame packs, Gemini native upload, and **claude-real-video** compared.

Traditional frame-based AI video approaches dump thousands of frames as images — 30,000 frames × 1,500 tokens = 45 million tokens of visual noise per minute of footage. That is why they are slow, expensive, and miss context.

video-use does what [browser-use does for web browsing](https://explainx.ai/blog/ai-plays-geoguessr-browser-use-v4-visual-geolocation-2026): instead of showing the LLM raw pixels, it gives it a structured representation. For the web, that is the DOM. For video, that is the transcript.

**Layer 1 — Audio transcript (always loaded).** One ElevenLabs Scribe call per source clip gives word-level timestamps, speaker diarization (who is speaking), and audio events like `(laughter)` and `(applause)`. Every take packs into a single ~12KB markdown file:

```markdown
## C0103  (duration: 43.0s, 8 phrases)
  [002.52-005.36] S0 Ninety percent of what a web agent does is completely wasted.
  [006.08-006.74] S0 We fixed this.
```

This is the LLM's primary editing surface. It can reason over word boundaries, identify the best take of a phrase, detect false starts before the word ends, and place cuts at exact millisecond timestamps — all from text.

**Layer 2 — Visual composite (on demand).** When the LLM needs to compare a close-up cut or sanity-check an ambiguous pause, it calls `timeline_view` — a tool that generates a filmstrip + speaker track + waveform + word labels PNG for any time range. It is called only at decision points, not for every frame.

The result: the same quality of edit decision a human editor makes from scrubbing, but derived from 12KB of text and a handful of targeted images.

## The Full Pipeline

```
Transcribe ──> Pack ──> LLM Reasons ──> EDL ──> Render ──> Self-Eval
                                                              │
                                                              └─ issue? fix + re-render (max 3x)
```

1. **Transcribe**: ElevenLabs Scribe processes each source clip
2. **Pack**: All takes merge into `takes_packed.md` — one file the LLM holds in context
3. **LLM Reasons**: Reads the transcript, proposes an edit strategy, **waits for your approval**
4. **EDL**: Generates an Edit Decision List — precise in/out points per clip in JSON
5. **Render**: ffmpeg executes the EDL, applies color grade, burns subtitles
6. **Self-Eval**: Runs `timeline_view` on the rendered output at every cut boundary. Catches visual jumps, audio pops, hidden subtitles. If issues found: fix + re-render. You see the preview only after it passes.

The "ask → confirm → execute → self-eval → persist" sequence is the same pattern as [Claude Code's agentic coding loop](https://explainx.ai/blog/anthropic-claude-code-expertise-research-agentic-coding-2026) — the agent never takes a destructive action (overwriting footage, finalizing render) without strategy approval first.

## Setup Guide

### Prerequisites

- Claude Code installed (or Codex, Hermes, Openclaw)
- Python 3.11+, `uv` or pip
- ffmpeg (`brew install ffmpeg` on Mac, `apt install ffmpeg` on Linux)
- ElevenLabs API key (free tier available at `elevenlabs.io/app/settings/api-keys`)

### One-Command Setup (Recommended)

Paste this into Claude Code:

```
Set up https://github.com/browser-use/video-use for me.

Read install.md first to install wire up ffmpeg, register the skill with whichever agent you're running under, and set up the ElevenLabs API key — ask me to paste it when you need it. Then read SKILL.md for daily usage, and always read helpers/ because that's where the editing scripts live. After install, don't transcribe anything on your own — just tell me it's ready and wait for me to drop footage into a folder.
```

Claude Code handles: clone, dependencies, skill registration, prompts you once for the ElevenLabs API key.

### Manual Setup

```bash
# 1. Clone and symlink into your agent's skills directory
git clone https://github.com/browser-use/video-use ~/Developer/video-use
ln -sfn ~/Developer/video-use ~/.claude/skills/video-use        # Claude Code
# ln -sfn ~/Developer/video-use ~/.codex/skills/video-use       # Codex

# 2. Install Python deps
cd ~/Developer/video-use
uv sync                         # or: pip install -e .

# 3. Install system deps
brew install ffmpeg              # required
brew install yt-dlp             # optional — for downloading online sources

# 4. API key
cp .env.example .env
# Edit .env and add: ELEVENLABS_API_KEY=your_key_here
```

### Your First Edit Session

```bash
cd /path/to/your/videos
claude    # opens Claude Code in that folder
```

Then in Claude Code:

```
edit these into a launch video
```

The agent will:

1. Inventory the source files in the folder
2. Propose an edit strategy (which takes to use, what to cut, suggested structure)
3. **Wait for your approval** before touching anything
4. Execute the EDL via ffmpeg
5. Self-evaluate the render
6. Show you `edit/final.mp4`

For an always-on setup (editing from your phone or via Telegram), the team recommends running through [Browser Use Box](https://browserusebox.com/?ref=explainx) on a VPS.

### Subtitles

Default: 2-word UPPERCASE chunks burned at the bottom. To customize, describe your style in the session:

```
use sentence-case subtitles, white text with black outline, position at top
```

The agent translates your description into ffmpeg `drawtext` filter parameters.

### Animation Overlays

video-use supports four animation engines:

table · 3 cols

| Engine | Best for | Notes |
| --- | --- | --- |
| **HyperFrames** | Motion graphics, lower thirds | Default recommendation |
| **Remotion** | React-based frame-accurate animations | Requires Node.js |
| **Manim** | Mathematical/technical visualizations | Requires Python Manim |
| **PIL** | Simple image overlays, static graphics | Fastest, no extra deps |

Animations run as parallel sub-agents — one per animation block — so a video with five animated sections generates all five concurrently instead of sequentially.

## video-use vs. Premiere Pro vs. DaVinci Resolve

table · 4 cols

|  | video-use | Adobe Premiere Pro | DaVinci Resolve |
| --- | --- | --- | --- |
| **Price** | Free (MIT) | $60/month | Free / $295 (Studio) |
| **Interface** | Natural language | Timeline GUI | Timeline GUI |
| **Learning curve** | Minutes | Weeks–months | Weeks |
| **Filler word removal** | Automatic | Manual or plugin | Manual or scripted |
| **Frame-precise control** | Via description | Yes | Yes |
| **Color grading** | Auto (ffmpeg presets) | Full professional suite | Industry-leading |
| **Subtitle generation** | Automatic | Via plugin/AI | Auto-caption feature |
| **Animation overlays** | Remotion / Manim / PIL | After Effects integration | Fusion (built-in) |
| **Self-evaluation** | Built-in | Manual preview | Manual preview |
| **Session memory** | project.md | Project files | Project files |
| **Best for** | Fast rough cuts, filler removal, launch videos | Professional broadcast, film | Color work, feature-length |

For **talking head content, YouTube tutorials, podcast clips, and launch videos** — video-use matches or beats the speed of an experienced Premiere Pro editor on the tasks that consume 80% of editing time (filler removal, take selection, subtitle burning). For **color work, complex motion graphics, and frame-precise creative cuts**, Premiere Pro and DaVinci Resolve remain stronger.

This mirrors how [Claude Code vs. traditional coding tools](https://explainx.ai/blog/anthropic-claude-code-expertise-research-agentic-coding-2026) plays out — agents win on repetitive, well-defined tasks; humans + traditional tools win on open-ended creative decisions.

## Use Cases That Work Well

**Launch and product videos**: Multiple takes, redundant sentences, filler words to cut. The LLM picks the cleanest take of each phrase, cuts dead air, grades warm/cinematic, burns subtitles. This is exactly the use case [Thariq's Claude Code Fable 5 launch video pipeline](https://explainx.ai/blog/fable-5-edited-own-launch-video-thariq-claude-code-2026) ran — same ffmpeg + Remotion + transcript approach, now packaged as a shareable skill.

**Podcast clip generation**: Drop a 90-minute recording, ask for the five best 90-second clips for social. The agent reads the full transcript, identifies the most quotable moments, and renders clips with subtitles.

**Tutorial screen recordings**: Cut dead pauses between steps, add callout animations over specific regions (Manim overlays), burn chapter markers as subtitle events.

**Interview editing**: Multi-speaker diarization from ElevenLabs tells the agent who is speaking when. It can cut between speakers based on content flow, not just silence detection.

**Batch processing**: Point the agent at a folder of 20 videos and ask for subtitle-burned versions of all of them. Runs sequentially; session memory tracks which are done.

## Design Rules Worth Knowing

SKILL.md documents 12 hard production rules the agent enforces regardless of creative direction:

1. **Always read `helpers/`** before every session — that is where editing scripts live
2. **Never touch footage until strategy is approved**
3. **30ms audio fades on every cut** — non-negotiable, prevents pops
4. **Self-eval before preview** — you never see a broken render
5. **Outputs go in `edit/` only** — sources are never modified
6. **Session memory in `project.md`** — next session reads it first
7. **Ask before downloading anything** (yt-dlp is optional)
8. **Never transcribe without an ElevenLabs call** — no hallucinated word timings
9. **One animation sub-agent per block** — parallelized
10. **Inventory sources before strategy** — no assumptions about what exists
11. **Propose, wait, execute** — three-step sequence, always
12. **Re-render max 3× on self-eval failure** — then surface the issue to the user

The philosophy: 12 rules for production correctness, artistic freedom for everything else.

## Connection to the Broader Agentic Video Ecosystem

video-use sits in the same agentic video space as [ViMax](https://explainx.ai/blog/vimax-agentic-video-generation-complete-guide-2026) (which generates video from scripts using AI models) and [Kling/Sora/Wan 2.5](https://explainx.ai/blog/video-generation-ai-sora-runway-kling-complete-guide-2026) (which generate video from text or image prompts). The distinction:

- **ViMax / Kling / Sora** — *generate* video from scratch using AI models
- **video-use** — *edits* existing raw footage using an LLM + ffmpeg

These are complementary. You might generate a product demo clip with Kling, shoot talking-head footage yourself, then bring both into video-use to cut and composite the final video.

For [loop engineering patterns](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026), video-use's self-eval loop is a good example of a production-correct agent loop: structured output (EDL JSON) → deterministic execution (ffmpeg) → automated verification → conditional retry.

---

## Quick Reference

table · 2 cols

| Task | Command in session |
| --- | --- |
| First edit | `edit these into a launch video` |
| Specific style | `keep all the takes, just remove filler words and grade warm` |
| Subtitles only | `burn white sentence-case subtitles, no other edits` |
| Social clips | `find the 3 best 90-second clips for Instagram` |
| Animation | `add a lower-third title animation for each speaker` |
| Download + edit | `download [URL] and edit into a 3-minute summary` |

## Related Reading

- [HyperFrames: HeyGen's HTML-to-video framework](https://explainx.ai/blog/hyperframes-heygen-html-to-video-ai-agents-2026) — The HTML/GSAP animation-overlay engine video-use's sub-agents can call, covered in depth
- [Diffusion Studio: video editing as code for AI agents](https://explainx.ai/blog/diffusion-studio-open-source-video-editor-as-code-august-2026) — Makes the timeline itself a JSX/TS program, the same legible-intermediate-representation idea video-use applies with EDL JSON
- [Fable 5 Edited Its Own Launch Video With Claude Code](https://explainx.ai/blog/fable-5-edited-own-launch-video-thariq-claude-code-2026) — The same transcript + ffmpeg + Remotion pipeline that video-use packages as a shareable skill
- [ViMax: Agentic Video Generation Guide](https://explainx.ai/blog/vimax-agentic-video-generation-complete-guide-2026) — The complementary tool for generating video from scratch
- [Video Generation AI: Sora, Runway, Kling Complete Guide](https://explainx.ai/blog/video-generation-ai-sora-runway-kling-complete-guide-2026) — Where generated footage comes from before you edit it in video-use
- [Claude Code Expertise: Research on Agentic Coding](https://explainx.ai/blog/anthropic-claude-code-expertise-research-agentic-coding-2026) — How the underlying agent platform powers video-use
- [Loop Engineering With Claude Code](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026) — The self-eval loop pattern video-use uses for reliable renders
- [OpenShot 4.0: local AI masking and color grading](https://explainx.ai/blog/openshot-4-0-local-ai-video-editor-august-2026) — GPLv3 NLE for capture, scopes, and offline ONNX masks when you need a timeline UI alongside agent edits

**Official resources:**

- [video-use GitHub](https://github.com/browser-use/video-use?ref=explainx) — MIT license, 11.6k stars
- [SKILL.md](https://github.com/browser-use/video-use/blob/main/SKILL.md?ref=explainx) — Full production rules and editing craft
- [install.md](https://github.com/browser-use/video-use/blob/main/install.md?ref=explainx) — Dependency installation and skill registration
- [ElevenLabs Scribe API](https://elevenlabs.io/docs/api-reference/speech-to-text?ref=explainx) — The transcription engine (required)
- [browser-use/browser-use](https://github.com/browser-use/browser-use?ref=explainx) — The parent project

*Feature details reflect video-use as of the main branch at June 29, 2026. The project is under active development — check the GitHub README for the latest capabilities.*