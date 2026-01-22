#!/bin/bash

# Agent OS Web Installer
# Simplified entry point for cloud/web-based installation
# Usage: curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash

set -e

# Color codes for output
BLUE='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display welcome banner
display_banner() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Agent OS Installation               ║${NC}"
    echo -e "${BLUE}║   Spec-driven agentic development     ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
}

# Check system compatibility
check_system() {
    local exit_code=0

    echo -e "${BLUE}Checking system compatibility...${NC}"
    echo ""

    # Check for curl
    if command -v curl &> /dev/null; then
        echo -e "${GREEN}✓${NC} curl is installed"
    else
        echo -e "${RED}✗${NC} curl is not installed"
        exit_code=1
    fi

    # Check bash version
    local bash_version=${BASH_VERSION%%.*}
    if [[ $bash_version -ge 3 ]]; then
        echo -e "${GREEN}✓${NC} bash $BASH_VERSION (supported)"
    else
        echo -e "${YELLOW}⚠${NC} bash $BASH_VERSION (may have compatibility issues)"
    fi

    # Check OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${GREEN}✓${NC} macOS detected"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${GREEN}✓${NC} Linux detected"
    else
        echo -e "${YELLOW}⚠${NC} Unsupported OS: $OSTYPE (may not work)"
    fi

    echo ""

    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}System requirements not met.${NC}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Display installation info
display_info() {
    echo -e "${BLUE}Installation Configuration:${NC}"
    echo ""

    # Show where it will install
    local install_dir="${AGENT_OS_HOME:-$HOME/agent-os}"
    if [[ "$1" == "--base-dir" ]]; then
        install_dir="$2"
    fi

    echo -e "  Target directory: ${YELLOW}$install_dir${NC}"
    echo ""

    # Check if already installed
    if [[ -d "$install_dir" ]]; then
        echo -e "${YELLOW}Note:${NC} An existing Agent OS installation was found at $install_dir"
        echo "      You'll be prompted to choose an update option."
        echo ""
    fi
}

# Detect and suggest CI/CD environment
detect_ci_environment() {
    if [[ -n "${CI:-}" ]]; then
        echo -e "${BLUE}CI/CD environment detected.${NC}"
        echo "Consider using ${YELLOW}--non-interactive${NC} flag for automated builds:"
        echo ""
        echo -e "  ${YELLOW}curl -sSL .../install.sh | bash -s -- --non-interactive${NC}"
        echo ""
    fi
}

# Main function
main() {
    display_banner
    check_system

    # Get first argument to check for --base-dir or --non-interactive (for display only)
    local base_dir_arg=""
    local base_dir_value=""

    # Parse arguments for display purposes (without consuming them)
    local i=1
    for arg in "$@"; do
        if [[ "$arg" == "--base-dir" ]]; then
            base_dir_arg="--base-dir"
            # Get next argument value
            eval "base_dir_value=\${$((i+1))}"
        fi
        ((i++)) || true
    done

    display_info "$base_dir_arg" "$base_dir_value"
    detect_ci_environment

    # Download and execute base-install.sh with all arguments
    local repo_url="https://github.com/buildermethods/agent-os"
    local install_script="${repo_url}/raw/main/scripts/base-install.sh"

    echo -e "${BLUE}Downloading Agent OS...${NC}"
    echo ""

    # Execute base-install.sh with all passed arguments
    bash <(curl -sSL --fail "$install_script") "$@"
}

# Run main function with all passed arguments
main "$@"
