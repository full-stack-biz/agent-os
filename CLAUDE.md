# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a spec-driven development framework that transforms AI coding agents into productive developers. It provides structured workflows, coding standards, and subagent delegation for the full development lifecycle—from product planning through implementation and verification.

**Current Version**: 2.1.1

## Development Commands

### Installation & Setup

#### Base Installation (Web Method - Primary)

The simplest way to install Agent OS globally:

```bash
# Install to ~/.agent-os (default)
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash

# Install to custom directory
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash -s -- --base-dir /custom/path

# Non-interactive mode (for CI/CD)
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash -s -- --non-interactive
```

#### Base Installation (Local Method - Alternative)

If you have the repository locally:

```bash
# From repository root
bash scripts/base-install.sh

# With custom directory
bash scripts/base-install.sh --base-dir /custom/path

# With non-interactive mode
bash scripts/base-install.sh --non-interactive

# With verbose output
bash scripts/base-install.sh --verbose
```

#### Project Installation & Updates

```bash
# Install Agent OS into a project (uses default or AGENT_OS_HOME location)
bash scripts/project-install.sh

# Install with custom base directory
bash scripts/project-install.sh --base-dir /custom/agent-os-path

# Update Agent OS in a project (if already installed)
bash scripts/project-update.sh

# Create a new custom profile (advanced)
bash scripts/create-profile.sh
```

### Custom Installation Directory

Agent OS supports installing and running from custom directories, enabling:
- Testing different Agent OS versions simultaneously
- Multiple separate installations for different teams or workflows
- CI/CD pipelines with specific installation paths
- Development and testing scenarios

**Three-layer precedence** (CLI flag > Environment variable > Default):

1. **CLI flag** (highest priority):
   ```bash
   bash scripts/project-install.sh --base-dir /custom/agent-os-path
   bash scripts/project-update.sh --base-dir /custom/agent-os-path
   bash scripts/create-profile.sh --base-dir /custom/agent-os-path
   ```

2. **Environment variable** (medium priority):
   ```bash
   export AGENT_OS_HOME=/custom/agent-os-path
   bash scripts/project-install.sh
   bash scripts/project-update.sh
   ```

3. **Default location** (lowest priority):
   ```bash
   # Uses $HOME/agent-os by default
   bash scripts/project-install.sh
   ```

### Key Configuration

Agent OS uses `config.yml` for global settings:
- `version`: Current version (2.1.1)
- `claude_code_commands`: Enable Claude Code integration (default: true)
- `agent_os_commands`: Enable generic commands (default: false)
- `use_claude_code_subagents`: Enable subagent delegation (default: true)
- `standards_as_claude_code_skills`: Use Claude Code Skills for standards (default: false)
- `profile`: Which profile to use (default: "default")

## Architecture Overview

### Core Components

1. **Installation Scripts** (`/`)
   - `install.sh`: Web installer entry point (recommended for new installations via curl)
     - Displays welcome banner and system compatibility checks
     - Delegates to `scripts/base-install.sh` with argument pass-through
     - Detects CI/CD environments and suggests non-interactive mode

2. **Scripts** (`/scripts`)
   - `base-install.sh`: Initial Agent OS installation to `~/agent-os` (or custom directory)
     - Supports `--non-interactive` flag for CI/CD automation
     - Can update existing installations with interactive prompts
   - `project-install.sh`: Install Agent OS into a project (uses specified or default base installation)
   - `project-update.sh`: Update existing project installations (supports custom base directories)
   - `common-functions.sh`: Shared utilities (52KB, contains YAML parsing, file operations, output formatting)
   - `create-profile.sh`: Create custom profiles (supports custom base directories)

3. **Profiles** (`/profiles/default`)
   - **Commands** (`/commands`): Entry points for user workflows (plan-product, shape-spec, write-spec, create-tasks, implement-tasks, orchestrate-tasks, improve-skills)
   - **Agents** (`/agents`): Specialized subagents (product-planner, spec-shaper, spec-writer, tasks-list-creator, implementer, implementation-verifier, spec-initializer, spec-verifier)
   - **Workflows** (`/workflows`): Sequential execution steps for each command
   - **Standards** (`/standards`): Coding standards organized by domain (global, frontend, backend, testing)

4. **Configuration** (`/config.yml`)
   - Global defaults for all projects
   - Installation method and feature toggles

### Development Lifecycle (6 Phases)

Agent OS supports these phases, each with its own command and workflow:

