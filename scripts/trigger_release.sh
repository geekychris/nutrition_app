#!/bin/bash

# Release Build Trigger Script for Nutrition Tracker
# This script creates a git tag and pushes it, triggering a release build
#
# Usage: ./scripts/trigger_release.sh [version] [options]
# Example: ./scripts/trigger_release.sh 1.0.5
# Example: ./scripts/trigger_release.sh 1.0.5 --skip-increment
# Example: ./scripts/trigger_release.sh 1.0.5 --message "Bug fixes and improvements"

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
VERSION=""
TAG_MESSAGE=""
SKIP_INCREMENT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-increment)
            SKIP_INCREMENT=true
            shift
            ;;
        --message)
            TAG_MESSAGE="$2"
            shift 2
            ;;
        -m)
            TAG_MESSAGE="$2"
            shift 2
            ;;
        *)
            if [ -z "$VERSION" ]; then
                VERSION="$1"
            fi
            shift
            ;;
    esac
done

echo -e "${BLUE}======================================"
echo "Nutrition Tracker Release Trigger"
echo -e "======================================${NC}"
echo ""

# Validate version argument
if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Error: Version number required${NC}"
    echo ""
    echo "Usage: $0 <version> [options]"
    echo ""
    echo "Options:"
    echo "  --skip-increment     Skip build number increment"
    echo "  --message, -m <msg>  Custom tag message"
    echo ""
    echo "Example: $0 1.0.5"
    echo "Example: $0 1.0.5 --message 'Bug fixes and improvements'"
    exit 1
fi

# Validate version format (semantic versioning)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    echo -e "${YELLOW}⚠️  Warning: Version '$VERSION' doesn't follow semantic versioning (e.g., 1.0.5)${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

TAG_NAME="v$VERSION"

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: Tag '$TAG_NAME' already exists${NC}"
    echo ""
    echo "Existing tags:"
    git tag --list "v*" | tail -5
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    git status --short
    echo ""
    read -p "Commit these changes before tagging? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        git commit -m "Prepare for release $VERSION"
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${YELLOW}⚠️  Continuing with uncommitted changes${NC}"
    fi
fi

# Increment build number unless skipped
if [ "$SKIP_INCREMENT" = false ]; then
    echo ""
    echo "Incrementing build number..."
    if [ -x "$PROJECT_DIR/scripts/increment_build.sh" ]; then
        "$PROJECT_DIR/scripts/increment_build.sh"
        
        # Commit the build number change
        if ! git diff-index --quiet HEAD --; then
            git add -A
            git commit -m "Increment build number for release $VERSION"
            echo -e "${GREEN}✅ Build number committed${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  increment_build.sh not found or not executable${NC}"
    fi
fi

# Set default tag message if not provided
if [ -z "$TAG_MESSAGE" ]; then
    TAG_MESSAGE="Release $VERSION"
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo ""
echo -e "${BLUE}Release Summary:${NC}"
echo "  Version:    $VERSION"
echo "  Tag:        $TAG_NAME"
echo "  Branch:     $CURRENT_BRANCH"
echo "  Message:    $TAG_MESSAGE"
echo ""

# Confirm release
read -p "Create and push release tag? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create annotated tag
echo ""
echo "Creating tag '$TAG_NAME'..."
git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
echo -e "${GREEN}✅ Tag created${NC}"

# Push commits and tag
echo ""
echo "Pushing to remote..."
git push origin "$CURRENT_BRANCH"
git push origin "$TAG_NAME"

echo ""
echo -e "${GREEN}======================================"
echo "✅ Release tag created successfully!"
echo -e "======================================${NC}"
echo ""
echo "Tag:     $TAG_NAME"
echo "Message: $TAG_MESSAGE"
echo ""
echo "Next steps:"
echo "1. Monitor your CI/CD pipeline (if configured)"
echo "2. Or run: ./scripts/archive_and_export.sh"
echo "3. Distribute via Xcode Organizer"
echo ""
