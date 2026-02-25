# Advanced UI & Video Mapping Redesign Task Plan

## Epic: Advanced Workflow & Single-Camera Dual-Crop UI

**Goal:** Overhaul the user interface to adopt a more advanced, asset-centric workflow. The UI will first ingest the audio, then ingest videos, and finally allow mapping uploaded videos to audio channels with specific crop configurations. Crucially, this will allow a single video file (e.g., a wide shot) to be used twice, cropped differently for each speaker.

---

### Phase 1: Core Data Model Updates
- [x] **Task 1.1: Multi-Use Asset Models**
  - **Action:** Refactor `ProjectSession` and mapping state so that a single physical video `URL` can be referenced by multiple `ChannelMapping` instances.
  - **Details:** Introduce a "Media Pool" concept where uploaded video URLs are stored. A channel mapping simply points to a video in the pool and holds its own independent crop configuration.
- [x] **Task 1.2: Independent Crop Configurations**
  - **Action:** Ensure `CropDefinition` is bound to the mapping segment rather than strictly a 1:1 bond with the file path.
  - **Tests:** Create a unit test where the same `AVAsset` URL is mapped to two different channels with distinct `CropDefinition`s (e.g., left half vs. right half), ensuring the composition builder applies the correct `CGAffineTransform` for each.

---

### Phase 2: User Interface Redesign
- [x] **Task 2.1: Step 1 - Master Audio Input Screen**
  - **Action:** Replace the current static questions ("Is audio split into left/right?") with a focused `AudioSelectionView`. 
  - **Details:** The app should first prompt the user **only** for the Master Audio File. Upon selection, the app can automatically detect the channel layout (or present a configuration option for it).
- [x] **Task 2.2: Step 2 - The Media Pool (Video Uploads)**
  - **Action:** Create a `VideoUploadView` presented after audio selection.
  - **Details:** Ask for video files. Allow the user to upload one or multiple video files into a staging area. Show thumbnails, filenames, or a list of the 2 incoming videos.
- [x] **Task 2.3: Step 3 - Channel Mapping & Cropping Interface**
  - **Action:** Create an advanced `MappingView` that lists the detected audio channels (e.g., "Channel 1 / Left", "Channel 2 / Right").
  - **Details:** 
    - For each channel, the user selects a video from the Media Pool.
    - If a video is assigned, the user can configure a "Crop Editor" or select presets (Full, Left Half, Right Half, Center).
    - This allows mapping *Video 1* (the standalone shot) to Channel 1, and *Video 2* (the wide shot) to Channel 2. Alternatively, map *Video 2* to Channel 1 (with Crop A) and to Channel 2 (with Crop B).

---

### Phase 3: Integration & View Model Updates
- [x] **Task 3.1: AutoPodCutViewModel Refactoring**
  - **Action:** Change the `AutoCutNavigationState` from boolean/static stepping to a state machine: `selectingAudio` -> `uploadingVideos` -> `mappingAndCropping` -> `processing`.
  - **Details:** Tie the new UI views to the view model, ensuring media URLs are stored correctly and passed to the existing video composition builders.
- [x] **Task 3.2: Verification and End-to-End Testing**
  - **Action:** Validate the new flow.
  - **Details:** Run an integration test selecting a single video, mapping it twice with different crop bounds, and verifying that the final export successfully transitions between the two uniquely cropped "virtual" cameras driven by the audio volume analysis.