1. **plan-product**: Establish product mission, roadmap, and tech stack
2. **shape-spec**: Gather and refine feature requirements through research and Q&A
3. **write-spec**: Create formal specification document (spec.md)
4. **create-tasks**: Break specification into actionable implementation tasks (tasks.md)
5. **implement-tasks**: Execute task implementation with single-agent approach
6. **orchestrate-tasks**: Advanced multi-agent orchestration for complex features

**Key point**: Users can employ any combination of these phases; they don't need to use all of them.

### Command Structure

Commands located in `/profiles/default/commands/{command-name}/` contain:
- **Command definition**: Entry point that may orchestrate subagents
- **Single-agent variant**: Direct execution without delegating to subagents
- **Multi-agent variant**: Delegates to specialized subagents for context efficiency

Example: `implement-tasks` has both single-agent and multi-agent paths, with the choice determined by `use_claude_code_subagents` config.

### Standards System

Standards are markdown files in `/profiles/default/standards/{domain}/`:

- **Global**: coding-style, conventions, validation, error-handling, tech-stack, commenting
- **Frontend**: CSS, components, accessibility, responsive design
- **Backend**: API, models, queries, migrations
- **Testing**: test-writing standards

Standards can be delivered to agents in two ways:
1. **As file references** in command prompts (default, `standards_as_claude_code_skills: false`)
2. **As Claude Code Skills** when `standards_as_claude_code_skills: true` (then use `improve-skills` command to enhance skill descriptions)

### Workflow System

Workflows are defined in `/profiles/default/workflows/` and contain:
- Sequential steps executed during a command
- Bash shell commands, user prompts, and file operations
- Template system using `{{double-braces}}` for variable substitution
- File I/O to persist state (creates agent-os/ folder in projects)

## Key Implementation Patterns

### 1. Configuration Inheritance

- **Base config** (`~/agent-os/config.yml`): Global defaults
- **Project override** (`project/agent-os-config.yml`): Project-specific settings
- **Runtime flags**: CLI arguments override both

### 2. Subagent Delegation

When `use_claude_code_subagents: true`, commands delegate to specialized agents:
- Each agent receives: parent config, standards, workflow steps, required context
- Agents inherit environment and can access shared files
- Enables context efficiency and specialized expertise

### 3. File-Based State Management

Projects create `agent-os/` directory structure:
```
project/
├── agent-os/
│   ├── product/          # Mission, roadmap, tech-stack (created by plan-product)
│   ├── specs/            # Feature specifications by name
│   │   ├── [spec-name]/
│   │   │   ├── spec.md   # Formal specification
│   │   │   ├── tasks.md  # Implementation tasks list
│   │   │   └── planning/ # Research artifacts from shape-spec
│   └── agents/           # Subagent definitions (for orchestrate-tasks)
└── .claude/
    ├── commands/agent-os/ # Claude Code commands
    └── agents/agent-os/   # Claude Code subagent definitions
```

### 4. Template System

Agent OS uses a sophisticated `{{double-braces}}` template system that processes files at **installation time** (not runtime). Templates are expanded by `scripts/common-functions.sh` functions `compile_agent()` and `compile_command()` during `project-install.sh` and `project-update.sh`.

#### Template Processing Pipeline

Templates are processed in this exact order:
1. **Variable substitution** — Replace `{{var_name}}` with provided values
2. **Conditionals** — Evaluate `{{IF}}`, `{{UNLESS}}`, `{{ENDIF}}`, `{{ENDUNLESS}}`
3. **Workflow includes** — Replace `{{workflows/path}}` with file contents (recursive)
4. **Standards includes** — Replace `{{standards/...}}` with file references (glob support)
5. **PHASE tags** — Embed `{{PHASE N: @agent-os/path.md}}` with headers (single-agent only)

#### Supported Directives

**A. Conditionals** — Include/exclude blocks based on config flags
```markdown
{{IF use_claude_code_subagents}}
[content for multi-agent mode]
{{ENDIF use_claude_code_subagents}}

{{UNLESS standards_as_claude_code_skills}}
[content when standards are file references, not Skills]
{{ENDUNLESS standards_as_claude_code_skills}}
```
- Supported conditions: `use_claude_code_subagents`, `standards_as_claude_code_skills`
- Nesting and mixed IF/UNLESS supported
- Evaluated based on runtime config values

