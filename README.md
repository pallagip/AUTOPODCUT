# AUTOPODCUT 🎙️🎬

An automated podcast video editor that synchronizes multi-channel audio with video, identifies active speakers, and generates a polished multi-camera composition.

## 🚀 Overview

AUTOPODCUT is designed to streamline the podcast editing process. By analyzing individual audio tracks from multiple microphones, it automatically detects who is speaking and switches between corresponding video sources. It handles synchronization, video cropping, and high-quality export to produce a ready-to-publish video.

## ✨ Key Features

- **Automated Multi-Camera Switching**: Intelligent speaker detection using volume analysis and state-machine logic (with hysteresis to prevent rapid "jittery" cuts).
- **Multi-Channel Audio Ingestion**: Load and process high-fidelity audio from various sources (`AVAsset`, `AVAudioFile`).
- **Dynamic Video Mapping**: Maps specific audio channels to individual video tracks or presets.
- **Customizable Video Cropping**: Built-in logic to frame speakers perfectly using `AVMutableVideoComposition`.
- **High-Quality Export**: Export final compositions in 4K resolution using HEVC (H.265) for optimal quality and file size.
- **Test-Driven Development**: Robust architecture built on TDD principles with extensive unit tests for core logic.

## 🛠️ Technology Stack

- **Language**: Swift
- **Frameworks**: AVFoundation, Accelerate (vDSP), SwiftUI
- **Methodology**: TDD (Test-Driven Development), Trunk-Based Development

## 📂 Project Structure

- `AUTOPODCUT/`: Main application source code.
- `AUTOPODCUT/Core/`: Core logic for audio processing, speaker detection, and video composition.
- `AUTOPODCUT/Models/`: Data structures for project sessions, channel mapping, and edit decisions.
- `AUTOPODCUTTests/`: Comprehensive test suite.
- `docs/`: Project documentation and worklogs.

## 🚦 Getting Started

### Prerequisites

- macOS
- Xcode 15.0+

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/pallagip/AUTOPODCUT.git
   ```
2. Open `AUTOPODCUT.xcodeproj` in Xcode.
3. Build and run the project.

## 🧪 Running Tests

To ensure everything is working correctly, run the test suite:

```bash
xcodebuild test -scheme AUTOPODCUT -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📜 Development Log

Refer to `docs/WORKLOG.md` for a detailed history of implemented features and architectural decisions.

---
Built with ❤️ for podcasters who want to focus on content, not editing.
