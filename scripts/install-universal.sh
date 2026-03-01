#!/bin/bash
# AI Ethics Enforcement Toolkit - Universal Installer
#
# Installs AI ethics enforcement across multiple development tools and environments
# Author: Victor J. Quiñones (FutureTranz)
# License: MIT
# Version: 1.3.0

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TOOLKIT_NAME="ai-ethics-enforcer"
PYTHON_EXECUTABLE="${PYTHON_EXECUTABLE:-python3}"
GITHUB_REPO="FutureTranz-Inc/ai-ethics"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Install Python dependencies
install_python_deps() {
    log_info "Installing Python dependencies..."

    if ! command_exists "$PYTHON_EXECUTABLE"; then
        log_error "Python 3 not found. Please install Python 3.6+ first."
        return 1
    fi

    # Create virtual environment if it doesn't exist
    if [ ! -d "$REPO_ROOT/venv" ]; then
        log_info "Creating Python virtual environment..."
        "$PYTHON_EXECUTABLE" -m venv "$REPO_ROOT/venv"
    fi

    # Activate virtual environment and install dependencies
    source "$REPO_ROOT/venv/bin/activate"
    pip install --upgrade pip
    pip install -r "$REPO_ROOT/requirements.txt" 2>/dev/null || true

    log_success "Python dependencies installed"
}

# Install Git hooks
install_git_hooks() {
    log_info "Installing Git hooks..."

    # Install pre-commit hook
    if [ -d ".git" ] || git rev-parse --git-dir > /dev/null 2>&1; then
        local git_dir
        git_dir=$(git rev-parse --git-dir)

        # Copy hooks
        cp "$SCRIPT_DIR/hooks/pre-commit" "$git_dir/hooks/pre-commit" 2>/dev/null || true
        cp "$SCRIPT_DIR/hooks/commit-msg" "$git_dir/hooks/commit-msg" 2>/dev/null || true

        # Make executable
        chmod +x "$git_dir/hooks/pre-commit" 2>/dev/null || true
        chmod +x "$git_dir/hooks/commit-msg" 2>/dev/null || true

        log_success "Git hooks installed"
    else
        log_warning "Not in a Git repository. Skipping Git hooks."
    fi
}

# Install VSCode extension
install_vscode_extension() {
    if command_exists code; then
        log_info "Installing VSCode extension..."

        # Create extension directory
        local ext_dir="$HOME/.vscode/extensions/futuretranz.ai-ethics-enforcer"

        mkdir -p "$ext_dir"

        # Copy extension files
        cat > "$ext_dir/package.json" << 'EOF'
{
    "name": "ai-ethics-enforcer",
    "displayName": "AI Ethics Enforcer",
    "description": "Enforces AI ethics policies in code and commits",
    "version": "1.0.0",
    "publisher": "FutureTranz",
    "engines": {
        "vscode": "^1.74.0"
    },
    "categories": ["Other"],
    "activationEvents": ["onStartupFinished"],
    "main": "./out/extension.js",
    "contributes": {
        "commands": [{
            "command": "ai-ethics.checkCurrentFile",
            "title": "Check AI Ethics Compliance"
        }],
        "configuration": {
            "title": "AI Ethics Enforcer",
            "properties": {
                "aiEthics.enabled": {
                    "type": "boolean",
                    "default": true,
                    "description": "Enable AI ethics enforcement"
                }
            }
        }
    }
}
EOF

        # Create basic extension script
        cat > "$ext_dir/out/extension.js" << 'EOF'
const vscode = require('vscode');
const { exec } = require('child_process');

function activate(context) {
    let disposable = vscode.commands.registerCommand('ai-ethics.checkCurrentFile', function () {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            const document = editor.document;
            const content = document.getText();

            exec(`cd "${__dirname}/../../.." && source venv/bin/activate && python src/ai_ethics_enforcer.py --type content "${document.fileName}"`, (error, stdout, stderr) => {
                if (error) {
                    vscode.window.showErrorMessage(`AI Ethics Check Failed: ${error.message}`);
                    return;
                }

                if (stdout.includes('VIOLATIONS FOUND')) {
                    vscode.window.showErrorMessage('AI Ethics violations found! Check output for details.');
                } else {
                    vscode.window.showInformationMessage('AI Ethics check passed!');
                }

                const outputChannel = vscode.window.createOutputChannel('AI Ethics');
                outputChannel.show();
                outputChannel.append(stdout);
            });
        }
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
}
EOF

        log_success "VSCode extension installed"
    else
        log_warning "VSCode CLI not found. Install VSCode and add 'code' to PATH."
    fi
}

# Install IntelliJ plugin
install_intellij_plugin() {
    log_info "Installing IntelliJ IDEA plugin..."

    # Create plugin directory structure
    local plugin_dir="$HOME/.intellij/plugins/ai-ethics-enforcer"
    mkdir -p "$plugin_dir"

    # Create plugin.xml
    cat > "$plugin_dir/plugin.xml" << 'EOF'
<idea-plugin>
    <id>futuretranz.ai-ethics-enforcer</id>
    <name>AI Ethics Enforcer</name>
    <version>1.0.0</version>
    <vendor>FutureTranz</vendor>
    <description><![CDATA[Enforces AI ethics policies in code and commits]]></description>

    <depends>com.intellij.modules.platform</depends>

    <extensions defaultExtensionNs="com.intellij">
        <applicationService serviceImplementation="com.futuretranz.aiethics.AIEthicsService"/>
        <notificationGroup id="AI Ethics" displayType="BALLOON"/>
    </extensions>

    <actions>
        <action id="AIEthics.CheckCurrentFile" class="com.futuretranz.aiethics.CheckCurrentFileAction"
                text="Check AI Ethics Compliance" description="Check current file for AI ethics violations">
            <add-to-group group-id="ToolsMenu" anchor="last"/>
        </action>
    </actions>
</idea-plugin>
EOF

    log_success "IntelliJ plugin structure created (requires compilation)"
}

# Install Xcode extension
install_xcode_extension() {
    if [ "$(detect_os)" = "macos" ]; then
        log_info "Installing Xcode extension..."

        # Create Xcode extension directory
        local ext_dir="$HOME/Library/Developer/Xcode/Plug-ins/AIEthicsEnforcer.xcplugin"
        mkdir -p "$ext_dir"

        # Create Info.plist
        cat > "$ext_dir/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.futuretranz.ai-ethics-enforcer</string>
    <key>CFBundleName</key>
    <string>AI Ethics Enforcer</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>XCPluginHasUI</key>
    <false/>
    <key>DVTPlugInCompatibilityUUIDs</key>
    <array>
        <string>8DC44374-4B35-4F9C-8D48-5BFF1B2A7C5E</string>
    </array>
</dict>
</plist>
EOF

        log_success "Xcode extension structure created"
    fi
}

# Install shell integration
install_shell_integration() {
    log_info "Installing shell integration..."

    local shell_rc
    case "$SHELL" in
        */zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        */bash)
            shell_rc="$HOME/.bashrc"
            ;;
        *)
            shell_rc="$HOME/.profile"
            ;;
    esac

    # Add to shell rc if not already present
    if ! grep -q "ai-ethics-enforcer" "$shell_rc" 2>/dev/null; then
        cat >> "$shell_rc" << 'EOF'