**B. Workflow Includes** — Embed workflow file contents
```markdown
{{workflows/implementation/implement-tasks}}
{{workflows/specification/research-spec}}
```
- Recursively processes nested workflows
- Detects circular references and errors
- Preserves newlines using Perl-based safe replacement
- Resolves paths relative to profile directory

**C. Standards Includes** — Embed standards references (converted to `@agent-os/standards/...` format)
```markdown
{{standards/global/coding-style}}              # Specific standard
{{standards/frontend/*}}                       # All frontend standards
{{standards/*}}                                # All standards
```
- Wildcard patterns (`*`) expanded to all matching files in profile
- Includes file reference format: `@agent-os/standards/domain/filename.md`
- Used in agent prompts to inject relevant standards

**D. PHASE Tags** — Embed numbered instruction files with auto-generated headers (single-agent commands only)
```markdown
{{PHASE 1: @agent-os/commands/plan-product/1-product-concept.md}}
{{PHASE 2: @agent-os/commands/plan-product/2-roadmap.md}}
{{PHASE 3: @agent-os/commands/plan-product/3-tech-stack.md}}
```
- Only processed when compiling single-agent command variants (embed mode)
- Generates H1 header from filename: `"1-product-concept.md"` → `# PHASE 1: Product Concept"`
- Recursively processes nested templates in embedded content
- Inserts `/single-agent/` into path when looking up file

**E. Variable Substitution** — Replace `{{key_name}}` with provided values
```markdown
name: {{standard_name_humanized_capitalized}}
description: Your approach to handling {{standard_name_humanized}}...
[Reference](../../../{{standard_file_path}})
```
- Used primarily in skill generation templates
- Multi-line values supported via `<<<key_name>>>` delimiters
- Safe regex replacement using `quotemeta()` escaping

#### Context-Aware Processing

Template behavior changes based on configuration and context:

| Context | Variable | Value | Behavior |
|---------|----------|-------|----------|
| Multi-agent commands | `use_claude_code_subagents` | true | Standards included, conditionals branch to agent version |
| Single-agent commands | `use_claude_code_subagents` | false | Standards included, conditionals branch to direct version |
| Standards as file refs | `standards_as_claude_code_skills` | false | `{{standards/*}}` expands to file references |
| Standards as Skills | `standards_as_claude_code_skills` | true | `{{UNLESS standards_as_claude_code_skills}}` block removed |
| Single-agent compile | `phase_mode="embed"` | true | PHASE tags expanded into content |
| Multi-agent compile | `phase_mode="embed"` | false | PHASE tags left as-is (handled by subagents) |

#### Where Templates Are Resolved

**Installation Phase** (`scripts/project-install.sh`):
- Line 235: Multi-agent commands compiled (PHASE tags not embedded)
- Line 286: Single-agent commands compiled (PHASE tags embedded)
- Line 327: Agents compiled (workflows + standards injected)
- Line 369: Standards converted to Skills (if enabled)

Configuration context set before compilation:
- `EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS` — From config.yml `use_claude_code_subagents`
- `EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS` — From config.yml `standards_as_claude_code_skills`
- `EFFECTIVE_PROFILE` — From config.yml `profile` setting

**Update Phase** (`scripts/project-update.sh`):
- Uses same compile functions with same configuration context
- Regenerates all installed commands and agents with updated templates

#### Common Usage Patterns

**Pattern 1: Conditional Standards Injection (Agents)**
```markdown
{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences

IMPORTANT: Refer to user's preferred standards:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```
Result: If `standards_as_claude_code_skills=false`, standards references included; otherwise removed.

**Pattern 2: Workflow Delegation (Agents)**
```markdown
Execute the workflow:

{{workflows/implementation/implement-tasks}}
```
Result: Workflow file content inserted at this location.

**Pattern 3: Phased Instructions (Single-Agent Commands)**
```markdown
{{PHASE 1: @agent-os/commands/implement-tasks/1-determine-tasks.md}}

{{PHASE 2: @agent-os/commands/implement-tasks/2-implement-tasks.md}}

{{PHASE 3: @agent-os/commands/implement-tasks/3-verify-implementation.md}}
```
Result: Each file embedded with auto-generated header (single-agent) or left as-is (multi-agent subagents).

**Pattern 4: Variable Substitution (Skill Templates)**
```markdown
---
name: {{standard_name_humanized_capitalized}}
description: Guidelines for {{standard_name_humanized}}
---

[View Standard]({{standard_file_path}})
```
Result: Variables replaced from standards metadata during skill generation.

