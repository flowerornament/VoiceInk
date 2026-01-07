# Define a directory for dependencies alongside the repository
DEPS_DIR := $(CURDIR)/../VoiceInk-Dependencies
WHISPER_CPP_DIR := $(DEPS_DIR)/whisper.cpp
FRAMEWORK_PATH := $(WHISPER_CPP_DIR)/build-apple/whisper.xcframework

# Build configuration (Debug or Release)
CONFIGURATION ?= Debug
BUILD_DIR := $(CURDIR)/build
APP_NAME := VoiceInk.app
INSTALL_DIR ?= $(HOME)/Applications

.PHONY: all clean whisper setup build check healthcheck help dev run release install uninstall

# Default target
all: check build

# Development workflow
dev: build run

# Prerequisites
check:
	@echo "Checking prerequisites..."
	@command -v git >/dev/null 2>&1 || { echo "git is not installed"; exit 1; }
	@command -v xcodebuild >/dev/null 2>&1 || { echo "xcodebuild is not installed (need Xcode)"; exit 1; }
	@command -v swift >/dev/null 2>&1 || { echo "swift is not installed"; exit 1; }
	@echo "Prerequisites OK"

healthcheck: check

# Build process
whisper:
	@mkdir -p $(DEPS_DIR)
	@if [ ! -d "$(FRAMEWORK_PATH)" ]; then \
		echo "Building whisper.xcframework in $(DEPS_DIR)..."; \
		if [ ! -d "$(WHISPER_CPP_DIR)" ]; then \
			git clone https://github.com/ggerganov/whisper.cpp.git $(WHISPER_CPP_DIR); \
		else \
			(cd $(WHISPER_CPP_DIR) && git pull); \
		fi; \
		cd $(WHISPER_CPP_DIR) && ./build-xcframework.sh; \
	else \
		echo "whisper.xcframework already built in $(DEPS_DIR), skipping build"; \
	fi

setup: whisper
	@echo "Whisper framework is ready at $(FRAMEWORK_PATH)"
	@echo "Please ensure your Xcode project references the framework from this new location."

build: setup
	@echo "Building VoiceInk ($(CONFIGURATION))..."
	@xcodebuild -project VoiceInk.xcodeproj \
		-scheme VoiceInk \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		build
	@echo "Build complete. App is at: $(BUILD_DIR)/Build/Products/$(CONFIGURATION)/$(APP_NAME)"

# Run application
run:
	@echo "Running VoiceInk from build directory..."
	@if [ -d "$(BUILD_DIR)/Build/Products/$(CONFIGURATION)/$(APP_NAME)" ]; then \
		open "$(BUILD_DIR)/Build/Products/$(CONFIGURATION)/$(APP_NAME)"; \
	else \
		echo "VoiceInk.app not found at $(BUILD_DIR)/Build/Products/$(CONFIGURATION)/$(APP_NAME)"; \
		echo "Please run 'make build' first."; \
		exit 1; \
	fi

# Build Release version
release:
	@$(MAKE) build CONFIGURATION=Release

# Install to Applications directory
install: release
	@echo "Installing VoiceInk to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@if [ -d "$(BUILD_DIR)/Build/Products/Release/$(APP_NAME)" ]; then \
		rm -rf "$(INSTALL_DIR)/$(APP_NAME)"; \
		cp -R "$(BUILD_DIR)/Build/Products/Release/$(APP_NAME)" "$(INSTALL_DIR)/"; \
		echo "✓ VoiceInk installed to $(INSTALL_DIR)/$(APP_NAME)"; \
		echo "You can now run it from Applications or use 'open $(INSTALL_DIR)/$(APP_NAME)'"; \
	else \
		echo "Error: Release build not found. Run 'make release' first."; \
		exit 1; \
	fi

# Uninstall from Applications directory
uninstall:
	@echo "Uninstalling VoiceInk from $(INSTALL_DIR)..."
	@if [ -d "$(INSTALL_DIR)/$(APP_NAME)" ]; then \
		rm -rf "$(INSTALL_DIR)/$(APP_NAME)"; \
		echo "✓ VoiceInk uninstalled"; \
	else \
		echo "VoiceInk not found at $(INSTALL_DIR)/$(APP_NAME)"; \
	fi

# Cleanup
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Build directory cleaned"

# Clean everything including dependencies
clean-all: clean
	@echo "Cleaning dependencies..."
	@rm -rf $(DEPS_DIR)
	@echo "Complete clean finished"

# Help
help:
	@echo "Available targets:"
	@echo "  check/healthcheck  Check if required CLI tools are installed"
	@echo "  whisper            Clone and build whisper.cpp XCFramework"
	@echo "  setup              Ensure whisper XCFramework is ready"
	@echo "  build              Build VoiceInk (Debug by default, set CONFIGURATION=Release for release)"
	@echo "  release            Build VoiceInk in Release configuration"
	@echo "  run                Launch the built VoiceInk app from build directory"
	@echo "  install            Build Release and install to $(INSTALL_DIR)"
	@echo "  uninstall          Remove VoiceInk from $(INSTALL_DIR)"
	@echo "  dev                Build (Debug) and run the app (for development)"
	@echo "  all                Run full build process (default)"
	@echo "  clean              Remove build directory"
	@echo "  clean-all          Remove build directory and dependencies"
	@echo "  help               Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  CONFIGURATION      Build configuration (Debug or Release, default: Debug)"
	@echo "  INSTALL_DIR        Installation directory (default: $(HOME)/Applications)"
