# How Agent OS Works

This document explains the technical mechanics of Agent OS v3: how it discovers, indexes, and injects standards into AI workflows.

## Installation Flow

### 1. User Runs `project-install.sh`

```bash
cd /path/to/project
bash /path/to/agent-os/scripts/project-install.sh
```

### 2. Installation Steps

**Phase 1: Validation**
- Verifies Agent OS base installation exists
- Checks that script isn't being run from base installation
- Loads configuration from `config.yml`

**Phase 2: Profile Resolution**
- Reads `default_profile` from config.yml (or uses CLI flag `--profile`)
- Builds profile inheritance chain using `get_profile_inheritance_chain()`
- Detects circular dependencies and reports errors
- Validates all profiles in chain exist

**Phase 3: Project Structure**
- Creates `agent-os/` directory structure
- Creates `agent-os/standards/` for project standards
- Creates `.claude/commands/agent-os/` for commands

**Phase 4: Standards Installation**
- Processes each profile in inheritance chain (base first)
- Copies all `.md` files from profile's `standards/` folder
- Later profiles override earlier ones (inheritance)
- Tracks file sources for user feedback

**Phase 5: Index Creation**
- Scans installed standards
- Creates `index.yml` with metadata
- Maps each standard to folder/filename
- Provides placeholder descriptions for customization

**Phase 6: Commands Installation**
- Copies command files from base installation's `commands/agent-os/`
- Makes 5 core commands available in Claude Code

### 3. Output

```
✓ Created agent-os/ directory structure
✓ Installed 15 standards files (from 2 profiles)
✓ Updated index.yml (15 entries)
✓ Installed 5 commands to .claude/commands/agent-os/

Next steps:
  1. Run /discover-standards to extract patterns from your codebase
  2. Run /inject-standards to inject standards into your context
```

## Standards Discovery (`/discover-standards`)

### How It Works

1. **Analyze Project Structure**
   - Scans `src/`, `app/`, `lib/`, etc. for code
   - Identifies dominant languages and frameworks
   - Maps folder structure to potential standard categories

2. **Interactive Guidance**
   - Uses `AskUserQuestion` to walk through discovery
   - Suggests standards categories based on analysis
   - Allows users to customize what gets documented

3. **Extract Patterns**
   - For each category, analyzes actual code files
   - Identifies repeated patterns and conventions
   - Suggests documentation based on patterns found

4. **Create Standards Files**
   - Generates markdown files in `agent-os/standards/`
   - Creates scannable, concise standards
   - Uses consistent formatting

### Example Discovery Session

```
Detected project structure:
  • Frontend: React + TypeScript
  • Backend: Node.js/Express
  • Database: PostgreSQL

Which areas should we document standards for?
  1) Frontend (React/TypeScript)
  2) Backend (Node.js/Express)
  3) Database (PostgreSQL)
  4) Testing
  5) DevOps/Deployment

User selects: 1, 2, 4

Analysis begins:
  Scanning Frontend code for patterns...
    ✓ Found 15 component patterns
    ✓ Found TypeScript usage patterns
    ✓ Found styling approach (CSS modules)

Discovered Frontend Standards:
  1. Components (functional vs class)
  2. TypeScript conventions
  3. Styling approach
  ... [user edits and confirms]
```

## Standards Indexing (`/index-standards`)

### Index File Format

```yaml
# agent-os/standards/index.yml

root:
  coding-style:
    description: General coding style guidelines

frontend:
  components:
    description: React component patterns and best practices
  typescript:
    description: TypeScript conventions and patterns
  styling:
    description: CSS/styling approach (modules, naming, etc)

backend:
  api-design:
    description: REST API design patterns and conventions
  database:
    description: Database schema and query patterns
  error-handling:
    description: Error handling and logging conventions
```

### How `/index-standards` Works

1. **Scans standards directories**
   - Finds all `.md` files in `agent-os/standards/`
   - Preserves folder structure (backend, frontend, etc)

2. **Extracts metadata**
   - Reads first heading or paragraph from each file
   - Uses as description (or prompts user for custom description)

3. **Creates index.yml**
   - Hierarchical YAML structure
   - Maps files to searchable keywords
   - Enables automatic discovery by `/inject-standards`

4. **Updates descriptions**
   - Prompts user to customize descriptions
   - Generates keywords for intelligent matching
   - Creates link structure for related standards

## Standards Injection (`/inject-standards`)

### Two Modes

#### Mode 1: Auto-Suggest
```
User is working on authentication. Agent OS detects keywords:
  - "authentication", "login", "bearer token"

Suggests injecting:
  • backend/authentication.md
  • backend/error-handling.md (for auth errors)
  • global/coding-style.md

User can accept all, select some, or skip.
```

#### Mode 2: Explicit Injection
```
User runs: /inject-standards backend/api-design

Agent OS:
  1. Finds backend/api-design.md
  2. Formats for current context (conversation/plan/skill)
  3. Inserts into active conversation
```

### Context-Aware Formatting

**For Regular Conversations:**
```markdown
## Injected Standards: API Design

[Full standard content]

---
Use these patterns when designing new endpoints.
```

**For Claude Code Plan Mode:**
```markdown
@agent-os/standards/backend/api-design.md

(Lightweight reference, plan mode handles full context)
```

**For Skill Creation:**
```markdown
---
related_standards:
  - backend/api-design.md
  - backend/error-handling.md
---

[Skill content with standard references]
```

## Profile Inheritance Mechanism

### Configuration Example

```yaml
# config.yml
version: 3.0
default_profile: rails-project

profiles:
  rails-project:
    inherits_from: framework-rails
  framework-rails:
    inherits_from: default
  default:
    # Base profile - no parent
```

### Resolution Algorithm