#### Implementation Details

**Processing Functions** (`scripts/common-functions.sh`):
- `process_conditionals()` (lines 500-630) — Parse IF/UNLESS with nesting
- `process_workflows()` (lines 633-717) — Recursively replace workflow includes
- `process_standards()` (lines 720-754) — Expand standards patterns to references
- `process_phase_tags()` (lines 758-922) — Embed PHASE files with headers
- `compile_agent()` (lines 925-1086) — Master orchestration function
- `compile_command()` (lines 1089-1097) — Wrapper for commands

**Safety Features**:
- Circular reference detection in workflow includes
- Perl-based newline-preserving replacement (safe from shell escaping issues)
- Safe regex escaping using `quotemeta()` for variable substitution
- Validation of template syntax before output

#### Template Scoping

- **Agent templates** — Used in `/profiles/default/agents/*.md` for prompt customization
- **Command templates** — Used in `/profiles/default/commands/*/single-agent/*.md` and multi-agent variants
- **Skill templates** — Used in `profiles/default/claude-code-skill-template.md` for auto-generation
- **Workflow templates** — Workflows can contain templates but are processed recursively

#### When NOT to Use Templates

Templates are processed at **installation time**, not at agent execution time:
- ❌ Don't use `{{}}` for agent runtime logic — it's expanded before Claude sees it
- ❌ Don't use `{{}}` for user input placeholders — user won't see them
- ❌ Don't expect dynamic template evaluation — all expansion happens during install/update

Use regular markdown instead if you need runtime flexibility.

### 5. YAML Parsing

`common-functions.sh` provides robust YAML parsing to handle:
- Different indentation (spaces/tabs)
- Quotes and different spacing
- Validation of required keys

**Key functions**: `get_yaml_value()`, `get_yaml_array()`, `validate_yaml()`

## Working with Agent OS Subagents & Templates

When validating, refining, or creating subagents in Agent OS projects, follow these rules to avoid breaking internal tooling:

### What NOT to Do

**❌ DO NOT remove, modify, or suggest removal of template directives:**
- `{{IF condition}}`, `{{UNLESS condition}}`, `{{ENDIF}}`, `{{ENDUNLESS}}`
- `{{workflows/path/to/workflow}}`
- `{{standards/domain/*}}`
- `{{PHASE N: @agent-os/path}}`
- `{{variable_name}}`

These are compile-time directives processed by `scripts/common-functions.sh` during installation. They are NOT runtime logic and will be expanded before Claude executes the subagent.

**❌ DO NOT suggest adding runtime logic that duplicates what templates do:**
- Don't suggest hardcoding workflow steps when `{{workflows/...}}` exists
- Don't suggest listing all standards when `{{standards/*}}` exists
- Don't suggest conditional prompt text when `{{IF/UNLESS}}` handles it

**❌ DO NOT remove Agent OS-specific YAML fields:**
- `color` field (used by Agent OS for visual organization)
- Other non-standard fields added by Agent OS framework

**❌ DO NOT treat template directives as "missing clarity":**
- Guides like "prompt must be clear and procedural" don't apply to template-based content
- The prompt will be clear AFTER template expansion at install time
- Don't expect agent prompts to be standalone executable before installation

**❌ DO NOT validate that template content exists at validation time:**
- Workflow paths like `{{workflows/implementation/implement-tasks}}` may or may not exist during validation
- Agent OS installation resolves these paths; validation happens before/after installation
- File existence validation is Agent OS's job, not the subagent validator's job

### What TO Do

**✅ DO detect Agent OS projects and apply appropriate rules:**
- Check for `agent-os-config.yml` or `profiles/default/` to detect Agent OS projects
- Apply template-aware validation only for Agent OS subagents
- Use standard subagent validation for non-Agent OS projects

**✅ DO respect the install-time processing model:**
- Understand that subagent files in Agent OS are templates, not final code
- Final validation happens after `project-install.sh` runs (templates expanded)
- Pre-installation validation should only check syntax, not content

**✅ DO validate template syntax, not template logic:**
- Check that `{{IF/UNLESS}}` blocks are balanced (matching ENDIF/ENDUNLESS)
- Check that template paths are formatted correctly
- Check that conditionals use valid condition names: `use_claude_code_subagents`, `standards_as_claude_code_skills`
- BUT: Don't validate that workflow/standards files actually exist (Agent OS does this)

