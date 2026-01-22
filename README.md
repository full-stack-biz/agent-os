<img width="1280" height="640" alt="agent-os-og" src="https://github.com/user-attachments/assets/f70671a2-66e8-4c80-8998-d4318af55d10" />

## Your system for spec-driven agentic development.

[Agent OS](https://buildermethods.com/agent-os) transforms AI coding agents from confused interns into productive developers. With structured workflows that capture your standards, your stack, and the unique details of your codebase, Agent OS gives your agents the specs they need to ship quality code on the first try—not the fifth.

Use it with:

✅ Claude Code, Cursor, or any other AI coding tool.

✅ New products or established codebases.

✅ Big features, small fixes, or anything in between.

✅ Any language or framework.

---

## Quick Start

### Installation

The simplest way to install Agent OS:

```bash
# Install Agent OS globally (to ~/.agent-os by default)
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash

# Install to a custom directory
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash -s -- --base-dir /custom/path

# Non-interactive mode for CI/CD
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash -s -- --non-interactive
```

Then, in your project:

```bash
# Install Agent OS into your project
cd /path/to/project
~/.agent-os/scripts/project-install.sh

# Or use a custom Agent OS installation
/path/to/custom/agent-os/scripts/project-install.sh
```

### Custom Installation Directory

Agent OS supports installing to any custom directory, enabling:

- **Multiple installations** - Test different versions or maintain separate configurations
- **CI/CD pipelines** - Specify exact installation paths for automated workflows
- **Team workflows** - Different installations for different teams or environments
- **Development** - Test and iterate on Agent OS itself

**Set your custom installation directory using any of these methods:**

```bash
# 1. CLI flag (highest priority)
bash scripts/project-install.sh --base-dir /custom/agent-os

# 2. Environment variable
export AGENT_OS_HOME=/custom/agent-os
bash scripts/project-install.sh

# 3. Default location (if no flag or env var set)
bash scripts/project-install.sh  # Uses ~/.agent-os
```

**Example: Test a custom Agent OS version in a project**

```bash
# Copy/clone Agent OS to a test location
cp -r agent-os /tmp/agent-os-test

# Install into your project using the test version
cd /path/to/project
/tmp/agent-os-test/scripts/project-install.sh
```

---

### Full Documentation & Installation

Complete guides, advanced usage, & best practices 👉 [buildermethods.com/agent-os](https://buildermethods.com/agent-os)

---

### Follow updates & releases

Read the [changelog](CHANGELOG.md)

[Subscribe to be notified of major new releases of Agent OS](https://buildermethods.com/agent-os)

---

### Created by Brian Casel @ Builder Methods

Created by Brian Casel, the creator of [Builder Methods](https://buildermethods.com), where Brian helps professional software developers and teams build with AI.

Get Brian's free resources on building with AI:
- [Builder Briefing newsletter](https://buildermethods.com)
- [YouTube](https://youtube.com/@briancasel)

Join [Builder Methods Pro](https://buildermethods.com/pro) for official support and connect with our community of AI-first builders:
