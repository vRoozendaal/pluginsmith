<p align="center">
  <img src="PluginSmith/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width="128" height="128" alt="PluginSmith">
</p>

<h1 align="center">PluginSmith</h1>

<p align="center">
  <strong>Build Claude Code plugins visually.</strong><br>
  Turn your documentation into production-ready plugins and skills — no boilerplate required.
</p>

<p align="center">
  <a href="https://github.com/vRoozendaal/PluginSmith/releases"><img src="https://img.shields.io/github/v/release/vRoozendaal/PluginSmith?style=flat-square&color=6e56cf" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-6e56cf?style=flat-square" alt="License: MIT"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2015%2B-6e56cf?style=flat-square" alt="macOS 15+">
  <img src="https://img.shields.io/badge/swift-5.9-6e56cf?style=flat-square" alt="Swift 5.9">
</p>

<p align="center">
  <a href="https://pluginsmith.app">Website</a> &nbsp;&middot;&nbsp;
  <a href="https://github.com/vRoozendaal/PluginSmith/releases">Download</a> &nbsp;&middot;&nbsp;
  <a href="https://pluginsmith.app/privacy.html">Privacy</a> &nbsp;&middot;&nbsp;
  <a href="https://pluginsmith.app/license.html">License</a>
</p>

<br>

<p align="center">
  <img src="website/images/screenshot-configure.png" width="800" alt="PluginSmith — Configure phase">
</p>

---

## What is PluginSmith?

PluginSmith is a native macOS app that helps you create [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugins and skills from your existing documentation. Instead of manually writing configuration files, YAML frontmatter, and directory structures, you drop in your docs and let PluginSmith handle the rest.

**Three steps. That's it.**

| Step | What happens |
|------|-------------|
| **1. Import** | Drop in Markdown, PDF, Word, Excel, or paste a URL |
| **2. Configure** | Define commands, skills, agents, hooks — or let AI suggest them |
| **3. Generate** | One click produces all files, ready to install |

## Features

- **Commands** — Create slash commands with descriptions, argument hints, tool selection, and model choice
- **Skills** — Build instruction sets with reference files and examples
- **Agents** — Configure autonomous agents with tools, models, and color coding
- **Hooks** — Set up event triggers (session start, tool use, prompt submission, stop)
- **MCP Servers** — HTTP and stdio server configuration with `.mcp.json` generation
- **AI-Assisted Config** — Click "Analyze Sources" to get intelligent suggestions for your entire plugin structure
- **One-Click Install** — Install directly to Claude's local marketplace, export to folder, or package as `.plugin`

## Requirements

- **macOS 15.0** (Sequoia) or later
- **Anthropic API key** — [Get one here](https://console.anthropic.com/settings/keys)

## Getting Started

### 1. Download

Grab the latest release from the [Releases page](https://github.com/vRoozendaal/PluginSmith/releases), or build from source.

### 2. Add your API key

Open PluginSmith → **Settings** → paste your Anthropic API key.

Your key is stored in the macOS Keychain and never leaves your machine except to communicate with the Anthropic API.

<details>
<summary><strong>How to get an Anthropic API key</strong></summary>

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Sign up or log in
3. Navigate to **Settings → API Keys**
4. Click **Create Key**
5. Copy the key (starts with `sk-ant-`)
6. Paste into PluginSmith → Settings

</details>

### 3. Create your first plugin

1. **Import** — Drag documentation files into the import area, or paste a URL
2. **Configure** — Click "Analyze Sources" to get AI suggestions, or manually add commands, skills, and agents
3. **Generate** — Hit Generate, then install to Claude or export

## Build from Source

```bash
git clone https://github.com/vRoozendaal/PluginSmith.git
cd PluginSmith
open PluginSmith.xcodeproj
```

Build and run with **Cmd+R** in Xcode.

## Supported Import Formats

| Format | Extensions |
|--------|-----------|
| Markdown | `.md`, `.markdown` |
| Plain Text | `.txt` |
| PDF | `.pdf` |
| Microsoft Word | `.docx`, `.doc` |
| Excel | `.xlsx` |
| Web | Any `https://` URL |

## Generated Output

PluginSmith generates a complete plugin directory structure:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── find-code-guideline.md
│   ├── verify-code-sequence.md
│   └── ...
├── skills/
│   └── my-skill/
│       ├── SKILL.md
│       ├── references/
│       └── examples/
├── agents/
│   └── my-agent.md
├── hooks/
│   └── hooks.json
├── .mcp.json
└── README.md
```

**Export options:**
- Install directly to `~/.claude/plugins/` (Claude's local marketplace)
- Export to any folder
- Package as a `.plugin` file for distribution

## Privacy

PluginSmith collects **zero** data. No analytics, no telemetry, no tracking, no accounts.

- Documents are processed locally
- AI features send content to the Anthropic API at your request only
- API key stored in macOS Keychain
- No intermediary servers

Read the full [Privacy Policy](https://pluginsmith.app/privacy.html).

## Why Free?

PluginSmith is a tool built by a developer, for developers. It's released under the MIT License because great tools should be accessible to everyone. The only cost is your own Anthropic API usage, which you control entirely.

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

## Author

**Roel van Roozendaal** — Berlin Germany

---

<p align="center">
  <sub>Built with SwiftUI &nbsp;&middot;&nbsp; Powered by Claude &nbsp;&middot;&nbsp; <a href="https://pluginsmith.app">pluginsmith.app</a></sub>
</p>
