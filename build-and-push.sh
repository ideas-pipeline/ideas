#!/bin/bash
# Build ideas page and push to GitHub Pages
set -e

SITE_DIR="/data/.openclaw/workspace/ideas-site"
DATA_FILE="/data/.openclaw/workspace/ideas.json"
TEMPLATE="$SITE_DIR/index.html"
OUTPUT="$SITE_DIR/index.html"
REPO_URL="https://ideas-pipeline:${GITHUB_TOKEN}@github.com/ideas-pipeline/ideas.git"

cd "$SITE_DIR"

# Read ideas.json and inject into HTML
DATA=$(cat "$DATA_FILE")

# Create temp file with injected data
python3 -c "
import sys
with open('$TEMPLATE') as f:
    html = f.read()
with open('$DATA_FILE') as f:
    data = f.read().strip()
html = html.replace('INJECT_DATA_HERE', data)
with open('$OUTPUT', 'w') as f:
    f.write(html)
print('Data injected successfully')
"

# Git operations
git add -A
if git diff --cached --quiet 2>/dev/null; then
    echo "No changes to push"
    exit 0
fi
git commit -m "update: $(date '+%Y-%m-%d %H:%M')"
git push "$REPO_URL" master 2>/dev/null || {
    # First push — set upstream
    git push -u "$REPO_URL" master
}
echo "✅ Pushed to GitHub Pages"
