# Claude Code Guide for VoiceInk

## Project Overview

**VoiceInk** is a native macOS application for near-instant voice-to-text transcription using local AI models. This is a fork from the original [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) repository, with licensing/trial features removed for open-source development.

**Key Characteristics:**
- **Platform**: macOS 14.0+ (Sonoma and later)
- **Language**: Swift + SwiftUI
- **Architecture**: MVVM with reactive SwiftUI patterns
- **ML Framework**: Whisper.cpp (local speech-to-text)
- **Data Persistence**: SwiftData for transcription history
- **License**: GPL v3

## Repository Structure

```
VoiceInk/
├── VoiceInk/                    # Main app source
│   ├── AppIntents/              # Siri/Shortcuts integration
│   ├── Models/                  # Data models & ViewModels
│   ├── Notifications/           # Notification handling
│   ├── PowerMode/               # Context-aware app detection
│   ├── Services/                # Business logic (AI, audio, etc.)
│   ├── Views/                   # SwiftUI views
│   ├── Whisper/                 # Whisper.cpp integration
│   ├── Resources/               # Static resources
│   └── Assets.xcassets/         # App assets
├── .beads/                      # AI-native issue tracking (Beads)
├── Makefile                     # Build automation
├── BUILDING.md                  # Build instructions
├── AGENTS.md                    # Beads workflow for AI agents
└── CLAUDE.md                    # This file
```

## Architecture & Key Components

### 1. Core App Structure (VoiceInk.swift)

The app entry point (`VoiceInkApp`) initializes:
- **SwiftData Container**: Persistent storage for transcriptions and vocabulary
- **WhisperState**: Central state manager for ML model and transcription
- **HotkeyManager**: Global keyboard shortcut handling
- **AIEnhancementService**: Post-transcription AI processing
- **MenuBarManager**: System tray integration
- **ActiveWindowService**: Context detection for Power Mode

### 2. Transcription Pipeline

**Recording → Whisper → AI Enhancement → Output**

1. **AudioEngineRecorder.swift**: Captures microphone input
2. **WhisperState.swift** (`VoiceInk/Whisper/`):
   - Manages Whisper.cpp model lifecycle
   - Handles transcription queue
   - Coordinates with AI enhancement
3. **AIEnhancementService.swift**: Optional GPT-style enhancement
4. **CursorPaster.swift**: Inserts text at cursor position

### 3. Data Models (SwiftData)

- **Transcription**: Stores transcription history with metadata
- **VocabularyWord**: Custom dictionary for domain-specific terms
- **WordReplacement**: Text replacement rules (e.g., "btw" → "by the way")

### 4. Power Mode (Context Awareness)

**Location**: `VoiceInk/PowerMode/`

Automatically applies custom settings based on:
- Active application (bundle ID)
- Website URL (for browsers)
- Custom prompts and AI models per context

**Key Files:**
- `PowerModeManager.swift`: Configuration management
- `ActiveWindowService.swift`: Window/URL detection via Accessibility API

### 5. Services Layer

**Key Services:**
- **AIService.swift**: Multi-provider AI integration (OpenAI, Anthropic, Groq, etc.)
- **AudioDeviceManager.swift**: Mic selection and audio device handling
- **SystemInfoService.swift**: Debug/support info generation
- **UserDefaultsManager.swift**: Centralized UserDefaults access

### 6. UI Components

**Main Windows:**
- **ContentView.swift**: Primary transcription UI
- **MetricsView.swift**: Dashboard with stats and promotions
- **SettingsView.swift**: Configuration interface
- **HistoryWindowController.swift**: Transcription history viewer

## Development Workflows

### Building the Project

See [BUILDING.md](BUILDING.md) for detailed instructions. Quick start:

```bash
make all              # Full build (downloads whisper.cpp, builds framework, runs app)
make dev              # Build and run for development
make clean            # Remove build artifacts
```

**Dependencies:**
- Whisper.xcframework (built automatically by Makefile)
- Managed in `../VoiceInk-Dependencies/` (relative to repo root)

### Beads Issue Tracking

This project uses **Beads** (`bd`) for AI-native issue management. See [AGENTS.md](AGENTS.md) for complete workflow.

**Essential commands:**
```bash
bd ready              # Show available work
bd show <id>          # View issue details
bd update <id> --status=in_progress
bd close <id>         # Mark complete
bd sync               # Sync with git
```

