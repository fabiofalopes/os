---
tags:
  - organization
  - migration
  - planning
date: 2026-07-02
---

# Organization Plan

Clean up `~/` from 60+ entries to just what matters.

---

## Agent Harness — Leave in Place

These paths are hardcoded by the tools. Don't move them.

```
~/.hermes/         ← 561M — agent data, state.db, skills
~/.opencode/       ← 160M — opencode binary + config
~/.config/opencode/ ← 75M — agents, skills, themes, runbooks
~/.claude/         ← 19M — Claude Code sessions
~/.openclaude/     ← 13M — OpenClaude sessions
~/opencode-sessions/ ← 6.1M — exported transcripts
```

---

## Projects → `~/code/`

Get project dirs out of `~/` root into one place.

```
~/code/
├── diane-agent-kit/
├── camera-server/
├── m5stack-dial/
├── pi-orchestrator/
├── claude-dashboard/
├── rpi-net/              ← docs + scripts only (lab/ in cold storage)
└── shared-workspace/     ← from shared-local/
```

---

## Scripts → `~/bin/`

Consolidate all custom scripts into one place already on `$PATH`.

```
~/bin/
├── claude-deepseek          ← 25+ claude-ollama wrappers
├── claude-deepseek-flash
├── claude-ollama-*
├── hermes-bridge
├── pitemp
├── aapt2 / aapt2-wrapper
├── arduino-cli
└── myscripts/               ← 60+ scripts from .myscripts/
```

---

## Dotfiles → `~/dotfiles/` (git-tracked)

One git repo to rule them all. Symlink into place.

```
~/dotfiles/
├── zsh/
│   ├── .zshrc
│   ├── .zprofile
│   └── .bashrc.d/
├── tmux/
│   ├── .tmux.conf
│   ├── .tmux.conf.local
│   └── plugins/             ← .tmux/ plugins directory
├── shell/
│   ├── .profile
│   ├── .bashrc
│   └── .bash_logout
├── ssh/
│   └── known_hosts
├── README.md
```

Symlink command:
```bash
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
```

---

## Agent Configs — Keep at `~/`

These are JSON configs that Claude/OpenClaude read from `~/`.

```
~/.claude.json
~/.claude.json.bak
~/.openclaude.json
~/.openclaude-profile.json
~/.npmrc
~/.face
```

---

## Misc Tool Configs → `~/archive/`

Small clutter from Pi tools. Don't need to live in `~/` root.

```
~/archive/
├── .agents/
├── .pi/
├── .slim/
├── .chelper/
├── .objection/
├── .mitmproxy/
├── .omo/
└── .android/
```

---

## Result

Before — `ls -la ~/` is 60+ entries of mystery:

```
.agents/  .android/  .arduino15/  .bash_history  .bash_logout  .bashrc
.bashrc.d/  .bashrc.original  .bun/  .cache/  .chelper/  .claude/
.claude.json  .claude.json.bak  .claude.json.tmp.*  .config/
Desktop/  .face/  .face.icon/  .gitconfig  .gnupg/  .hermes/
.java/  .local/  .mitmproxy/  .moshi/  .myscripts/  .npm/
.npm-global/  .npmrc  .objection/  .omo/  .opencode/  .openclaude/
.openclaude.json  .openclaude-profile.json  .pi/  .profile  .slim/
.ssh/  .sudo_as_admin_successful  .tmux/  .tmux.conf  .tmux.conf.local
.vim/  .viminfo  .wget-hsts  .zprofile  .zsh_history  .zshrc
```

After:

```
~/.hermes/          ← agent harness
~/.opencode/
~/.config/opencode/
~/.claude/
~/.openclaude/
~/.claude.json      ← agent configs
~/.openclaude.json
~/code/             ← projects
~/bin/              ← scripts
~/dotfiles/         ← git-tracked configs
~/archive/          ← misc tool configs
~/rpi-backup/       ← backup artifacts
```

---

## Related

- [[pi-backup-session-2026-07-02]]
