# Automated Podcast Editor - Implementation Plan

This plan follows Trunk-Based Development (TBD) with Test-Driven Development (TDD). 
Each task represents a small, mergeable, and testable unit of work.

## Core Constraint
- Audio is the source of truth for the timeline: the multi-channel `.wav` file runs continuously and doesn't stretch or slide.

---

## Epic 1: Audio Ingestion & Multi-Channel Parsing
**Goal:** Read the master multi-channel `.wav` file and expose individual track boundaries and buffers.

- [x] **Task 1.1: Audio File Loader Model**
  - **Action:** Create a service or model to load an audio asset path using `AVAudioFile` or `AVAsset`.
  - **Tests:** Feed a mock multi-channel wav file; assert the channel count and duration match expectations.
- [ ] **Task 1.2: Channel Buffer Extractor**
  - **Action:** Implement AVFoundation logic to extract single-channel buffers (`AVAudioPCMBuffer`) for isolated analysis.
  - **Tests:** Verify extracted buffer's format is single-channel and length matches the source.

---

## Epic 2: Media Mapping (State Management)
**Goal:** Map specific video files to specific audio channels. If a channel is speaking and has no mapped video, we default to black.

- [ ] **Task 2.1: Project Mapping Models**
  - **Action:** Create state structs (e.g., `ProjectSession`, `ChannelMapping`) representing: Audio Channel Index -> Expected Video URL.
  - **Tests:** Unit test addition, removal, and validation of mappings, including handling missing videos (which should trigger a "black frame" fallback state).

---

## Epic 3: Video Pre-processing (Cropping)
**Goal:** Define and apply visual cropping to video sources before compiling the final timeline.

- [ ] **Task 3.1: Crop Definition Model**
  - **Action:** Create a value type representing crop parameters (x, y, width, height, or aspect ratio) for mapped videos.
  - **Tests:** Boundary validations for coordinates (x, y >= 0; dimensions > 0).
- [ ] **Task 3.2: AVVideoComposition Crop Logic**
  - **Action:** Implement a utility to apply `CGAffineTransform` or `AVVideoCompositionCoreAnimationTool` for the crop on an `AVAssetTrack`.
  - **Tests:** Functional test to apply crop struct to an AVAsset, verifying the output composition dimensions in tests or via sample export.

---

## Epic 4: Synchronization & Speaker Detection
**Goal:** Dynamically generate an Edit Decision List (EDL) by detecting who is talking and minimizing erratic camera switching.

- [ ] **Task 4.1: Volume Analysis Engine**
  - **Action:** Analyze the PCM buffer of each channel using `vDSP` to calculate average RMS/Power levels over fixed window sizes (e.g., 0.1s intervals).
  - **Tests:** Unit test with a synthetic audio buffer of known silence/noise to assert output power values.
- [ ] **Task 4.2: Active Speaker State Machine & Smoothing**
  - **Action:** Determine the "loudest" active channel per interval. Implement "hang time" (hysteresis) logic so it doesn't switch speakers rapidly if someone interrupts for <1 second.
  - **Tests:** Feed a mocked timeline of volume levels; assert the output decision states map correctly with hysteresis rules applied.
- [ ] **Task 4.3: EDL Generator**
  - **Action:** Convert the Active Speaker states into an Edit Decision List (EDL) array of `[startTime, endTime, targetChannel]`.
  - **Tests:** Convert known continuous speaker states into accurate contiguous time ranges.

---

## Epic 5: Final Assembly & Export
**Goal:** Build the final timeline combining continuous audio, mapped cropped videos, and black fallback frames according to the EDL.

- [ ] **Task 5.1: AVMutableComposition Builder**
  - **Action:** Build a composer that creates an `AVMutableComposition`. It adds the master audio as a single track, then sequentially places video segments according to the EDL. Wait, maybe inject black frames (`AVVideoComposition`) where appropriate.
  - **Tests:** Verify the resulting composition's total duration equals audio duration and tracking count matches EDL segments.
- [ ] **Task 5.2: Multi-cam Export Process**
  - **Action:** Implement `AVAssetExportSession` to render the composition.
  - **Tests:** Assert export session states (success, failure), handle completion handlers appropriately.

---

## Repository Standards & Practices
1. **Directory Structure:**
   - `/docs/` - Project documentation, planning, and worklog.
   - `/AUTOPODCUT/Core/` - Foundational audio/video logic.
   - `/AUTOPODCUT/Models/` - State and configuration structs.
   - `/AUTOPODCUT/UI/` - Views and components.
2. **Trunk-Based Development Workflow:** 
   - Commit directly to `main` for small tasks or use short-lived feature branches that merge daily.
   - Write tests first, then implementation.
   - Maintain track of finished work in `/docs/WORKLOG.md`.