**Critical**: Always run `bd sync` and `git push` before ending a session!

### Git Workflow

**Remotes:**
- `origin`: Your fork (flowerornament/VoiceInk)
- `upstream`: Original repo (Beingpax/VoiceInk)

**Syncing with upstream:**
```bash
git fetch upstream
git merge upstream/main
# Resolve conflicts if any
git push origin main
```

## Coding Conventions

### Swift Style

- **SwiftUI**: Declarative views, prefer composition over inheritance
- **MVVM**: ViewModels manage state, Views remain lightweight
- **@Published/@StateObject/@ObservedObject**: Use appropriately for reactive updates
- **Async/Await**: Preferred for async operations (not completion handlers)
- **Actors**: Used for thread-safe state (e.g., `WhisperState`)

### Naming Conventions

- **Services**: Suffix with `Service` (e.g., `AIService`, `AudioDeviceManager`)
- **ViewModels**: Suffix with `ViewModel` (e.g., `LicenseViewModel`)
- **Managers**: Suffix with `Manager` for singletons (e.g., `HotkeyManager`)
- **UserDefaults Keys**: Centralized in `UserDefaultsManager.swift`

### File Organization

- Group related functionality in folders (Models, Views, Services)
- Keep view code in `Views/`, business logic in `Services/`
- Place reusable components in appropriate subdirectories

## AI-Specific Guidelines

### When Working on VoiceInk:

1. **Licensing Code**: This fork has removed trial/licensing logic. Default app to `.licensed` state.
2. **Privacy**: VoiceInk is privacy-first. Never add telemetry without explicit consent.
3. **Performance**: Audio recording is real-time. Avoid blocking main thread in recording pipeline.
4. **Whisper.cpp**: The ML model runs locally. Changes require understanding C++ bridging.
5. **Accessibility**: Uses macOS Accessibility API for cursor positioning—requires system permissions.

### Key Files to Understand First:

- **VoiceInk.swift**: App initialization and dependency injection
- **WhisperState.swift**: Core transcription logic
- **HotkeyManager.swift**: How shortcuts trigger recording
- **Recorder.swift**: Recording state machine

### Common Tasks:

- **Add AI Provider**: Modify `AIService.swift`, add provider enum case
- **New Power Mode Feature**: Extend `PowerModeConfiguration` in `PowerModeManager.swift`
- **UI Changes**: Update SwiftUI views in `Views/`, follow existing patterns
- **Build Issues**: Check Makefile dependencies, verify whisper.xcframework exists

## Testing & Quality

- **Manual Testing**: Build with `make dev` and test recording workflows
- **Permissions**: Test with Accessibility and Microphone permissions granted
- **Audio Devices**: Test with different input sources (built-in mic, USB, etc.)
- **Context Switching**: Verify Power Mode activates correctly across apps

## Troubleshooting

**Build Errors:**
1. Run `make clean && make all`
2. Verify Xcode Command Line Tools installed: `xcode-select --install`
3. Check whisper.xcframework exists at `../VoiceInk-Dependencies/whisper.cpp/build-apple/whisper.xcframework`

**Runtime Issues:**
- Check Console.app for VoiceInk logs (subsystem: `com.prakashjoshipax.voiceink`)
- Verify Accessibility permission granted in System Settings
- Ensure microphone permission granted

## Related Documentation

- **[BUILDING.md](BUILDING.md)**: Complete build instructions
- **[AGENTS.md](AGENTS.md)**: Beads workflow for AI collaboration
- **[README.md](README.md)**: Project overview and features
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Contribution guidelines (Note: Original repo doesn't accept PRs)

## Fork-Specific Notes

This fork differs from upstream:
- **No licensing/trial system**: App always reports as licensed
- **Open source focus**: Removed commercial promotional content
- **Beads integration**: Added AI-native issue tracking
- **Relative dependencies**: Uses `../VoiceInk-Dependencies/` instead of `~/VoiceInk-Dependencies`

When syncing with upstream, expect conflicts in:
- `LicenseViewModel.swift`
- `UserDefaultsManager.swift`
- `SystemInfoService.swift`
- Promotional UI components

Resolve by keeping our simplified "always licensed" version.

---

**Ready to contribute?** Check `bd ready` for available issues, or explore the codebase starting with `VoiceInk.swift` → `WhisperState.swift` → `Recorder.swift` to understand the core transcription flow.
