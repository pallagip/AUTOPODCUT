# Agent Onboarding Guide (AGENTS.md)

Welcome to the **AUTOPODCUT** project. This file serves as the system prompt and onboarding manual for any AI agents or developers contributing to this repository.

## 1. Project Overview
AUTOPODCUT is an automated podcast editing software built for macOS (assumed Swift/AVFoundation). Its primary function is to take a multi-channel `.wav` file (the absolute timeline master) and multiple source video angles, detect the active speaker on the audio, and automatically generate a compiled, synced multi-cam edit.

## 2. Core Constraints & Rules Every Agent Must Follow
- **Audio is Immutable:** The multi-channel `.wav` file dictates all timing and sync. It runs sequentially and uncut underneath the video edits. **Never slide or stretch audio to match video.**
- **Missing Video Fallback:** If an audio channel is active (speaker is talking) but unmapped to a camera angle, the system MUST fallback to a black video frame.
- **Pre-Export Cropping:** Before the composition is finalized, video tracks must incorporate predefined user crops (using `CGAffineTransform` or `AVVideoComposition`).
- **Trunk-Based Development (TBD):** Always commit small, testable increments directly to `main` (or very short-lived branches).
- **Test-Driven Development (TDD):** Every feature in the `PLAN.md` must have unit/integration tests covering its core behavior before the implementation is finalized. 

## 3. Directory Structure and Responsibilities
Agents should place code according to these domain boundaries:
- `/docs/` - Configuration, plans, and tracking (`PLAN.md`, `WORKLOG.md`, `AGENTS.md`).
- `/AUTOPODCUT/Core/` - Foundational audio parsing, DSP/Accelerate logic, AVFoundation utilities.
- `/AUTOPODCUT/Models/` - Swift value types (structs) representing `Project`, `CropConfig`, `ChannelMapping`, `EDL` (Edit Decision List).
- `/AUTOPODCUT/UI/` - SwiftUI or AppKit views.
- `/AUTOPODCUTTests/` - Unit tests for algorithms and models.

## 4. Agent Workflow
When assigned a new feature or task:
1. **Check State:** Read `/docs/PLAN.md` to see the roadmap and `/docs/WORKLOG.md` to determine what was most recently completed.
2. **Review Context:** Identify if any code related to the task already exists via `grep_search` or exploring the directory hierarchy.
3. **Draft Tests:** Write tests for the boundaries and logic (e.g., mock audio buffers, mapping validation).
4. **Implement:** Write the specific implementation, prioritizing clean boundaries over monolithic classes.
5. **Verify:** Run tests (`xcodebuild test` or via the current run environment) and ensure they pass.
6. **Log:** Update `/docs/WORKLOG.md` with the completed task.
7. **Document:** Keep inline code documentation up to date, specifically focusing on complex AVFoundation interactions.

## 5. Technology Stack Context
- **Language:** Swift
- **Platform:** macOS Native
- **Media Framework:** AVFoundation
- **Processing:** Accelerate / vDSP (for raw audio buffer volume analysis)
- **UI:** SwiftUI (preferred) or AppKit

By following this document strictly, AI agents ensure high reliability, maintainability, and delivery speed across all sessions.
