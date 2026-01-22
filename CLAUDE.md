# CLAUDE.md

This file provides guidance to Claude Code when working with this Agent OS v3 project.

## Project Overview

Agent OS v3 is a standards discovery and injection framework that helps AI tools access project conventions and coding patterns. Rather than orchestrating development (v2's approach), v3 focuses on making standards discoverable and contextually relevant.

**Key files:**
- `scripts/project-install.sh` — Installs Agent OS into a project
- `scripts/sync-to-profile.sh` — Syncs project standards to base profiles
- `commands/agent-os/` — 5 core commands for standards management
- `profiles/` — Profile hierarchy with configuration and commands

## Core Concepts

### Standards Discovery System
Agent OS v3 provides three integrated commands:

1. **`/discover-standards`** — Extract patterns from existing code
   - Analyzes codebase structure
   - Guides users through documentation process
   - Creates concise, project-specific standards

2. **`/inject-standards`** — Insert relevant standards into conversations
   - Auto-suggests applicable standards based on context
   - Provides explicit injection for targeted use
   - Context-aware formatting (conversations, plan mode, skills)

3. **`/index-standards`** — Organize standards with `index.yml`
   - Creates searchable standard metadata
   - Maps files to keywords for discovery
   - Enables automatic standard matching

### Product Planning Commands

4. **`/plan-product`** — Establish product mission and roadmap
   - Defines project goals and constraints
   - Captures technology stack decisions
   - Creates artifact: `agent-os/product/`

5. **`/shape-spec`** — Gather requirements through research and Q&A
   - Explores feature patterns and user needs
   - Creates investigation artifacts
   - Feeds into formal specification (user creates spec.md separately)

## Architecture

### Profile System

Agent OS uses a profile inheritance chain for flexibility:

```yaml
profiles:
  default:
    # Base profile, always present
  custom-rails:
    inherits_from: default
    # Inherits defaults, adds Rails-specific standards
  custom-nextjs:
    inherits_from: default
    # Inherits defaults, adds Next.js-specific standards
```

**Profile directory structure:**
```
profiles/default/
├── commands/agent-os/
│   ├── discover-standards.md
│   ├── inject-standards.md
│   ├── index-standards.md
│   ├── plan-product.md
│   └── shape-spec.md
└── standards/
    ├── global/
    │   ├── coding-style.md
    │   └── error-handling.md
    └── (other domains as defined by profile)
```

### Installation & Configuration

**Installation:**
```bash
# In project directory
bash /path/to/agent-os/scripts/project-install.sh

# With options
bash /path/to/agent-os/scripts/project-install.sh --profile custom-rails
bash /path/to/agent-os/scripts/project-install.sh --commands-only
```

**Configuration (config.yml):**
```yaml
version: 3.0
default_profile: default

profiles:
  default:
    # Base configuration
  custom-rails:
    inherits_from: default
```

### File Structure After Installation

```
project/
├── agent-os/
│   └── standards/              # Discovered and provided standards
│       ├── index.yml           # Standard metadata for discovery
│       ├── global/
│       │   ├── coding-style.md
│       │   └── error-handling.md
│       └── (other domains)
├── .claude/
│   └── commands/agent-os/      # Available commands
│       ├── discover-standards.md
│       ├── inject-standards.md
│       ├── index-standards.md
│       ├── plan-product.md
│       └── shape-spec.md
├── agent-os/product/           # Created by /plan-product
│   ├── mission.md
│   ├── roadmap.md
│   └── tech-stack.md
```

## Key Implementation Details

### Standards Discovery
The `/discover-standards` command analyzes codebase structure and guides users through pattern extraction:
- Scans source directories for patterns
- Uses AskUserQuestion for interactive guidance
- Creates markdown standards files in `agent-os/standards/`
- Suggests standard categories based on code structure

### Standards Injection
The `/inject-standards` command provides intelligent context awareness:
- **Auto-mode:** Analyzes current work and recommends standards
- **Explicit-mode:** User specifies which standards to inject
- **Format-aware:** Different output for conversations vs. plan mode

### Profile Inheritance Chain
Profiles can inherit from parent profiles:
1. User specifies `default_profile` in config.yml or via CLI
2. System follows `inherits_from` chain to build complete set
3. Standards/commands are merged (child overrides parent)
4. Installation applies all profiles in chain order

## Development Workflow

### For Users
1. Install Agent OS: `bash scripts/project-install.sh`
2. Run `/discover-standards` to extract project patterns
3. Use `/inject-standards` during development to access conventions
4. Run `/index-standards` to organize standards for discovery
5. Use `/plan-product` and `/shape-spec` as needed
6. Leverage Claude Code Plan Mode with standards available in context

### For Team Scaling
Use `scripts/sync-to-profile.sh` to:
1. Select which standards to promote to base profile
2. Push standards back to shared profile
3. Enable team-wide consistency across multiple projects

## Critical Implementation Patterns

### Profile Inheritance Resolution
When building inheritance chain:
1. Start with requested profile name
2. Follow `inherits_from` links until reaching profile with no parent
3. Detect circular dependencies and report error
4. Return chain as newline-separated list (base first)

### Standards File Operations
When managing standards:
- Use `copy_standards()` for recursive directory copying
- Exclude `.backups/` directories automatically
- Validate file existence before operations
- Preserve relative paths during copying

### Bash Safety (Shellcheck Compliant)
Critical patterns for script reliability:
```bash
# Declare and assign separately
local var
var=$(command)  # Not: local var=$(command)

# Use read -r for input safety
read -rp "Prompt: " input_var

# Quote expansions in patterns
"${var#"$pattern"/}"  # Not: "${var#$pattern/}"

# Export variables used by sourced scripts
export VERBOSE="true"
```

## Important Notes

- **No agents in v3:** Unlike v2, there are no specialized agents to create or manage
- **Profile-focused:** All customization happens through profiles
- **Standards-first:** The framework is optimized for standards management, not orchestration
- **AI-native:** Commands are designed to work with modern AI tools (Claude Code plan mode, extended thinking)

## Related Documentation

- `AGENT_OS_V3_ARCHITECTURE.md` — Detailed architecture and migration from v2
- `README.md` — Quick start and basic usage
- `config.yml` — Configuration schema and defaults
