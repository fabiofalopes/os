---
title: "Deep Agents: Open Source Agent Harness"
source: "https://www.langchain.com/deep-agents"
author:
published:
created: 2026-09-06
description: "Deep Agents handles planning, context management, and subagent orchestration, so agents can run long, complex work like research and coding."
tags:
  - "clippings"
---
![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/69999dae51418243b721e2e3_Frame%202147255016.svg)

deepagents

## Build agents for complex, multi-step tasks

Deep Agents is an open source agent harness built for long-running tasks. It handles planning, context management, and multi-agent orchestration for complex work like research and coding.

## Why use Deep Agents?

### Designed for autonomous agents

Agents are taking on increasingly complex work over long time horizons, like research, coding, and multi-step workflows. Deep Agents provides the primitives for these patterns:

- **Break down complex objectives:** *Planning tools let agents decompose tasks, track progress, and adapt as they learn*
- **Delegate work in parallel:** *Spawn subagents for independent subtasks, each with isolated context*
- **Persist knowledge across sessions:** *Virtual filesystem stores system prompts, skills, and long-term memory*

[

Learn about the agent harness

](https://docs.langchain.com/oss/python/deepagents/harness)

![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/6999a0bed2f79ae5467ae2be_Eval_2-2.avif) ![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/69982183c78f464d8485ff43_glow.avif)

### Native context management

Context management is critical for long-running agents, and hard to get right. Deep Agents includes middleware that helps agents compress conversation history, offload large tool results, isolate context with subagents, and use prompt caching to reduce latency and cost.

[

Context management with deep agents

](https://blog.langchain.com/context-management-for-deepagents/)

![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/6999a0be575e3305fd8a3d58_dd71ede3670662aea274e86aa82ef40e_Eval_2-1.avif) ![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/69982183c78f464d8485ff43_glow.avif)

### Model neutral with maximum configurability

Deep Agents is a batteries-included, general purpose agent harness. Use any model provider, manage state, and add human-in-the-loop when you need it. Tracing and deployment work natively with LangSmith.

[

Deploy deep agents with LangSmith

](https://www.langchain.com/langsmith-platform)

![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/6999a0bef56ac8c7eb734c1d_de3e8cf95f8471b43cbae824c0fe3609_Eval_2.avif) ![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/69982183c78f464d8485ff43_glow.avif)

### Build with dcode

**dcode is an open-source terminal coding agent built on the Deep Agents SDK. With dcode you can bring your own model, customize the agent harness, and control how code execution is approved, traced, and run.**

[

Learn more about dcode

](https://www.langchain.com/dcode)

![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/6999a0bed97d88401ea13ab5_graphic.avif) ![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/69982183c78f464d8485ff43_glow.avif)

#### Deep Agents

[![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/69a047c394793b4a6b6a7a45_4486f48551ac550292df72164c412c24_module3.avif)](https://academy.langchain.com/courses/foundation-introduction-to-deepagents)

Learn how to build long-running agents for complex workflows with Deep Agents. You’ll explore what an agent harness is, how it accelerates development, and how to use LangSmith to improve your agents.

[

Take the course

](https://academy.langchain.com/courses/foundation-introduction-to-deepagents)

![](https://cdn.prod.website-files.com/65b8cd72835ceeacd4449a53/6999965e520db9b0ccefdaa3_langchain%20vis.png)