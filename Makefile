# Makefile for VS Code R Extension (Fork)

PACKAGE_NAME = r-workdir
VERSION = $(shell node -p "require('./package.json').version")
VSIX_FILE = $(PACKAGE_NAME)-$(VERSION).vsix

# Default target
.PHONY: help
help:
	@echo "VS Code R Extension (Fork) - Build and Release"
	@echo ""
	@echo "Available targets:"
	@echo "  install-deps    Install all dependencies including vsce"
	@echo "  build          Build the extension"
	@echo "  test           Run tests"
	@echo "  lint           Run linting"
	@echo "  package        Create .vsix package for release"
	@echo "  clean          Clean build artifacts"
	@echo "  release        Automated release with GitHub CLI (tags, pushes, creates release)"
	@echo "  version        Show current version"
	@echo ""
	@echo "Current version: $(VERSION)"

# Install dependencies including vsce
.PHONY: install-deps
install-deps:
	npm install
	npm install -g @vscode/vsce

# Build the extension
.PHONY: build
build:
	npm run build

# Run tests
.PHONY: test
test:
	npm test

# Run linting
.PHONY: lint
lint:
	npm run lint

# Create VSIX package
.PHONY: package
package: build
	@echo "Creating VSIX package..."
	@if ! command -v vsce >/dev/null 2>&1; then \
		echo "Error: vsce not found. Run 'make install-deps' first."; \
		exit 1; \
	fi
	vsce package --out $(VSIX_FILE)
	@echo "Package created: $(VSIX_FILE)"
	@echo "Users can install this by:"
	@echo "  1. Download $(VSIX_FILE) from GitHub releases"
	@echo "  2. In VS Code: Ctrl+Shift+P > 'Extensions: Install from VSIX...'"
	@echo "  3. Select the downloaded .vsix file"

# Clean build artifacts
.PHONY: clean
clean:
	rm -rf out/
	rm -rf dist/
	rm -rf node_modules/
	rm -f *.vsix

# Fully automated release with GitHub CLI
.PHONY: release
release: clean install-deps lint test package
	@echo ""
	@echo "🚀 Starting automated release process..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "Error: GitHub CLI (gh) not found. Install it first."; \
		exit 1; \
	fi
	@echo "📝 Creating git tag v$(VERSION)..."
	git tag v$(VERSION)
	@echo "⬆️  Pushing tag to GitHub..."
	git push origin v$(VERSION)
	@echo "🎯 Creating GitHub release..."
	gh release create v$(VERSION) $(VSIX_FILE) \
		--title "v$(VERSION) - R Extension with Configurable Working Directory" \
		--notes "Release v$(VERSION) of the R extension fork with configurable working directory support.\n\n## Installation\n\n1. Download the \`$(VSIX_FILE)\` file from this release\n2. In VS Code: \`Ctrl+Shift+P\` > \"Extensions: Install from VSIX...\"\n3. Select the downloaded .vsix file\n\n## Features\n\n- All features from the original R extension\n- **New**: Configurable working directory via \`r.workingDirectory\` setting\n- Support for renv environments and complex project structures\n\nSee the [README](https://github.com/torbjorn/vscode-R#readme) for more details."
	@echo ""
	@echo "✅ Automated release complete!"
	@echo "🔗 View release: https://github.com/torbjorn/vscode-R/releases/tag/v$(VERSION)"

# Show current version
.PHONY: version
version:
	@echo $(VERSION)

# Quick development build
.PHONY: dev
dev:
	npm run build

# Watch mode for development
.PHONY: watch
watch:
	npm run watch