When user specifies `rails-project`:

```
1. Start: rails-project
2. Check: inherits_from = "framework-rails"
3. Add to chain: [rails-project, framework-rails, ...]
4. Check: framework-rails inherits_from = "default"
5. Add to chain: [rails-project, framework-rails, default, ...]
6. Check: default inherits_from = (none/false)
7. Stop, return chain
```

**Result:** Standards are merged in order:
- `default/standards/` files loaded first
- `framework-rails/standards/` override if present
- `rails-project/standards/` override if present
- Project's own standards override all

## Standards Synchronization

### `sync-to-profile.sh` Workflow

Used to push project discoveries back to shared profiles:

**Step 1: Find Standards**
```bash
Find all .md files in project's agent-os/standards/
Display list with checksboxes
```

**Step 2: Select Destination**
```bash
List existing profiles from base installation
Or create new profile
```

**Step 3: Interactive Selection**
```bash
User toggles which standards to sync (a=all, n=none, d=deselect all)
```

**Step 4: Handle Conflicts**
```bash
If file already exists in destination:
  - Show file in both locations
  - Ask: Keep project version? Keep profile version? Merge?
```

**Step 5: Sync & Backup**
```bash
Create backup: profile/standards/.backups/2026-01-22-1432/
Copy selected standards to profile
Update profile's index.yml
```

## Standards File Operations

### How `copy_standards()` Works

```bash
copy_standards() {
    local source_dir=$1
    local dest_dir=$2

    # Create destination
    mkdir -p "$dest_dir"

    # Find all .md files (exclude .backups/)
    find "$source_dir" -name "*.md" -type f ! -path "*/.backups/*" -print0 |
    while IFS= read -r -d '' file; do
        # Preserve relative path
        relative_path="${file#"$source_dir"/}"
        dest_file="$dest_dir/$relative_path"

        # Create subdirectories
        mkdir -p "$(dirname "$dest_file")"

        # Copy file
        cp "$file" "$dest_file"
    done
}
```

**Key features:**
- Uses `-print0` and `read -d ''` for safe filename handling
- Preserves folder structure with `${file#...}` expansion
- Excludes backup directories automatically
- Creates nested directories as needed

## Critical Functions

### `get_profile_inheritance_chain()`

Returns all profiles in inheritance order (base first):

```
Input: config.yml, profile name "custom-rails", profiles directory

Output:
default
framework-rails
custom-rails

(base first, so earlier ones can be overridden)
```

### `ensure_dir()`

Creates directory if not exists:

```bash
ensure_dir "$PROJECT_DIR/agent-os/standards"
# Creates all parent directories safely
```

### `copy_file()`

Copies file with directory creation:

```bash
copy_file "$source" "$dest"
# Creates parent directories before copying
```

## Error Handling

### Common Error Cases

**1. Circular Profile Dependency**
```
Profile A → B → A (circular!)
Error: "Circular dependency detected in profile inheritance chain: A → B → A"
```

**2. Missing Profile**
```
Profile references non-existent parent
Error: "Profile not found: missing-parent"
```

**3. Malformed config.yml**
```
YAML parsing fails
Error: "Failed to parse config.yml"
```

**4. No Standards Found**
```
Profile has no standards directory
Message: "No standards to install (profile is empty)"
```

## Performance Considerations

### Installation Speed
- Profile resolution: O(depth) where depth = inheritance chain length
- File copying: O(n) where n = number of standards files
- Index creation: O(n log n) due to sorting

### Memory Usage
- Inheritance chains: minimal (typically 3-5 profiles)
- File operations: streaming (not loading all into memory)
- Index: small YAML file (typically <10KB)

### Optimization Points
- Standards copying uses `find` with `-print0` for efficiency
- No file duplication (files copied once)
- Inheritance resolution cached per command run
- Interactive prompts don't block on I/O

## Bash Patterns Used

### Safe Variable Expansion
```bash
# Correct: expandable variables quoted separately
"${var#"$pattern"/}"

# Incorrect: unquoted patterns match as glob
"${var#$pattern/}"
```

### Safe Read Input
```bash
# Correct: read with -r flag
read -rp "Prompt: " variable

# Incorrect: read without -r
read -p "Prompt: " variable  # Breaks on backslashes
```

### Separate Declare & Assign
```bash
# Correct: prevents masking return values
local var
var=$(command)

# Incorrect: masks command's return value
local var=$(command)
```

### Trap Cleanup with Quoted Variables
```bash
# Correct: use single quotes to delay expansion
local tempfile=$(mktemp)
trap 'rm -f "$tempfile"' EXIT

# Incorrect: double quotes expand before trap runs
trap "rm -f $tempfile" EXIT
```

## Integration with Claude Code

### Commands Location
- Commands installed to `.claude/commands/agent-os/`
- Claude Code automatically discovers and registers them
- Commands run as independent bash scripts

### Standards Context
- Standards available in `agent-os/standards/`
- `/inject-standards` adds them to conversation context
- Plan mode can reference standards via `@agent-os/standards/...` format

### Workflow Integration
1. User runs `/discover-standards` → creates standards
2. User runs `/inject-standards` → makes them available
3. User runs Claude Code commands → standards in context
4. Plan mode executes with full standard guidelines

## Testing & Validation

### Shellcheck Compliance
All scripts pass `shellcheck -x` from scripts directory:
- SC2155 fixes: declare and assign separately
- SC2162 fixes: `read -r` for safe input
- SC2004 fixes: proper array indexing without `$`

### Dry-Run Testing
```bash
bash scripts/project-install.sh --dry-run --verbose
```

Shows what would happen without making changes.

### Validation Checks
- Profile existence before use
- File permissions before copying
- Configuration syntax before parsing
- Circular dependency detection
