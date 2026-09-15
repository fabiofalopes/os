---
title: "Set up AEM Agent Skills | Adobe Experience Manager as a Cloud Service"
source: "https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/agent-skills"
author:
published: 2026-06-16
created: 2026-09-15
description: "Learn how to set up AEM Agent Skills for AI-assisted development."
tags:
  - "clippings"
---
## Set up AEM Agent Skills

Learn how to set up AEM Agent Skills for AI-assisted development.

When you ask a coding agent through an AI-powered IDE to work on AEM development tasks, it can use **AEM Agent Skills** procedural guidance from Adobe instead of relying only on generic model training or whatever it can infer from your repository alone.

Adobe provides the AEM Agent Skills via the [Adobe Skills](https://github.com/adobe/skills) repository. Also see the [AI-assisted development](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/overview) for how Adobe helps with AI-assisted development.

In this tutorial, you install the skills on a local clone of the [WKND Sites Project](https://github.com/adobe/aem-guides-wknd). You can use the same steps for your own AEM as a Cloud Service project.

<iframe src="https://video.tv.adobe.com/v/3484940/?learn=on&amp;enablevpops" allowfullscreen="" allow="encrypted-media" title="Content from video.tv.adobe.com"></iframe>

Transcript

## Prerequisites

To follow this tutorial, you need the following:

- A local clone of the [WKND Sites Project](https://github.com/adobe/aem-guides-wknd) or your own AEM as a Cloud Service project.
- An AI-powered IDE such as Cursor, or Visual Studio Code with GitHub Copilot.

## Install AEM Agent Skills

Install AEM Agent Skills with the `npx` command (requires [Node.js](https://nodejs.org/) so `npx` is available). For other install options, for example, Claude Code plugins or the GitHub CLI extension, see the [Installation](https://github.com/adobe/skills/tree/main#installation) section in the Adobe Skills repository.

1. Clone the [WKND Sites Project](https://github.com/adobe/aem-guides-wknd) locally:
	```shell
	$ git clone https://github.com/adobe/aem-guides-wknd.git
	```
2. Open the cloned project in your AI-powered IDE (for example, Cursor) and open the integrated terminal.  
	![Open the terminal](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/media_10d375890874f2202a960a49f29b84ef449cad656.png?width=750&format=webply&optimize=medium)
3. Run the following command to add AEM Agent Skills for Cursor:
	```shell
	$ npx skills add https://github.com/adobe/skills/tree/main/plugins/aem/cloud-service --agent cursor
	```
	For other agent types, see the [Installation](https://github.com/adobe/skills/tree/main#installation) section in the Adobe Skills repository.
4. When prompted, choose which AEM Agent Skills to install.  
	![Select which AEM Agent Skills to install](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/media_151a9ff66597e77fe8212c63bb4971d654dce384e.png?width=750&format=webply&optimize=medium)
	Select the **ensure-agents-md** skill so the installer can create **AGENTS.md** and **CLAUDE.md** files at the repository root. That bootstrap skill inspects your project, for example, the root `pom.xml` and modules, and generates tailored agent guidance.
	If **AGENTS.md** already exists, it is **not** overwritten.
5. Choose the installation scope. For this walkthrough, the **Project** scope is typical so skill files live in the repo.  
	![Select the installation scope](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/media_1f03cbd3f7736e2916c73a3de53d44f34cca2d242.png?width=750&format=webply&optimize=medium)
6. Confirm the install under `.agents/skills`. You should see **SKILLS.md** and related reference and asset folders.  
	![Review the installed skills](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/media_17bf544bdb57c4d2096ba165b685e62387d616c12.png?width=750&format=webply&optimize=medium)
7. When Adobe adds or updates skills, use the CLI to add, update, remove, or list them. To see all commands:
	```shell
	$ npx skills --help
	```
	![Review the available skills commands](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/media_1bfb62dad3da230b3b7565ae3f3a5e02dc58bcc1b.png?width=750&format=webply&optimize=medium)

## Use Cases

[![Create AEM Component with AI-assisted development](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/setup/media_10039355427c30b000d5b0e668e34f9de74cb8e23.png?width=750&format=webply&optimize=medium)](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/use-cases/component-development#_self "Create AEM Component with AI-assisted development")

**[Create AEM Component with AI-assisted development](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/use-cases/component-development#_self "Create AEM Component with AI-assisted development")**

Learn how to use AI-assisted development to develop AEM components.

*[Create AEM Component](https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/ai/ai-assisted-development/use-cases/component-development#_self "Create AEM Component")*