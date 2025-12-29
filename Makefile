# Next.js Blueprint Clone Script
# Usage: make clone <project-name> [DESCRIPTION="My awesome project"]

BLUEPRINT_DIR = nextjs-blueprint

.PHONY: clone help

# Default target
help:
	@echo "Next.js Blueprint Clone Tool"
	@echo ""
	@echo "Usage:"
	@echo "  make clone <project-name> [DESCRIPTION=\"My awesome project\"]"
	@echo ""
	@echo "Examples:"
	@echo "  make clone hello"
	@echo "  make clone my-blog DESCRIPTION=\"Personal blog site\""
	@echo ""
	@echo "This will:"
	@echo "  1. Create a new directory with the project name"
	@echo "  2. Copy all files from $(BLUEPRINT_DIR) except .git, node_modules, .DS_Store"
	@echo "  3. Update package.json with new project name and description"
	@echo "  4. Install dependencies with pnpm"
	@echo "  5. Initialize new git repository"

clone:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Error: Project name is required"; \
		echo "Usage: make clone <project-name>"; \
		exit 1; \
	fi
	$(eval PROJECT_NAME := $(filter-out $@,$(MAKECMDGOALS)))
	@if [ -d "$(PROJECT_NAME)" ]; then \
		echo "Error: Directory $(PROJECT_NAME) already exists"; \
		exit 1; \
	fi
	@echo "� Creeating new project: $(PROJECT_NAME)"
	@echo "📁 Creating directory..."
	@mkdir -p $(PROJECT_NAME)
	@echo "📋 Copying files..."
	@rsync -av --exclude='.git' --exclude='node_modules' --exclude='.DS_Store' $(BLUEPRINT_DIR)/ $(PROJECT_NAME)/
	@echo "📋 Copying .kiro configuration..."
	@if [ -d ".kiro" ]; then \
		cp -r .kiro $(PROJECT_NAME)/; \
	fi
	@echo "📝 Updating package.json..."
	@sed -i '' 's/"name": "nextjs-blueprint"/"name": "$(PROJECT_NAME)"/' $(PROJECT_NAME)/package.json
	@if [ -n "$(DESCRIPTION)" ]; then \
		sed -i '' 's/"version": "0.1.0",/"version": "0.1.0",\n  "description": "$(DESCRIPTION)",/' $(PROJECT_NAME)/package.json; \
	fi
	@echo "📦 Installing dependencies..."
	@cd $(PROJECT_NAME) && pnpm install
	@echo "🔧 Initializing git repository..."
	@cd $(PROJECT_NAME) && git init
	@cd $(PROJECT_NAME) && git add .
	@cd $(PROJECT_NAME) && git commit -m "Initial commit from Next.js Blueprint"
	@echo "✅ Project $(PROJECT_NAME) created successfully!"
	@echo ""
	@echo "Next steps:"
	@echo "  cd $(PROJECT_NAME)"
	@echo "  pnpm dev"

# Catch-all target to handle project name arguments
%:
	@:


