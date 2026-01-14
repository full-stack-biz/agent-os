# How Agent OS Works: Complete Guide

Agent OS is a **spec-driven development framework** that transforms AI coding agents into productive developers. This document explains the conceptual model and mechanics.

## The Core Problem It Solves

AI agents (Claude, Cursor, etc.) are great at coding, but they often:
- Don't understand your project's conventions and patterns
- Lack context about your tech stack and standards
- Can't break down large features systematically
- Need to be prompted repeatedly with the same information

Agent OS solves this by **embedding your standards, patterns, and development methodology** into automated workflows that guide agents through structured phases.

## The High-Level Flow

Think of Agent OS as a **multi-phase assembly line** for features:

```
1. Plan Product → 2. Shape Spec → 3. Write Spec → 4. Create Tasks → 5. Implement Tasks → 6. Verify
```

Each phase:
- Runs AI agents through a **structured workflow**
- Injects your **coding standards**
- Creates **artifacts** that feed into the next phase
- Stores everything in the project so context persists

Users can use any combination of these phases—they're independent.

## Installation & Setup

**Agent OS has a 2-level installation:**

### 1. Base Installation
```bash
bash scripts/base-install.sh
```
- Installs Agent OS globally to `~/agent-os/`
- Downloads all profiles, standards, workflows
- Sets up global config (`config.yml`)

### 2. Project Installation
```bash
bash scripts/project-install.sh
```
- Installs Agent OS into each project you use it with
- Creates `.claude/commands/` and `.claude/agents/` for Claude Code
- Creates `agent-os/` folder for storing specs, tasks, etc.
- Project inherits settings from global config

### Directory Structure

```
~/agent-os/
├── config.yml                 ← Global settings
├── profiles/default/          ← Shared workflows & standards
│   ├── commands/
│   ├── agents/
│   ├── workflows/
│   └── standards/
└── scripts/

my-project/
├── .claude/
│   ├── commands/agent-os/     ← Installed commands
│   └── agents/agent-os/       ← Installed subagents
└── agent-os/
    ├── product/               ← Mission, roadmap, tech stack
    └── specs/                 ← Feature specs & tasks
```

## Configuration: How It Adapts to Your Setup

Agent OS is **flexible**—you choose which features to use via `config.yml`:

```yaml
claude_code_commands: true            # Use Claude Code?
use_claude_code_subagents: true       # Delegate to specialized agents?
agent_os_commands: false              # Use with Cursor/other tools?
standards_as_claude_code_skills: false # Deliver standards as Skills or file refs?
profile: default                      # Which profile to use
```

This means you can use Agent OS with:
- **Claude Code + subagents**: Context-efficient (specialized agents, lower token usage per agent)
- **Claude Code without subagents**: Simpler, faster (one agent does everything, higher token usage per task)
- **Other AI tools entirely**: Cursor, Windsurf, or generic tool integration
- Or mix different configurations per project

## The Workflow System: How Work Actually Gets Done

When you run a command like `/plan-product`, here's what happens:

```
You invoke: /plan-product in Claude Code
     ↓
Command definition loads and asks questions
     ↓
If use_claude_code_subagents=true:
     → Delegates to "product-planner" subagent
       (a specialized Claude instance)
     ↓
Subagent receives:
  - Workflow steps (from /profiles/default/workflows/)
  - Your standards (injected as context)
  - Project config
     ↓
Subagent executes workflow:
  1. Check if product/ folder exists
  2. Ask user for product info
  3. Create product/mission.md
  4. Create product/roadmap.md
  5. Create product/tech-stack.md
     ↓
Files persist in project/agent-os/product/
```

**Workflows are bash scripts embedded in markdown** that orchestrate:
- User questions and input collection
- File creation and modification
- Validation and checks
- State management

## The 6 Development Phases

### 1. **plan-product**

Captures your product's **mission, roadmap, and tech stack**.

```
Input: Product idea
Output: agent-os/product/
  ├── mission.md      (product's core purpose)
  ├── roadmap.md      (feature roadmap)
  └── tech-stack.md   (technical choices)
```

- Usually run once per project
- Subsequent specs reference this to stay aligned
- Informs tech stack choices for all future work

### 2. **shape-spec** (New in v2.1)

**Research phase** before writing formal specs.

```
Input: Feature name or user story
Output: agent-os/specs/{spec-name}/planning/
  ├── research.md      (background info)
  ├── requirements.md  (gathered requirements)
  └── approach.md      (proposed technical approach)
```

- Reads your existing `product/tech-stack.md`
- Asks clarifying questions about the feature
- Documents research before writing formal spec
- Prevents bad decisions caught late in implementation

### 3. **write-spec**

Creates the **formal specification**.

```
Input: Feature requirements from shape-spec
Output: agent-os/specs/{spec-name}/spec.md
```

**spec.md includes:**
- **Overview**: What is being built and why
- **Requirements**: Functional and non-functional
- **Acceptance Criteria**: How to know it's done
- **Edge Cases**: Failure modes and boundary conditions
- **API/Data Contracts**: Schema, endpoints, data structures
- **Testing Strategy**: How it should be tested

Standards are injected here to ensure consistent documentation style.

### 4. **create-tasks**

Breaks the spec into **concrete implementation tasks**.

```
Input: spec.md
Output: agent-os/specs/{spec-name}/tasks.md
```

**tasks.md includes:**
- List of 3-10 implementation tasks
- Each task is a standalone unit of work
- Tasks follow topological order (dependencies respected)
- Tasks reference specific requirements from spec.md

Example breakdown:
```
# Tasks for User Authentication

1. Create User model with auth fields
   - References: spec.md Requirements #1, #2
2. Implement password hashing utility
   - Dependencies: Task 1
3. Create login endpoint
   - Dependencies: Task 1, Task 2
4. Create JWT token system
   - Dependencies: Task 3
5. Add authentication middleware
   - Dependencies: Task 4
```

### 5. **implement-tasks**

**Implements each task** from tasks.md.

```
Input: tasks.md
Output:
  - Implemented code in project
  - agent-os/specs/{spec-name}/verification-report.md
```

Execution:
- Can use **single-agent** (direct Claude Code execution) or **multi-agent** (delegate to "implementer" subagent)
- Standards are injected—all code follows conventions automatically
- Each task is implemented, tested, and verified
- Creates verification report tracking what passed/failed

### 6. **orchestrate-tasks** (Advanced)

For **complex features**, coordinate multiple **specialized subagents**.

```
Input: tasks.md + custom agent definitions
Output:
  - Implemented code
  - Orchestration logs
  - Verification reports per agent
```

Useful for:
- Large features with multiple parallel work streams
- Features needing different expertise (frontend expert, backend expert, etc.)
- High-risk work needing specialized reviewers

## Standards Injection: Keeping Code Aligned

Agent OS stores **coding standards** as markdown files:

```
/standards/
├── global/
│   ├── coding-style.md          (naming, formatting, structure)
│   ├── conventions.md           (project-specific patterns)
│   ├── error-handling.md        (how to handle errors)
│   ├── validation.md            (input validation patterns)
│   ├── tech-stack.md            (framework versions, approved libs)
│   └── commenting.md            (documentation standards)
├── frontend/
│   ├── components.md            (component structure, patterns)
│   ├── CSS.md                   (styling approach)
│   ├── accessibility.md         (a11y requirements)
│   └── responsive-design.md     (mobile/desktop considerations)
├── backend/
│   ├── API.md                   (REST/GraphQL patterns)
│   ├── models.md                (ORM patterns, validation)
│   ├── queries.md               (query optimization)
│   └── migrations.md            (database migration patterns)
└── testing/
    └── test-writing.md          (test structure, coverage)
```

### How Standards Get Applied

When a subagent runs, **relevant standards are injected into the prompt**:

```
You are the implementer agent. Follow these standards:

=== GLOBAL STANDARDS ===
[Entire contents of coding-style.md]
[Entire contents of error-handling.md]

=== BACKEND STANDARDS ===
[Entire contents of API.md]
[Entire contents of models.md]

Now implement this task...
```

This means:
- Every agent execution is grounded in your conventions
- No code style debates or inconsistencies
- Conventions are enforced automatically, not through code review
- New team members follow patterns from day one

### Two Delivery Modes

1. **File References** (default, `standards_as_claude_code_skills: false`):
   - Standards files are mentioned by path in the prompt
   - Agent can read them if needed
   - Simple, works everywhere

