# Worklog

This document tracks completed tasks and milestones according to the `PLAN.md`.

## [YYYY-MM-DD] - Initialization
- **Action:** Restructured project workspace to adopt industry best practices (created `/docs` folder).
- **Action:** Decomposed initial product requirements into `PLAN.md` with Epic and Task blocks, adopting Test-Driven Development (TDD) and Trunk-Based Development (TBD).
- **Action:** Created `AGENTS.md` to define onboarding constraints, directory structure, and development workflows for AI agents.

## [YYYY-MM-DD] - Epic 1: Audio Ingestion
- **Action:** Implemented `AudioFileLoader` model to safely ingest audio assets via AVAsset/AVAudioFile.
- **Action:** Added `AudioFileLoaderTests` to verify handling of missing files, valid multichannel structures, and invalid formats.
- **Action:** Executed tests successfully through Xcodebuild using Trunk-Based Development approach.
- **Action:** Implemented `ChannelBufferExtractor` to extract individual channel float data into a single-channel `AVAudioPCMBuffer`.
- **Action:** Implemented `ChannelBufferExtractorTests` to verify accurate channel index extraction and error states.
- **Action:** Executed all tests locally with `xcodebuild test` to full completion.

## Next Up
- Epic 2: Media Mapping (State Management) -> Task 2.1: Project Mapping Models

## [YYYY-MM-DD] - Epic 2: Media Mapping (State Management)
- **Action:** Created `ProjectSession` and `ChannelMapping` structs representing logic between index mapped and unmapped video URLs.
- **Action:** Created `ProjectSessionTests` asserting boundaries against non-configured sessions and correctly evaluating state mappings and default `nil` black screen evaluations.
- **Action:** Successfully tested and verified through Xcode builds.

## [YYYY-MM-DD] - Epic 3: Video Pre-processing (Cropping)
- **Action:** Created `CropDefinition` struct resolving to `CGRect` using core configurations.
- **Action:** Added unit tests ensuring positive sizes and non-negative X/Y coordinates fail predictably according to standards.

## Next Up
- Epic 3: Video Pre-processing (Cropping) -> Task 3.2: AVVideoComposition Crop Logic
