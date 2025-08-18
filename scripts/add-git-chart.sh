#!/bin/bash

# Script to add a chart from a git repository
# Usage: ./scripts/add-git-chart.sh <chart-name> <git-repo-url> <chart-path> [tag-or-commit]

set -e

if [ $# -lt 3 ]; then
    echo "Usage: $0 <chart-name> <git-repo-url> <chart-path> [tag-or-commit]"
    echo "Example: $0 my-chart https://github.com/user/repo helm/ v1.0.0"
    echo "Example: $0 my-chart https://github.com/user/repo helm/ main"
    exit 1
fi

CHART_NAME="$1"
REPO_URL="$2"
CHART_PATH="$3"
REF="${4:-main}"

echo "Adding chart: $CHART_NAME"
echo "Repository: $REPO_URL"
echo "Chart path: $CHART_PATH"
echo "Reference: $REF"

# Create the source configuration
cat > "sources/$CHART_NAME.yaml" << EOF
# $CHART_NAME chart source configuration
repo_url: $REPO_URL
chart_path: $CHART_PATH
ref: $REF
EOF

echo "Chart source configuration created: sources/$CHART_NAME.yaml"
echo ""
echo "To update this chart, run:"
echo "  make update-chart CHART=$CHART_NAME"
echo ""
echo "To update all charts, run:"
echo "  make update-charts"
