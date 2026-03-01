#!/bin/bash
#
# install-attribution-policy.sh - Install AI Attribution Policy enforcement
#
# This script installs the complete AI Attribution Policy enforcement system:
# - Git hooks (commit-msg, pre-commit)
# - CI checks (GitHub Actions)
# - Policy documentation
#
# Usage:
#   cd your-project
#   bash ai-dev-tasks/scripts/install-attribution-policy.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}⚖️  AI Attribution Policy Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Smart git repository detection
echo "🔍 Detecting git repository..."

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Error: git command not found${NC}"
    exit 1
fi

if ! git rev-parse --git-dir &> /dev/null; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
CURRENT_DIR=$(pwd)

if [ "$CURRENT_DIR" != "$GIT_ROOT" ]; then
    echo -e "${YELLOW}📍 Git root detected: $GIT_ROOT${NC}"
    echo -e "${GREEN}✨ Auto-correcting: Changing to git root...${NC}"
    cd "$GIT_ROOT"
    echo -e "${GREEN}✅ Now in: $(pwd)${NC}"
    echo ""
fi

# Check if ai-dev-tasks exists
if [ ! -d "ai-dev-tasks" ]; then
    echo -e "${RED}❌ Error: ai-dev-tasks submodule not found${NC}"
    echo "Please add ai-dev-tasks as a submodule first:"
    echo "  git submodule add https://github.com/FutureTranz-Inc/ai-dev-tasks.git"
    exit 1
fi

echo "📄 Installing AI Attribution Policy..."
echo ""

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

INSTALLED_COUNT=0
SKIPPED_COUNT=0

# Install commit-msg hook
if [ -f ".git/hooks/commit-msg" ]; then
    echo -e "${YELLOW}⚠️  .git/hooks/commit-msg already exists${NC}"
    echo "   Creating backup: .git/hooks/commit-msg.backup"
    cp .git/hooks/commit-msg .git/hooks/commit-msg.backup
fi

cp ai-dev-tasks/scripts/hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
echo -e "${GREEN}✅ Installed: commit-msg hook (blocks AI attribution)${NC}"
INSTALLED_COUNT=$((INSTALLED_COUNT + 1))

# Install pre-commit hook
if [ -f ".git/hooks/pre-commit" ]; then
    echo -e "${YELLOW}⚠️  .git/hooks/pre-commit already exists${NC}"
    echo "   Creating backup: .git/hooks/pre-commit.backup"
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup
fi

cp ai-dev-tasks/scripts/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo -e "${GREEN}✅ Installed: pre-commit hook (strips AI attribution)${NC}"
INSTALLED_COUNT=$((INSTALLED_COUNT + 1))

# Install CI check script
if [ ! -d "scripts" ]; then
    mkdir -p scripts
fi

if [ -f "scripts/ci-check-attribution.sh" ]; then
    echo -e "${YELLOW}⚠️  scripts/ci-check-attribution.sh already exists (skipping)${NC}"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
else
    cp ai-dev-tasks/scripts/ci-check-attribution.sh scripts/ci-check-attribution.sh
    chmod +x scripts/ci-check-attribution.sh
    echo -e "${GREEN}✅ Installed: CI attribution check script${NC}"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi

# Install GitHub Actions workflow
if [ ! -d ".github/workflows" ]; then
    mkdir -p .github/workflows
fi

if [ -f ".github/workflows/attribution-policy.yml" ]; then
    echo -e "${YELLOW}⚠️  .github/workflows/attribution-policy.yml already exists (skipping)${NC}"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
else
    cp ai-dev-tasks/.github/workflows/attribution-policy.yml .github/workflows/attribution-policy.yml
    echo -e "${GREEN}✅ Installed: GitHub Actions workflow${NC}"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi

# Copy policy document to project root
if [ -f "AI_ATTRIBUTION_POLICY.md" ]; then
    echo -e "${YELLOW}⚠️  AI_ATTRIBUTION_POLICY.md already exists (skipping)${NC}"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
else
    cp ai-dev-tasks/AI_ATTRIBUTION_POLICY.md AI_ATTRIBUTION_POLICY.md
    echo -e "${GREEN}✅ Installed: AI Attribution Policy document${NC}"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi

echo ""
echo "🔍 Verification..."
echo ""

# Verify installation
VERIFICATION_PASSED=true

if [ -x ".git/hooks/commit-msg" ]; then
    echo -e "${GREEN}✅ commit-msg hook installed and executable${NC}"
else
    echo -e "${RED}❌ commit-msg hook not properly installed${NC}"
    VERIFICATION_PASSED=false
fi

if [ -x ".git/hooks/pre-commit" ]; then
    echo -e "${GREEN}✅ pre-commit hook installed and executable${NC}"
else
    echo -e "${RED}❌ pre-commit hook not properly installed${NC}"
    VERIFICATION_PASSED=false
fi

if [ -f "AI_ATTRIBUTION_POLICY.md" ]; then
    echo -e "${GREEN}✅ AI Attribution Policy document present${NC}"
else
    echo -e "${RED}❌ AI Attribution Policy document not found${NC}"
    VERIFICATION_PASSED=false
fi

echo ""

if [ "$VERIFICATION_PASSED" = true ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 AI Attribution Policy Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📊 Summary:"
    echo "   - Components installed: $INSTALLED_COUNT"
    echo "   - Components skipped:   $SKIPPED_COUNT"
    echo ""
    echo "🛡️  Enforcement Active:"
    echo "   ✅ Local commits blocked if AI attribution detected"
    echo "   ✅ Staged files automatically cleaned of AI attribution"
    echo "   ✅ CI checks will fail PRs with AI attribution"
    echo ""
    echo "📚 Policy Details:"
    echo "   See: AI_ATTRIBUTION_POLICY.md"
    echo ""
    echo "🧪 Test the Policy:"
    echo ""
    echo "🧹 Clean Existing History (optional):"
    echo "   bash ai-dev-tasks/scripts/clean-ai-attribution-history.sh"
    echo ""
    echo "✅ Your project now enforces human-only authorship attribution!"
    echo ""
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}⚠️  Installation completed with errors${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Please review errors above and fix manually."
    exit 1
fi
