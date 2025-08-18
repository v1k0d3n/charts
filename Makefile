# Helm Charts Repository Makefile
# This Makefile manages fetching, packaging, and publishing Helm charts

# Configuration
REPO_NAME := v1k0d3n
REPO_URL := https://$(REPO_NAME).github.io/charts
CHARTS_DIR := charts
SOURCES_DIR := sources
TEMP_DIR := .temp

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Initialize repository structure
.PHONY: init
init: ## Initialize the repository structure
	@echo "Creating directory structure..."
	mkdir -p $(CHARTS_DIR)
	mkdir -p $(SOURCES_DIR)
	mkdir -p $(TEMP_DIR)
	@echo "Repository structure initialized"

# Update all charts
.PHONY: update-charts
update-charts: ## Update all charts to their latest versions
	@echo "Updating all charts..."
	@if [ -d "$(SOURCES_DIR)" ] && [ -n "$$(ls $(SOURCES_DIR)/*.yaml 2>/dev/null)" ]; then \
		for chart in $$(ls $(SOURCES_DIR)/*.yaml | xargs -n1 basename -s .yaml); do \
			echo "Processing chart: $$chart"; \
			$(MAKE) update-chart CHART=$$chart; \
		done; \
	else \
		echo "No chart sources found in $(SOURCES_DIR)"; \
	fi
	@echo "All charts updated"

# Update specific chart
.PHONY: update-chart
update-chart: ## Update a specific chart (use CHART=chartname)
	@if [ -z "$(CHART)" ]; then \
		echo "Error: CHART variable is required. Usage: make update-chart CHART=chartname"; \
		exit 1; \
	fi
	@echo "Updating chart: $(CHART)"
	@if [ ! -f "$(SOURCES_DIR)/$(CHART).yaml" ]; then \
		echo "Error: Source configuration for $(CHART) not found in $(SOURCES_DIR)/$(CHART).yaml"; \
		exit 1; \
	fi
	@$(MAKE) fetch-chart CHART=$(CHART)
	@$(MAKE) package-chart CHART=$(CHART)
	@echo "Chart $(CHART) updated successfully"

# Fetch chart from source repository
.PHONY: fetch-chart
fetch-chart: ## Fetch chart from source repository
	@echo "Fetching chart $(CHART) from source..."
	@source_config=$$(cat $(SOURCES_DIR)/$(CHART).yaml); \
	repo_url=$$(echo "$$source_config" | grep '^repo_url:' | cut -d' ' -f2); \
	chart_path=$$(echo "$$source_config" | grep '^chart_path:' | cut -d' ' -f2); \
	version=$$(echo "$$source_config" | grep '^version:' | cut -d' ' -f2); \
	ref=$$(echo "$$source_config" | grep '^ref:' | cut -d' ' -f2); \
	\
	if [ -n "$$version" ]; then \
		echo "Fetching version $$version"; \
		helm pull $$repo_url/$(CHART) --version $$version --untar --untardir $(TEMP_DIR); \
	elif [ -n "$$ref" ]; then \
		echo "Fetching from git ref $$ref"; \
		rm -rf $(TEMP_DIR)/$(CHART)-src; \
		git clone --depth 1 --branch $$ref $$repo_url $(TEMP_DIR)/$(CHART)-src; \
		cp -r $(TEMP_DIR)/$(CHART)-src/$$chart_path $(TEMP_DIR)/$(CHART); \
	else \
		echo "Fetching latest version"; \
		helm pull $$repo_url/$(CHART) --untar --untardir $(TEMP_DIR); \
	fi

# Package chart
.PHONY: package-chart
package-chart: ## Package chart for distribution
	@echo "Packaging chart $(CHART)..."
	@if [ ! -d "$(TEMP_DIR)/$(CHART)" ]; then \
		echo "Error: Chart source not found in $(TEMP_DIR)/$(CHART)"; \
		exit 1; \
	fi
	@mkdir -p $(CHARTS_DIR)/$(CHART)
	@helm package $(TEMP_DIR)/$(CHART) --destination $(CHARTS_DIR)/$(CHART)
	@echo "Chart packaged successfully"

# Update repository index
.PHONY: index
index: ## Update the Helm repository index
	@echo "Updating repository index..."
	@helm repo index $(CHARTS_DIR) --url $(REPO_URL)
	@echo "Repository index updated"

# Clean temporary files
.PHONY: clean
clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	rm -rf $(TEMP_DIR)
	@echo "Cleanup completed"

# Full update workflow
.PHONY: publish
publish: update-charts index clean ## Complete workflow: update charts, rebuild index, and clean
	@echo "Repository published successfully"

# Test repository
.PHONY: test
test: ## Test the repository
	@echo "Testing repository..."
	@helm repo add test-repo $(REPO_URL)
	@helm repo update
	@helm search repo test-repo
	@helm repo remove test-repo
	@echo "Repository test completed"

# Show chart versions
.PHONY: versions
versions: ## Show available chart versions
	@echo "Available chart versions:"
	@if [ -d "$(CHARTS_DIR)" ]; then \
		for chart in $$(ls $(CHARTS_DIR)/*/ 2>/dev/null | xargs -n1 basename); do \
			echo "$$chart:"; \
			ls $(CHARTS_DIR)/$$chart/*.tgz 2>/dev/null | xargs -n1 basename -s .tgz | sort -V; \
			echo; \
		done; \
	else \
		echo "No charts directory found"; \
	fi

# Add new chart source
.PHONY: add-chart
add-chart: ## Add a new chart source (use CHART=name REPO=url PATH=path VERSION=version)
	@if [ -z "$(CHART)" ] || [ -z "$(REPO)" ] || [ -z "$(PATH)" ]; then \
		echo "Error: CHART, REPO, and PATH variables are required."; \
		echo "Usage: make add-chart CHART=chartname REPO=https://github.com/user/repo PATH=helm/ VERSION=1.0.0"; \
		exit 1; \
	fi
	@echo "Adding chart source: $(CHART)"
	@echo "repo_url: $(REPO)" > $(SOURCES_DIR)/$(CHART).yaml
	@echo "chart_path: $(PATH)" >> $(SOURCES_DIR)/$(CHART).yaml
	@if [ -n "$(VERSION)" ]; then echo "version: $(VERSION)" >> $(SOURCES_DIR)/$(CHART).yaml; fi
	@if [ -n "$(REF)" ]; then echo "ref: $(REF)" >> $(SOURCES_DIR)/$(CHART).yaml; fi
	@echo "Chart source configuration created: $(SOURCES_DIR)/$(CHART).yaml"
