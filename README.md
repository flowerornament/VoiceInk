# VoiceInk

A native macOS application for near-instant voice-to-text transcription using local AI models.

[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Platform](https://img.shields.io/badge/platform-macOS%2014.0%2B-brightgreen)

This is a fork of [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) with licensing/trial features removed for open-source development.

## Features

- **Local AI Transcription**: Uses Whisper.cpp for offline speech-to-text processing
- **Privacy-Focused**: 100% offline processing - your data never leaves your device
- **Power Mode**: Context-aware settings that automatically adjust based on active application or URL
- **Global Shortcuts**: Configurable keyboard shortcuts for quick recording
- **Personal Dictionary**: Custom vocabulary and text replacement rules
- **AI Enhancement**: Optional post-processing with external AI providers
- **AI Assistant Mode**: Voice-driven conversational assistant

## Requirements

- macOS 14.0 or later
- Xcode Command Line Tools
- Git

## Building from Source

### Prerequisites

- macOS 14.0 or later
- Xcode Command Line Tools: `xcode-select --install`
- Git

### Dependencies

The Makefile automatically manages dependencies, but you can also install via Homebrew:

```bash
brew install --cask voiceink
```

Or build from source:

```bash
make all    # Download dependencies, build framework, and run
make dev    # Build and run for development
make clean  # Remove build artifacts
```

See [BUILDING.md](BUILDING.md) for detailed build instructions.

## Documentation

- [BUILDING.md](BUILDING.md) - Build instructions and dependencies
- [CLAUDE.md](CLAUDE.md) - Guide for AI assistants working on this codebase
- [AGENTS.md](AGENTS.md) - Beads workflow for issue tracking
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards

## Project Structure

```
VoiceInk/
├── VoiceInk/           # Main application source
│   ├── Models/         # Data models and ViewModels
│   ├── Services/       # Business logic
│   ├── Views/          # SwiftUI interface
│   ├── Whisper/        # ML model integration
│   └── PowerMode/      # Context-aware features
├── .beads/             # AI-native issue tracking
└── Makefile            # Build automation
```

## Contributing

Contributions are welcome! Please:
1. Check existing issues or create a new one
2. Follow the coding conventions in [CLAUDE.md](CLAUDE.md)
3. Use `bd` (Beads) for issue tracking - see [AGENTS.md](AGENTS.md)

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built with:
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - High-performance Whisper inference
- [FluidAudio](https://github.com/FluidInference/FluidAudio) - Parakeet model support
- [Sparkle](https://github.com/sparkle-project/Sparkle) - App updates
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global hotkeys
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin) - Launch at login
- [MediaRemoteAdapter](https://github.com/ejbills/mediaremote-adapter) - Media control
- [SelectedTextKit](https://github.com/tisfeng/SelectedTextKit) - Selected text access

Original project by [Beingpax](https://github.com/Beingpax/VoiceInk).