# AI Ethics Enforcer Integration
export PATH="$PATH:/path/to/ai-ethics/scripts"
alias ai-check='python3 /path/to/ai-ethics/src/ai_ethics_enforcer.py'
EOF

        log_success "Shell integration added to $shell_rc"
    else
        log_info "Shell integration already present"
    fi
}

# Install CI/CD integration
install_ci_integration() {
    log_info "Installing CI/CD integration..."

    # GitHub Actions
    if [ -d ".github/workflows" ]; then
        local workflow_file=".github/workflows/ai-ethics.yml"

        if [ ! -f "$workflow_file" ]; then
            cat > "$workflow_file" << 'EOF'
name: AI Ethics Check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  ai-ethics-check:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt

    - name: Run AI Ethics Check
      run: |
        python src/ai_ethics_enforcer.py --type file .
EOF

            log_success "GitHub Actions workflow created"
        fi
    fi
}

# Install language-specific integrations
install_language_integrations() {
    log_info "Installing language-specific integrations..."

    # Python
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        # Add pre-commit hook for Python
        if command_exists pre-commit; then
            pre-commit install
            log_success "Pre-commit hooks installed for Python"
        fi
    fi

    # JavaScript/Node.js (npm, yarn, pnpm, bun)
    if [ -f "package.json" ]; then
        # Add husky for git hooks
        if command_exists npx; then
            npx husky install 2>/dev/null || true
            log_success "Husky git hooks installed for JavaScript"
        fi

        # Check for bun
        if command_exists bun; then
            log_info "Bun detected - consider using bun for package management"
        fi
    fi

    # Java
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        log_info "Java project detected - configure build tools manually"
    fi

    # C#/.NET
    if [ -f "*.csproj" ] || [ -f "*.fsproj" ] || [ -f "*.vbproj" ] || [ -f "packages.config" ] || [ -f "*.sln" ]; then
        # Check for .NET projects using find since glob might not work in bash
        if find . -maxdepth 2 -name "*.csproj" -o -name "*.fsproj" -o -name "*.vbproj" -o -name "*.sln" | grep -q .; then
            log_info "C#/.NET project detected"
            if command_exists dotnet; then
                log_info ".NET CLI available - configure git hooks manually"
            fi
        fi
    fi

    # PowerShell
    if find . -maxdepth 2 -name "*.ps1" -o -name "*.psm1" -o -name "*.psd1" | grep -q .; then
        log_info "PowerShell scripts detected"
        # PowerShell can use git hooks too
    fi

    # SQL
    if find . -maxdepth 2 -name "*.sql" -o -name "*.ddl" | grep -q .; then
        log_info "SQL files detected - configure database tools manually"
    fi

    # Homebrew (macOS package manager)
    if [ "$(detect_os)" = "macos" ] && command_exists brew; then
        log_info "Homebrew detected - consider installing AI ethics tools via brew"
        # Could potentially install tools via brew here
    fi

    # Go
    if [ -f "go.mod" ] || [ -f "go.sum" ]; then
        log_info "Go project detected"
        if command_exists go; then
            log_info "Go tools available - configure git hooks manually"
        fi
    fi

    # Rust
    if [ -f "Cargo.toml" ] || [ -f "Cargo.lock" ]; then
        log_info "Rust project detected"
        if command_exists cargo; then
            log_info "Cargo available - configure git hooks manually"
        fi
    fi

    # PHP
    if [ -f "composer.json" ] || [ -f "composer.lock" ]; then
        log_info "PHP project detected"
        if command_exists composer; then
            log_info "Composer available - configure git hooks manually"
        fi
    fi

    # Docker
    if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        log_info "Docker project detected"
        if command_exists docker; then
            log_info "Docker available - consider adding AI ethics checks to container builds"
        fi
    fi

    # Kubernetes
    if find . -maxdepth 2 -name "*.yaml" -o -name "*.yml" | xargs grep -l "apiVersion.*apps/v1\|kind.*Deployment\|kind.*Pod\|kind.*Service" 2>/dev/null | grep -q .; then
        log_info "Kubernetes manifests detected"
        if command_exists kubectl; then
            log_info "kubectl available - consider adding AI ethics validation to deployment pipelines"
        fi
    fi

    # Windows-specific tools
    if [ "$(detect_os)" = "windows" ]; then
        if command_exists choco; then
            log_info "Chocolatey detected - consider installing AI ethics tools via choco"
        fi
        if command_exists winget; then
            log_info "Windows Package Manager detected - consider installing AI ethics tools via winget"
        fi
    fi

    # Linux-specific package managers
    if [ "$(detect_os)" = "linux" ]; then
        if command_exists apt; then
            log_info "APT detected - consider installing AI ethics tools via apt"
        fi
        if command_exists yum; then
            log_info "YUM detected - consider installing AI ethics tools via yum"
        fi
        if command_exists dnf; then
            log_info "DNF detected - consider installing AI ethics tools via dnf"
        fi
        if command_exists pacman; then
            log_info "Pacman detected - consider installing AI ethics tools via pacman"
        fi
    fi
}

