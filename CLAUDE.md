# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a spec-driven development framework that transforms AI coding agents into productive developers. It provides structured workflows, coding standards, and subagent delegation for the full development lifecycle—from product planning through implementation and verification.

**Current Version**: 2.1.1

## Development Commands

### Installation & Setup

```bash
# Base installation (first time only) - installs Agent OS globally
bash scripts/base-install.sh

# Install Agent OS into a project
bash scripts/project-install.sh

# Update Agent OS in a project (if already installed)
bash scripts/project-update.sh

# Create a new custom profile (advanced)
bash scripts/create-profile.sh
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

1. **Scripts** (`/scripts`)
   - `base-install.sh`: Initial Agent OS installation to `~/agent-os`
   - `project-install.sh`: Install Agent OS into a project
   - `project-update.sh`: Update existing project installations
   - `common-functions.sh`: Shared utilities (52KB, contains YAML parsing, file operations, output formatting)
   - `create-profile.sh`: Create custom profiles

2. **Profiles** (`/profiles/default`)
   - **Commands** (`/commands`): Entry points for user workflows (plan-product, shape-spec, write-spec, create-tasks, implement-tasks, orchestrate-tasks, improve-skills)
   - **Agents** (`/agents`): Specialized subagents (product-planner, spec-shaper, spec-writer, tasks-list-creator, implementer, implementation-verifier, spec-initializer, spec-verifier)
   - **Workflows** (`/workflows`): Sequential execution steps for each command
   - **Standards** (`/standards`): Coding standards organized by domain (global, frontend, backend, testing)

3. **Configuration** (`/config.yml`)
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

Profiles use `{{variable}}` syntax for substitution:
- Profile values injected during installation
- Allows customization without modifying core files
- Currently minimal use; mainly for profile name/version

### 5. YAML Parsing

`common-functions.sh` provides robust YAML parsing to handle:
- Different indentation (spaces/tabs)
- Quotes and different spacing
- Validation of required keys

**Key functions**: `get_yaml_value()`, `get_yaml_array()`, `validate_yaml()`

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

