#!/bin/bash

# Demonstration script for the Helm Charts Repository
# This script shows the complete workflow for adding and updating charts

set -e

echo "=== Helm Charts Repository Demo ==="
echo ""

# Check if we're in the right directory
if [ ! -f "Makefile" ]; then
    echo "Error: Please run this script from the repository root"
    exit 1
fi

echo "1. Initializing repository structure..."
make init

echo ""
echo "2. Adding kubevirt-redfish chart from git repository..."
./scripts/add-git-chart.sh kubevirt-redfish-demo \
    https://github.com/v1k0d3n/kubevirt-redfish \
    helm \
    v0.2.1

echo ""
echo "3. Updating the chart..."
make update-chart CHART=kubevirt-redfish-demo

echo ""
echo "4. Updating repository index..."
make index

echo ""
echo "5. Showing available chart versions..."
make versions

echo ""
echo "6. Cleaning up temporary files..."
make clean

echo ""
echo "=== Demo completed successfully! ==="
echo ""
echo "Next steps:"
echo "1. Commit and push your changes"
echo "2. Enable GitHub Pages in repository settings"
echo "3. Users can then add your repository with:"
echo "   helm repo add v1k0d3n https://v1k0d3n.github.io/charts"
echo ""
echo "Repository structure created:"
echo "- charts/          # Chart packages"
echo "- sources/         # Chart source configurations"
echo "- .github/workflows/ # GitHub Actions workflows"