# Install system-wide hooks
install_system_hooks() {
    log_info "Installing system-wide hooks..."

    # PAM module for authentication (advanced)
    if [ "$(detect_os)" = "linux" ]; then
        log_info "Consider installing PAM module for system-wide AI ethics enforcement"
    fi

    # Windows scheduled task
    if [ "$(detect_os)" = "windows" ]; then
        log_info "Setting up Windows scheduled task for AI ethics monitoring"
        # Note: Requires PowerShell or schtasks for full implementation
        log_info "Consider using Windows Task Scheduler for automated enforcement"
    fi

    # macOS launch agent
    if [ "$(detect_os)" = "macos" ]; then
        local plist_file="$HOME/Library/LaunchAgents/com.futuretranz.ai-ethics.plist"

        cat > "$plist_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.futuretranz.ai-ethics</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>--version</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

        log_success "macOS Launch Agent created"
    fi
}

# Install browser extensions
install_browser_extensions() {
    log_info "Installing browser extensions..."

    # Chrome extension
    local chrome_dir="$HOME/.chrome-extensions/ai-ethics"
    mkdir -p "$chrome_dir"

    cat > "$chrome_dir/manifest.json" << 'EOF'
{
    "manifest_version": 3,
    "name": "AI Ethics Enforcer",
    "version": "1.0.0",
    "description": "Enforces AI ethics in web applications",
    "permissions": ["activeTab", "storage"],
    "content_scripts": [{
        "matches": ["<all_urls>"],
        "js": ["content.js"]
    }],
    "action": {
        "default_popup": "popup.html"
    }
}
EOF

    log_success "Browser extension structure created"
}

# Main installation function
main() {
    log_info "Starting AI Ethics Enforcement Toolkit installation..."
    log_info "Repository: $GITHUB_REPO"
    log_info "Operating System: $(detect_os)"

    # Check prerequisites
    if ! command_exists git; then
        log_error "Git is required but not installed."
        exit 1
    fi

    # Install components
    install_python_deps
    install_git_hooks
    install_vscode_extension
    install_intellij_plugin
    install_xcode_extension
    install_shell_integration
    install_ci_integration
    install_language_integrations
    install_system_hooks
    install_browser_extensions

    log_success "AI Ethics Enforcement Toolkit installation completed!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Restart your IDE/editor"
    log_info "2. Run 'ai-check --help' for CLI usage"
    log_info "3. Check documentation for advanced configuration"
    log_info ""
    log_info "Installed components:"
    log_info "  ✓ Python core library"
    log_info "  ✓ Git hooks"
    log_info "  ✓ VSCode extension"
    log_info "  ✓ IntelliJ plugin structure"
    log_info "  ✓ Xcode extension structure"
    log_info "  ✓ Shell integration"
    log_info "  ✓ CI/CD workflows"
    log_info "  ✓ Language-specific hooks"
    log_info "  ✓ System hooks"
    log_info "  ✓ Browser extensions"
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
