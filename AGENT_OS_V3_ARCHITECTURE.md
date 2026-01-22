# Agent OS v3: Architecture Shift

## Executive Summary

Agent OS v3 represents a fundamental architectural shift from a complex multi-agent orchestration framework to a lightweight standards discovery and injection system. This document details what changed, why, and what it means for users.

**Key metric:** 6,197 lines removed, 2,104 added (66% reduction in codebase)

---

## The Philosophical Change

### v2 Approach: Orchestration-First
Agent OS v2 was built on the assumption that the framework needed to manage the entire development lifecycle:
- Multiple specialized Claude Code agents for each phase (spec-writer, implementer, verifier, etc.)
- Complex command structures with `multi-agent/` and `single-agent/` variants
- Detailed workflow files orchestrating each step of development
- Separate base installation vs. project installation with inheritance chains

### v3 Approach: Standards-First
Agent OS v3 embraced the reality that AI tools (particularly Claude Code with plan mode) have evolved to handle orchestration themselves. The framework now focuses on what it does uniquely well:
- **Discovering** patterns and standards from existing codebases
- **Indexing** standards for intelligent detection
- **Injecting** standards at the right moment with context awareness

This allows frontier AI models to naturally incorporate project conventions while managing their own workflow.

---

## What Was Removed

### Agent Infrastructure (8 agents deleted)
```
❌ spec-initializer.md
❌ spec-shaper.md
❌ spec-writer.md
❌ spec-verifier.md
❌ implementation-verifier.md
❌ implementer.md
❌ product-planner.md
❌ tasks-list-creator.md
```

These agents are no longer needed because modern AI models handle spec creation, implementation, and verification naturally when given good standards context.

### Command Architecture
The command structure was simplified from dual-path to single-path:

**v2 (removed):**
```
commands/
├── create-tasks/
│   ├── multi-agent/create-tasks.md
│   └── single-agent/
│       ├── 1-get-spec-requirements.md
│       ├── 2-create-tasks-list.md
│       └── create-tasks.md
├── implement-tasks/
│   ├── multi-agent/implement-tasks.md
│   └── single-agent/
│       ├── 1-determine-tasks.md
│       ├── 2-implement-tasks.md
│       ├── 3-verify-implementation.md
│       └── implement-tasks.md
├── orchestrate-tasks/orchestrate-tasks.md
└── improve-skills/improve-skills.md
```

**v3 (new):**
```
commands/agent-os/
├── discover-standards.md
├── inject-standards.md
├── index-standards.md
├── plan-product.md
└── shape-spec.md
```

### Workflow System (24 files deleted)
The entire `workflows/` folder was removed, which contained:
- `planning/` — Detailed product planning workflows
- `specification/` — Research, initialization, writing, and verification of specs
- `implementation/` — Task creation, implementation, and verification flows

These workflows enforced a rigid step-by-step process. v3 trusts AI models to manage these phases.

### Installation Scripts (2 scripts removed, 1 rewritten)
```
❌ base-install.sh (701 lines)
❌ create-profile.sh (326 lines)
❌ project-update.sh (922 lines)
✅ project-install.sh (rewritten, simplified)
```

The separate base/project installation distinction was removed. Users now simply install Agent OS into their project once.

### Standards File Structure (16 files deleted)
v2 had a pre-built standards hierarchy:
```
standards/
├── backend/
│   ├── api.md
│   ├── migrations.md
│   ├── models.md
│   └── queries.md
├── frontend/
│   ├── accessibility.md
│   ├── components.md
│   ├── css.md
│   └── responsive.md
└── global/
    ├── coding-style.md
    ├── commenting.md
    ├── conventions.md
    ├── error-handling.md
    ├── tech-stack.md
    ├── validation.md
    └── testing/test-writing.md
```

v3 removed this structure entirely. Standards are now discovered from the codebase, not predefined.

---

## What Was Added

### The Discovery & Injection System

#### 1. `/discover-standards` (187 lines)
Lets users extract patterns from their codebase:
- Analyzes code structure to identify areas
- Uses AskUserQuestion to guide discovery
- Creates concise, scannable standards
- Suggests what to document based on actual code patterns

**Key insight:** Instead of imposing standards, v3 helps teams extract their own tribal knowledge.

#### 2. `/inject-standards` (291 lines)
Intelligently injects relevant standards based on context:
- **Auto-suggest mode:** Analyzes current conversation and recommends applicable standards
- **Explicit mode:** Directly injects specified standards
- **Context-aware:** Different formatting for conversations, plan mode, and skill creation

**Key insight:** Standards are now context-aware, not blanket-applied to every situation.

#### 3. `/index-standards` (124 lines)
Organizes standards with an `index.yml` file for automatic detection:
- Maps standard files to keywords
- Enables intelligent searching and matching
- Allows custom organization per project

**Key insight:** Standards are discoverable and tagged, not just a folder dump.

### Simplified Configuration

**v2 config.yml (complex):**
- Single file with many boolean flags
- Separate inheritance files for each profile
- Convoluted inheritance chains

**v3 config.yml (simple):**
```yaml
version: 3.0
default_profile: test-profile

profiles:
  test-profile:
    inherits_from: mid-profile
  mid-profile:
    inherits_from: base-profile
```

Profile inheritance is now inline and human-readable.

### New Sync Script
`sync-to-profile.sh` (528 lines) — Pushes project standards back to base profiles for team reuse. This enables the discovery workflow to scale across teams.

---

## Impact on User Workflows

### Before v3
```
Install Agent OS (base + project)
  ↓
Run /plan-product (delegates to product-planner agent)
  ↓
Run /shape-spec (delegates to spec-shaper agent)
  ↓
Run /create-spec via spec-writer, spec-verifier agents
  ↓
Run /create-tasks with specific task-list-creator agent
  ↓
Run /implement-tasks or /orchestrate-tasks depending on complexity
  ↓
Multiple agents verify and report
```

### After v3
```
Install Agent OS (into project)
  ↓
Run /discover-standards (extract your patterns)
  ↓
Use /inject-standards as needed during development
  ↓
Use Claude Code Plan Mode directly
  ↓
Standards are automatically available in agent context
```

The number of explicit steps decreased dramatically. Users now rely on AI tools' built-in planning rather than Agent OS's orchestration.

---

## Migration Path for v2 Users

### What Stays
- Your `standards/` folder content (same format)
- Your `product/` folder (mission, roadmap, tech-stack)
- Your `specs/` folder structure

### What Changes
- Commands: `/plan-product`, `/shape-spec`, `/discover-standards`, `/inject-standards`
- No more `/create-tasks`, `/implement-tasks`, `/orchestrate-tasks`
- No more separate agent definitions
- Simpler `config.yml`

### What You Need to Do
1. Move your custom standards to v3's standards folder
2. Use `/discover-standards` to identify any patterns you missed
3. Use `/inject-standards` to bring standards into conversations and plans
4. Let Claude Code Plan Mode handle orchestration (no more manual agent delegation)

---

## Code Statistics

### Deleted
- **77 total files changed**
- **6,197 lines removed**
- All workflow files (24 files)
- All specialized agents (8 files)
- Multiple installation scripts (3 files)
- Pre-built standards (16 files)

### Added
- **2,104 lines added**
- Discovery system (3 commands: discover, inject, index)
- New sync script
- Simplified configuration system

### Net Reduction
**~4,000 lines of complexity removed** while maintaining core functionality.

---

## Why This Matters

### For Users
1. **Simpler installation** — One process, not two
2. **Fewer commands** — 5 focused commands instead of 8+ with variants
3. **Less setup** — No agent creation, no role definitions
4. **Better AI integration** — Standards available natively in Claude Code's context
5. **Discovery-driven** — Standards emerge from your actual code, not imposed from templates

### For Maintenance
1. **Smaller codebase** — Easier to understand and modify
2. **Clearer purpose** — Agent OS is now a standards tool, not an orchestration framework
3. **Less fragility** — Fewer moving parts means fewer things to break
4. **Better alignment** — v3 aligns with how modern AI tools actually work (plan mode, extended thinking)

### For Teams
1. **Standards sharing** — `sync-to-profile.sh` enables team-wide standard propagation
2. **Consistency** — `/inject-standards` ensures standards are used where needed
3. **Flexibility** — Teams can define standards per-project or organization-wide

---

## The Architectural Vision

v3 represents a maturation of Agent OS's purpose:

**Early versions (v1-v2):** AI tools needed orchestration. They couldn't plan their own work, so Agent OS had to break down problems into explicit steps and delegate to specialized agents.

**v3 and beyond:** AI tools now handle planning and orchestration naturally. Agent OS's unique value is **establishing and enforcing conventions**—standards that keep AI agents aligned with the project's style, patterns, and best practices.

The framework shifted from "AI orchestration system" to "standards management system." It's smaller, more focused, and more aligned with how teams actually want to work with AI.