**✅ DO preserve and respect Agent OS conditional structure:**
- If a subagent has `{{UNLESS standards_as_claude_code_skills}}...{{ENDUNLESS}}`, keep it
- If a subagent uses `{{IF use_claude_code_subagents}}`, respect both branches
- Suggestions should not collapse these conditionals into a single path

**✅ DO document Agent OS template usage in validation reports:**
- When validating an Agent OS subagent, note: "This subagent uses Agent OS templates and will be expanded at install time"
- Point out template directives found: workflows, standards, conditionals
- Explain that the final prompt clarity will be determined after template expansion

### Agent OS Subagent Characteristics

Subagents in `/profiles/default/agents/` are templates, not standalone executablecode:

**Installation-time processing** (before Claude executes):
```
Source: profiles/default/agents/spec-shaper.md (contains {{}} templates)
        ↓
        [compile_agent() processes templates]
        ↓
Destination: .claude/agents/spec-shaper.md (final executable subagent)
```

**Validation timing:**
- **Pre-installation**: Don't expect workflows/standards to be included yet
- **Post-installation**: Validate the compiled `.claude/agents/spec-shaper.md` instead
- **Template syntax**: Can validate anytime ({{}} syntax is independent of file content)

### Example: Spec-Shaper Subagent

This is VALID Agent OS subagent structure:
```yaml
---
name: spec-shaper
description: Use proactively to gather detailed requirements...
tools: Write, Read, Bash, WebFetch, Skill
color: blue
model: inherit
---

You are a software product requirements research specialist...

{{workflows/specification/research-spec}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Do NOT suggest:**
- ❌ Removing `color` field (Agent OS uses it)
- ❌ Removing `{{workflows/...}}` and writing out the workflow manually
- ❌ Removing `{{UNLESS standards_as_claude_code_skills}}...{{ENDUNLESS}}` block
- ❌ Improving "prompt clarity" by inlining template content
- ❌ Adding fallback prompt text because templates look incomplete

**Do suggest:**
- ✅ Better description with delegation trigger phrases
- ✅ More specific tools (if some listed aren't actually used)
- ✅ Improved error handling in the base prompt (outside templates)
- ✅ Better integration signals for Claude's delegation

## Important Development Notes

### When Modifying Scripts

1. **Bash Compatibility**: Test on both macOS and Linux. Watch for:
   - Post-increment syntax (e.g., `((i++)`): use `i=$((i+1))` for compatibility
   - Bash v3 vs v4 differences
   - Tab handling in YAML parsing

2. **Dry-Run Safety**: Scripts support `--dry-run` flag. Always verify destructive operations check this flag before executing.

3. **Common Functions**: Use utilities from `common-functions.sh` rather than duplicating:
   - Color output: `print_color()`, `print_success()`, `print_error()`
   - YAML operations: `get_yaml_value()`, `get_yaml_array()`
   - File operations: `copy_with_template()`, `validate_required_files()`

### When Adding Workflows

1. Workflows are bash scripts embedded in markdown files
2. Use `print_status()`, `print_success()`, `print_error()` for output
3. Workflows can check if `agent-os/` folder exists and handle existing state
4. Workflows should validate required files before using them
5. All file operations should respect the dry-run mode if applicable

### When Adding Standards

1. Standards files should be actionable, focused guidance
2. Avoid generic statements; include specific patterns/examples
3. Can reference multiple standards from one workflow
4. Standards are injected into subagent prompts, so keep descriptions concise

## Testing & Validation

- Scripts use `--dry-run` flag for safe testing without side effects
- `--verbose` flag enables debug output
- Main installation flow: base-install.sh → project-install.sh (for each project)
- Verify with: `ls -la ~/.agent-os/` and `ls -la project/.claude/commands/agent-os/`

## Recent Major Changes (v2.1.0+)

- **Config flexibility**: Moved from rigid "modes" to boolean feature flags
- **Skills support**: Standards can be delivered as Claude Code Skills
- **6 phases**: Expanded from 4 to support shape-spec and orchestrate-tasks
- **Removed bloat**: Eliminated mandatory documentation and specialized verifiers
- **Improved install**: Simplified project update workflow

## Key Files to Understand

- `scripts/common-functions.sh`: ~1300 lines of shared utilities (YAML parsing, file ops, output)
- `scripts/project-install.sh`: Main installation orchestration (~200 lines logic)
- `profiles/default/workflows/`: Where actual development workflows are defined
- `config.yml`: Configuration schema and defaults