2. **Claude Code Skills** (`standards_as_claude_code_skills: true`):
   - Standards become discoverable "skills" agents can reference
   - Better discoverability in Claude Code
   - Run `improve-skills` command to enhance skill descriptions
   - Modern approach for Claude Code users

## Subagent Delegation: Context Efficiency

Instead of one Claude instance context-switching between planning, writing specs, and implementing, Agent OS creates **specialized subagents**:

### The Agents

| Agent | Role | Context |
|-------|------|---------|
| **product-planner** | Captures mission, roadmap, tech stack | Product vision |
| **spec-shaper** | Researches and shapes requirements | Feature scope, dependencies |
| **spec-writer** | Writes formal specifications | Requirements, tech stack |
| **tasks-list-creator** | Breaks specs into implementation tasks | Spec document |
| **implementer** | Codes the actual implementation | Task, spec, tech stack, standards |
| **implementation-verifier** | Runs tests and verifies | Code, test suite |
| **spec-initializer** | Sets up new spec | Product info |

### Benefits of Specialization

Each subagent:
- Has a **focused role** with clear instructions
- Receives **relevant standards** only (not all standards)
- Operates in a **narrow context** (lower token usage per agent)
- Is dedicated to one task type (more effective than context-switching)

**The trade-off:**
- ✅ More specialized, focused output
- ✅ Lower token usage per agent
- ✅ Context efficiency
- ❌ Requires multiple calls to Claude API
- ❌ Slightly slower than single agent doing everything

**You can disable subagents** by setting `use_claude_code_subagents: false` to have Claude Code execute everything directly.

## File-Based State Persistence

Agent OS uses the **project filesystem as a database**:

```
agent-os/
├── product/
│   ├── mission.md               (product purpose)
│   ├── roadmap.md               (feature roadmap)
│   └── tech-stack.md            (technical decisions)
│
└── specs/
    └── user-authentication/
        ├── spec.md              ← What to build
        ├── tasks.md             ← How to build it (broken into tasks)
        ├── planning/
        │   ├── research.md
        │   ├── requirements.md
        │   └── approach.md
        ├── implementation/
        │   ├── verification-report.md
        │   └── logs/
        └── ...
```

### Why This Matters

- **Context persists** across sessions—subagents can read prior work
- **No database** needed—filesystem is the database
- **Git-friendly**—everything is markdown, diffs are readable
- **Transparent**—users can review and edit files directly
- **Audit trail**—git history shows evolution of specs and implementations

## Example: Building a Feature End-to-End

Let's say you want to add "user authentication" to your app:

### Step 1: Shape the Spec
```bash
/shape-spec user-authentication
```

Spec-shaper agent:
- Reads `agent-os/product/tech-stack.md` to understand your tech choices
- Asks clarifying questions about auth requirements
- Documents research in `agent-os/specs/user-authentication/planning/`

### Step 2: Write the Formal Spec
```bash
/write-spec user-authentication
```

Spec-writer agent:
- Creates `agent-os/specs/user-authentication/spec.md` with:
  - Requirements (OAuth2 vs JWT, session-based, etc.)
  - Acceptance criteria (login works, tokens refresh, etc.)
  - Edge cases (lockout after N attempts, password reset, etc.)
  - API contracts (POST /login, JWT payload schema, etc.)

### Step 3: Create Implementation Tasks
```bash
/create-tasks user-authentication
```

Tasks-list-creator agent:
- Reads spec.md
- Creates `agent-os/specs/user-authentication/tasks.md`:
  ```
  1. Create User model with auth fields
  2. Implement password hashing utility
  3. Create login endpoint (/api/login)
  4. Add JWT token generation
  5. Create password reset flow
  6. Add auth middleware for protected routes
  7. Write authentication tests
  ```

### Step 4: Implement Tasks
```bash
/implement-tasks user-authentication
```

Implementer agent (or Claude Code directly):
- Reads spec.md and tasks.md
- Injects all relevant standards (coding-style, API, models, error-handling, testing)
- Implements each task:
  1. Creates User model with password hash field ✓
  2. Adds bcrypt hashing utility ✓
  3. Implements POST /api/login endpoint ✓
  4. Generates JWT tokens ✓
  5. Implements password reset email flow ✓
  6. Adds middleware to verify JWT on protected routes ✓
  7. Writes test suite ✓
- Runs tests and creates verification report

### Result

✅ Feature is shipped with:
- Clear specification (in git, reviewed before coding)
- Consistent code style (standards applied automatically)
- All tests passing (verified before merge)
- Full audit trail (git shows evolution of spec → implementation)
- Standards-aligned (no style debates during code review)

## Key Principles

### 1. Specification-First
Write specs before code. Prevents rework and misunderstandings.

### 2. Standards-Driven
Inject conventions automatically. No manual enforcement during code review.

### 3. Specialized Agents
Use focused subagents for different roles. Context efficiency over generalists.

### 4. File-Based State
Keep everything in version control. Transparency, persistence, git-friendly.

### 5. Flexible Phases
Use what you need; skip what you don't. Workflows are optional and composable.

### 6. Modular Profiles
Switch profiles or customize workflows. Extensibility without modifying core.

## When to Use Each Phase

| Phase | When to Use | Skip When |
|-------|-------------|-----------|
| **plan-product** | Once per project | You already have mission/roadmap/tech stack |
| **shape-spec** | Before big features | Feature scope is already crystal clear |
| **write-spec** | Multi-team features, complex logic | Simple bug fixes or obvious enhancements |
| **create-tasks** | Complex specs needing breakdown | Small, obvious specs (skip to implement) |
| **implement-tasks** | Implementing work | You're still in planning phase |
| **orchestrate-tasks** | Very large features, parallel streams | Simple features (use implement-tasks) |

**Recommendation**: Start with plan-product once. Then for each feature: shape-spec → write-spec → create-tasks → implement-tasks. Skip orchestrate-tasks unless you need it.

## Configuration Strategies

### Strategy 1: Full Workflow (Recommended for Teams)
```yaml
claude_code_commands: true
use_claude_code_subagents: true
standards_as_claude_code_skills: true
```
- Use all 6 phases
- Specialized subagents for context efficiency
- Standards as discoverable Skills
- Best for: Teams building complex products

### Strategy 2: Lightweight Single-Agent
```yaml
claude_code_commands: true
use_claude_code_subagents: false
standards_as_claude_code_skills: false
```
- Skip subagent delegation
- Claude Code executes all workflows directly
- Standards injected as file references
- Best for: Solo developers, quick iterations, lower complexity

### Strategy 3: Generic Tool Integration
```yaml
claude_code_commands: false
agent_os_commands: true
standards_as_claude_code_skills: false
```
- Generate commands for Cursor, Windsurf, or other tools
- File-based commands instead of Claude Code subagents
- Best for: Teams not using Claude Code

## What Happens Without Agent OS

Without Agent OS, AI agents:
1. Ask "What's your tech stack?" repeatedly
2. Write code in inconsistent styles (refactoring during review)
3. Misunderstand requirements (implement wrong feature, rework)
4. Skip edge cases (testing finds bugs late)
5. Don't test (manual testing burden)
6. Context-switch between spec, design, implementation (higher token usage)

With Agent OS:
1. ✅ Standards are injected (consistent code from day one)
2. ✅ Specs are written first (fewer misunderstandings)
3. ✅ Tests are part of implementation (fewer bugs)
4. ✅ Agents are specialized (context efficiency)
5. ✅ Everything is in git (audit trail, persistence)
6. ✅ Workflows are repeatable (same process every time)

## Getting Started

1. **Install Agent OS**:
   ```bash
   bash scripts/base-install.sh
   cd my-project
   bash ~/agent-os/scripts/project-install.sh
   ```

2. **Configure**:
   Edit `my-project/agent-os-config.yml` to customize settings

3. **Start with plan-product**:
   ```bash
   /plan-product
   ```
   Define your product's mission, roadmap, and tech stack

4. **Plan a feature**:
   ```bash
   /shape-spec user-authentication
   ```
   Research and scope the feature

5. **Write the spec**:
   ```bash
   /write-spec user-authentication
   ```
   Document what you're building

6. **Create tasks**:
   ```bash
   /create-tasks user-authentication
   ```
   Break into implementation tasks

7. **Implement**:
   ```bash
   /implement-tasks user-authentication
   ```
   Build it with standards applied automatically

That's the flow. Repeat for each feature.

---

**Agent OS transforms AI from a helpful coder into a productive developer that follows your standards, understands your product, and ships consistent, spec-driven code.**

