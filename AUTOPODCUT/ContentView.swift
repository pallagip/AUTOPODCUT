//
//  ContentView.swift
//  AUTOPODCUT
//
//  Created by Patrik Pallagi on 2025. 12. 24..
//

import SwiftUI
import AVFoundation
import Accelerate
import UniformTypeIdentifiers

// MARK: - Navigation State

enum CutMode {
    case classic
    case mainSpeakerSwitch
    case threeHostPanel
}

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var viewModel = AutoPodCutViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AutoPodCut")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    Picker("Operation Mode", selection: $viewModel.cutMode) {
                        Text("Classic AutoCut").tag(CutMode.classic)
                        Text("MainSpeakerSwitch").tag(CutMode.mainSpeakerSwitch)
                        Text("Three Host Panel").tag(CutMode.threeHostPanel)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 10)
                    
                    // Step 1
                    SectionView(title: "Step 1: Select Master Audio (.wav)") {
                        FileSelectionButton(
                            title: "Select Master Audio",
                            selectedFileName: viewModel.soundAudioFileName,
                            action: { viewModel.selectSoundAudio() }
                        )
                    }
                    
                    if viewModel.soundAudioURL != nil {
                        
                        // SPEAKER 1 (Main if applicable)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(viewModel.cutMode == .mainSpeakerSwitch ? "Step 2 & 3: Configure Main Speaker" : (viewModel.cutMode == .threeHostPanel ? "Step 2 & 3: Configure Hosts (Track 3,4,5)" : "Step 2 & 3: Configure Speaker 1")).font(.headline)
                            HStack(spacing: 20) {
                                if viewModel.cutMode == .threeHostPanel {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Host Left Track").font(.subheadline).foregroundColor(.secondary)
                                        Picker("", selection: $viewModel.hostLeftTrack) {
                                            ForEach(1...viewModel.soundAudioNumChannels, id: \.self) { track in
                                                Text("Track \(track)").tag(track)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: 100)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Host Middle Track").font(.subheadline).foregroundColor(.secondary)
                                        Picker("", selection: $viewModel.hostMiddleTrack) {
                                            ForEach(1...viewModel.soundAudioNumChannels, id: \.self) { track in
                                                Text("Track \(track)").tag(track)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: 100)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Host Right Track").font(.subheadline).foregroundColor(.secondary)
                                        Picker("", selection: $viewModel.hostRightTrack) {
                                            ForEach(1...viewModel.soundAudioNumChannels, id: \.self) { track in
                                                Text("Track \(track)").tag(track)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: 100)
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Select Audio Track").font(.subheadline).foregroundColor(.secondary)
                                        Picker("", selection: $viewModel.soundTrackOne) {
                                            ForEach(1...viewModel.soundAudioNumChannels, id: \.self) { track in
                                                Text("Track \(track)").tag(track)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: 150)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(viewModel.cutMode == .threeHostPanel ? "Select Host Video" : "Select Video File").font(.subheadline).foregroundColor(.secondary)
                                    FileSelectionButton(
                                        title: viewModel.cutMode == .mainSpeakerSwitch ? "Select Main Video" : (viewModel.cutMode == .threeHostPanel ? "Host Video" : "Select Video 1"),
                                        selectedFileName: viewModel.videoOneFileName,
                                        action: { viewModel.selectVideoOne() }
                                    )
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(viewModel.cutMode == .mainSpeakerSwitch ? Color.yellow.opacity(0.15) : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.cutMode == .mainSpeakerSwitch ? Color.yellow.opacity(0.8) : Color.clear, lineWidth: 2)
                        )
                        .cornerRadius(12)
                        
                        // SPEAKER 2 / GUEST
                        SectionView(title: viewModel.cutMode == .mainSpeakerSwitch ? "Step 4 & 5: Configure Other Speaker" : (viewModel.cutMode == .threeHostPanel ? "Step 4 & 5: Configure Guest" : "Step 4 & 5: Configure Speaker 2")) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(viewModel.cutMode == .mainSpeakerSwitch ? "Group Tracks" : "Select Audio Track").font(.subheadline).foregroundColor(.secondary)
                                    if viewModel.cutMode == .mainSpeakerSwitch {
                                        Text("Auto-Group (Tracks 3, 4, 5)")
                                            .foregroundColor(.secondary)
                                            .padding(.vertical, 8)
                                    } else if viewModel.cutMode == .threeHostPanel {
                                        Picker("", selection: $viewModel.guestTrack) {
                                            ForEach(1...viewModel.soundAudioNumChannels, id: \.self) { track in
                                                Text("Track \(track)").tag(track)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: 150)
                                    } else {
                                        Picker("", selection: $viewModel.soundTrackTwo) {
                                            ForEach(1...viewModel.soundAudioNumChannels, id: \.self) { track in
                                                Text("Track \(track)").tag(track)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: 150)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(viewModel.cutMode == .threeHostPanel ? "Select Guest Video" : "Select Video File").font(.subheadline).foregroundColor(.secondary)
                                    FileSelectionButton(
                                        title: viewModel.cutMode == .mainSpeakerSwitch ? "Select Other Video" : (viewModel.cutMode == .threeHostPanel ? "Guest Video" : "Select Video 2"),
                                        selectedFileName: viewModel.videoTwoFileName,
                                        action: { viewModel.selectVideoTwo() }
                                    )
                                }
                            }
                        }
                        
                        // Step 6
                        FuturisticButton(
                            title: viewModel.isProcessing ? "PROCESSING..." : (viewModel.cutMode == .threeHostPanel ? "NEXT" : "EXPORT"),
                            isSelected: viewModel.canPerformAutoCut,
                            isEnabled: viewModel.canPerformAutoCut && !viewModel.isProcessing,
                            action: { viewModel.performAutoCut() }
                        )
                    }
                    
                    if viewModel.isProcessing {
                        VStack(spacing: 12) {
                            AnimatedProgressBar(progress: viewModel.progress)
                                .frame(height: 8)
                            Text(viewModel.progressMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !viewModel.statusMessage.isEmpty {
                        Text(viewModel.statusMessage)
                            .font(.caption)
                            .foregroundColor(viewModel.isError ? .red : .green)
                    }
                }
                .padding()
                .frame(maxWidth: 800)
            }
        }
        .frame(minWidth: 700, minHeight: 650)
        .sheet(isPresented: $viewModel.presentLeftCrop) {
            if let url = viewModel.videoOneURL {
                CropSelectionView(
                    videoURL: url,
                    title: "Adjust Host Left Crop",
                    cropRect: $viewModel.hostLeftManualCrop,
                    isPresented: $viewModel.presentLeftCrop,
                    onSave: {
                        if viewModel.exportWizardState == .waitingForLeftCrop {
                            viewModel.exportWizardState = .waitingForRightCrop
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                viewModel.presentRightCrop = true
                            }
                        }
                    },
                    onCancel: {
                        if viewModel.exportWizardState == .waitingForLeftCrop {
                            viewModel.exportWizardState = .idle
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.presentRightCrop) {
            if let url = viewModel.videoOneURL {
                CropSelectionView(
                    videoURL: url,
                    title: "Adjust Host Right Crop",
                    cropRect: $viewModel.hostRightManualCrop,
                    isPresented: $viewModel.presentRightCrop,
                    onSave: {
                        if viewModel.exportWizardState == .waitingForRightCrop {
                            viewModel.exportWizardState = .idle
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                viewModel.startExportProcess()
                            }
                        }
                    },
                    onCancel: {
                        if viewModel.exportWizardState == .waitingForRightCrop {
                            viewModel.exportWizardState = .idle
                        }
                    }
                )
            }
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.headline)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Futuristic Button Style

struct FuturisticButton: View {
    let title: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? 
                                [Color.cyan.opacity(0.8), Color.blue.opacity(0.9)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.5)]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Hover gradient overlay
                        if isHovered && isEnabled {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan.opacity(0.6),
                                    Color.blue.opacity(0.7),
                                    Color.purple.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .transition(.opacity)
                        }
                        
                        // Selected glow effect
                        if isSelected {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan.opacity(0.4),
                                    Color.blue.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .overlay(
                    // Border with glow
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: isSelected || isHovered ?
                                    [Color.cyan.opacity(0.8), Color.blue.opacity(0.6), Color.purple.opacity(0.4)] :
                                    [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isHovered ? 2.5 : 1.5
                        )
                        .shadow(color: (isSelected || isHovered) ? Color.cyan.opacity(0.6) : Color.clear, radius: isHovered ? 12 : 8)
                )
                .cornerRadius(12)
                .shadow(color: (isSelected || isHovered) ? Color.blue.opacity(0.4) : Color.black.opacity(0.2), radius: isHovered ? 15 : 8, x: 0, y: isHovered ? 4 : 2)
                .scaleEffect(isHovered && isEnabled ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if isEnabled {
                isHovered = hovering
            }
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}



// MARK: - Animated Progress Bar

struct AnimatedProgressBar: View {
    let progress: Double // 0.0 to 1.0
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                
                // Progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: progressColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(max(animatedProgress, 0), 1))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: animatedProgress)
                
                // Shimmer effect overlay
                if animatedProgress > 0 && animatedProgress < 1 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(max(animatedProgress, 0), 1))
                        .blur(radius: 2)
                }
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
        .onAppear {
            animatedProgress = progress
        }
    }
    
    // Color changes from blue -> cyan -> green as progress increases
    private var progressColors: [Color] {
        if progress < 0.33 {
            // Blue phase (0-33%)
            return [Color.blue.opacity(0.8), Color.blue.opacity(0.9)]
        } else if progress < 0.66 {
            // Cyan phase (33-66%)
            return [Color.cyan.opacity(0.8), Color.blue.opacity(0.8)]
        } else if progress < 0.9 {
            // Green-cyan phase (66-90%)
            return [Color.cyan.opacity(0.8), Color.green.opacity(0.7)]
        } else {
            // Green phase (90-100%)
            return [Color.green.opacity(0.8), Color.green.opacity(0.9)]
        }
    }
}

// MARK: - File Selection Button Component

struct FileSelectionButton: View {
    let title: String
    let selectedFileName: String?
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(action: action) {
                HStack {
                    Image(systemName: "folder")
                    Text(title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            if let fileName = selectedFileName {
                Text(fileName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 10)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - View Model

@MainActor
// MARK: - Export Wizard State
enum ExportWizardState {
    case idle
    case waitingForLeftCrop
    case waitingForRightCrop
}

class AutoPodCutViewModel: ObservableObject {
    @Published var cutMode: CutMode = .classic
    
    @Published var soundAudioNumChannels: Int = 6
    @Published var soundTrackOne: Int = 1
    @Published var soundTrackTwo: Int = 2
    
    // Tracks for threeHostPanel mode
    @Published var hostLeftTrack: Int = 3
    @Published var hostMiddleTrack: Int = 4
    @Published var hostRightTrack: Int = 5
    @Published var guestTrack: Int = 6
    
    @Published var videoOneCrop: CropPreset = .full
    @Published var videoTwoCrop: CropPreset = .full
    
    // Manual crops for threeHostPanel mode
    @Published var hostLeftManualCrop: CGRect?
    @Published var hostRightManualCrop: CGRect?
    @Published var presentLeftCrop: Bool = false
    @Published var presentRightCrop: Bool = false
    @Published var exportWizardState: ExportWizardState = .idle
    
    @Published var videoOneURL: URL?
    @Published var videoTwoURL: URL?
    @Published var soundAudioURL: URL?
    
    @Published var videoOneFileName: String?
    @Published var videoTwoFileName: String?
    @Published var soundAudioFileName: String?
    
    @Published var isProcessing = false
    @Published var progressMessage = ""
    @Published var progress: Double = 0.0 // 0.0 to 1.0
    @Published var statusMessage = ""
    @Published var isError = false
    
    var canPerformAutoCut: Bool {
        videoOneURL != nil && videoTwoURL != nil && soundAudioURL != nil && !isProcessing
    }
    
    // MARK: - File Selection Methods
    
    func selectVideoOne() {
        // Accept .mov, .mp4, and other video formats that can contain HEVC/H.265 codec
        selectFile(allowedTypes: [UTType.movie, UTType.mpeg4Movie, UTType.video]) { [weak self] url in
            self?.videoOneURL = url
            self?.videoOneFileName = url?.lastPathComponent
        }
    }
    
    func selectVideoTwo() {
        // Accept .mov, .mp4, and other video formats that can contain HEVC/H.265 codec
        selectFile(allowedTypes: [UTType.movie, UTType.mpeg4Movie, UTType.video]) { [weak self] url in
            self?.videoTwoURL = url
            self?.videoTwoFileName = url?.lastPathComponent
        }
    }
    
    func selectSoundAudio() {
        selectFile(allowedTypes: [UTType.wav, UTType.mp3, UTType.mpeg4Audio, UTType.audio]) { [weak self] url in
            self?.soundAudioURL = url
            self?.soundAudioFileName = url?.lastPathComponent
            
            // Auto-detect track count from the audio file
            if let url = url {
                Task {
                    do {
                        let asset = AVURLAsset(url: url)
                        if let track = try await asset.loadTracks(withMediaType: .audio).first {
                            if let formatDescriptions = try await track.load(.formatDescriptions) as? [CMAudioFormatDescription], let format = formatDescriptions.first {
                                if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(format)?.pointee {
                                    await MainActor.run {
                                        let channels = Int(asbd.mChannelsPerFrame)
                                        self?.soundAudioNumChannels = max(1, channels)
                                        self?.soundTrackOne = min(1, channels)
                                        self?.soundTrackTwo = min(2, channels)
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Failed to load channel count: \(error)")
                    }
                }
            }
        }
    }
    
    private func selectFile(allowedTypes: [UTType], completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = allowedTypes
        
        panel.begin { response in
            if response == .OK {
                DispatchQueue.main.async {
                    completion(panel.url)
                }
            }
        }
    }
    
    // MARK: - Auto Cut Process
    
    func performAutoCut() {
        guard videoOneURL != nil, videoTwoURL != nil, soundAudioURL != nil else {
            return
        }
        
        if cutMode == .threeHostPanel {
            exportWizardState = .waitingForLeftCrop
            presentLeftCrop = true
        } else {
            startExportProcess()
        }
    }
    
    func startExportProcess() {
        guard let videoOneURL = videoOneURL,
              let videoTwoURL = videoTwoURL,
              let soundAudioURL = soundAudioURL else {
            return
        }
        
        // First, ask user to select output folder before starting processing
        Task {
            guard let outputURL = await selectOutputFolder() else {
                // User cancelled folder selection
                return
            }
            
            await MainActor.run {
                self.isProcessing = true
                self.progress = 0.0
                self.statusMessage = ""
                self.isError = false
            }
            
            do {
                try await processAutoCut(
                    videoOneURL: videoOneURL,
                    videoTwoURL: videoTwoURL,
                    videoOneCrop: videoOneCrop,
                    videoTwoCrop: videoTwoCrop,
                    soundAudioURL: soundAudioURL,
                    outputURL: outputURL,
                    cutMode: cutMode
                )
            } catch {
                await MainActor.run {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.isError = true
                    self.isProcessing = false
                    print("Auto cut error: \(error)")
                }
            }
        }
    }
    
    private func processAutoCut(
        videoOneURL: URL,
        videoTwoURL: URL,
        videoOneCrop: CropPreset,
        videoTwoCrop: CropPreset,
        soundAudioURL: URL,
        outputURL: URL,
        cutMode: CutMode
    ) async throws {
        let processor = VideoCutProcessor()
        
        // Step 1: Load all assets
        await updateProgress("Loading assets...", progress: 0.1)
        let videoOneAsset = AVURLAsset(url: videoOneURL)
        let videoTwoAsset = AVURLAsset(url: videoTwoURL)
        let soundAudioAsset = AVURLAsset(url: soundAudioURL)
        
        // Load asset properties
        if #available(macOS 12.0, *) {
            _ = try await videoOneAsset.load(.tracks, .duration)
            _ = try await videoTwoAsset.load(.tracks, .duration)
            _ = try await soundAudioAsset.load(.tracks, .duration)
        } else {
            // Fallback for older macOS versions
            _ = videoOneAsset.tracks
            _ = videoOneAsset.duration
            _ = videoTwoAsset.tracks
            _ = videoTwoAsset.duration
            _ = soundAudioAsset.tracks
            _ = soundAudioAsset.duration
        }
        
        // Step 2: Extract audio for synchronization
        await updateProgress("Extracting audio channels...", progress: 0.2)
        
        var leftChannel: [Float] = []
        var rightChannel: [Float] = [] // Will represent right channel in classic mode, NOT used in mainSpeakerSwitch
        var groupChannels: [[Float]] = [] // Used only in mainSpeakerSwitch
        let sampleRate: Float
        
        if cutMode == .threeHostPanel {
            let extracted = try await processor.extractFourChannels(
                from: soundAudioAsset,
                track1Index: hostLeftTrack,
                track2Index: hostMiddleTrack,
                track3Index: hostRightTrack,
                track4Index: guestTrack
            )
            leftChannel = extracted.track1       // hostLeft
            groupChannels = [extracted.track2, extracted.track3, extracted.track4] // middle, right, guest
            sampleRate = extracted.sampleRate
        } else if cutMode == .mainSpeakerSwitch {
            let extracted = try await processor.extractMainAndGroupChannels(
                from: soundAudioAsset,
                mainIndex: soundTrackOne
            )
            leftChannel = extracted.main
            groupChannels = extracted.group
            sampleRate = extracted.sampleRate
        } else {
            let extracted = try await processor.extractSelectedChannels(
                from: soundAudioAsset,
                leftIndex: soundTrackOne,
                rightIndex: soundTrackTwo
            )
            leftChannel = extracted.left
            rightChannel = extracted.right
            sampleRate = extracted.sampleRate
        }
        
        // Create mono mix of Sound Audio for synchronization
        let monoMix: [Float]
        if cutMode == .threeHostPanel {
            monoMix = processor.createMonoMixGroup(main: leftChannel, group: groupChannels)
        } else if cutMode == .mainSpeakerSwitch {
            monoMix = processor.createMonoMixGroup(main: leftChannel, group: groupChannels)
        } else {
            monoMix = processor.createMonoMix(left: leftChannel, right: rightChannel)
        }
        
        print("Sound Audio: \(monoMix.count) samples (\(String(format: "%.1f", Double(monoMix.count) / Double(sampleRate)))s)")
        
        // Step 3: Extract audio from videos
        await updateProgress("Extracting video audio tracks...", progress: 0.3)
        let videoOneAudio = try await processor.extractMonoAudio(from: videoOneAsset)
        let videoTwoAudio = try await processor.extractMonoAudio(from: videoTwoAsset)
        
        // Step 4: Synchronize BOTH videos INDEPENDENTLY
        await updateProgress("Synchronizing Video One...", progress: 0.4)
        let videoOneOffset = processor.findSyncOffset(
            videoAudio: videoOneAudio,
            referenceAudio: monoMix,
            sampleRate: sampleRate,
            videoName: "Video One"
        )
        
        await updateProgress("Synchronizing Video Two...", progress: 0.5)
        let videoTwoOffset = processor.findSyncOffset(
            videoAudio: videoTwoAudio,
            referenceAudio: monoMix,
            sampleRate: sampleRate,
            videoName: "Video Two"
        )
        
        print("\n=== FINAL SYNC OFFSETS ===")
        print("Video One: \(String(format: "%.2f", videoOneOffset)) seconds")
        print("Video Two: \(String(format: "%.2f", videoTwoOffset)) seconds")
        print("==========================")
        
        // Step 5: Analyze loudness to determine speaker dominance over time
        await updateProgress("Analyzing speaker loudness...", progress: 0.6)
        
        // Calculate true duration from exact extracted samples to avoid corrupt file metadata issues
        let exactDurationSeconds = Double(leftChannel.count) / Double(sampleRate)
        let soundAudioDuration = CMTime(seconds: exactDurationSeconds, preferredTimescale: 600)
        
        let speakerSegments: [SpeakerSegment]
        
        if cutMode == .threeHostPanel {
            speakerSegments = processor.analyzeThreeHostPanel(
                hostLeftChannel: leftChannel,
                hostMiddleChannel: groupChannels[0],
                hostRightChannel: groupChannels[1],
                guestChannel: groupChannels[2],
                sampleRate: sampleRate,
                duration: exactDurationSeconds,
                silenceDuration: 0.8
            )
        } else if cutMode == .mainSpeakerSwitch {
            speakerSegments = processor.analyzeMainSpeakerSwitchGroup(
                mainChannel: leftChannel, // Video One is Main Speaker
                groupChannels: groupChannels,
                sampleRate: sampleRate,
                duration: exactDurationSeconds,
                silenceDuration: 0.8
            )
        } else {
            speakerSegments = processor.analyzeSpeakerDominance(
                leftChannel: leftChannel,
                rightChannel: rightChannel,
                sampleRate: sampleRate,
                duration: exactDurationSeconds,
                minimumShotLength: 3.0
            )
        }
        
        print("Generated \(speakerSegments.count) video segments")
        for segment in speakerSegments {
            print("  \(segment.speaker): \(segment.startTime) - \(segment.endTime)")
        }
        
        // Step 6: Get video properties from Video One for output
        await updateProgress("Reading video properties...", progress: 0.7)
        var naturalSize: CGSize = .zero
        
        if #available(macOS 12.0, *) {
            guard let videoOneTrack = try await videoOneAsset.loadTracks(withMediaType: .video).first else {
                throw ProcessingError.noVideoTrack
            }
            naturalSize = try await videoOneTrack.load(.naturalSize)
            _ = try await videoOneTrack.load(.nominalFrameRate) // Load frame rate for potential future use
        } else {
            guard let videoOneTrack = videoOneAsset.tracks(withMediaType: .video).first else {
                throw ProcessingError.noVideoTrack
            }
            naturalSize = videoOneTrack.naturalSize
        }
        
        // Step 7: Compose the final video
        await updateProgress("Composing final video...", progress: 0.8)
        let composition = try await processor.composeVideo(
            videoOneAsset: videoOneAsset,
            videoTwoAsset: videoTwoAsset,
            soundAudioAsset: soundAudioAsset,
            videoOneOffset: videoOneOffset,
            videoTwoOffset: videoTwoOffset,
            videoOneCrop: videoOneCrop,
            videoTwoCrop: videoTwoCrop,
            speakerSegments: speakerSegments,
            outputSize: naturalSize,
            soundAudioDuration: soundAudioDuration,
            cutMode: cutMode,
            hostLeftCrop: hostLeftManualCrop,
            hostRightCrop: hostRightManualCrop
        )
        
        // Step 8: Export the final video
        await updateProgress("Exporting video (this may take a while)...", progress: 0.9)
        try await processor.exportVideo(
            composition: composition.composition,
            videoComposition: composition.videoComposition,
            to: outputURL
        )
        
        await MainActor.run {
            self.progress = 1.0
            self.statusMessage = "Export completed successfully!"
            self.isError = false
            self.isProcessing = false
        }
        
        print("Export completed to: \(outputURL.path)")
    }
    
    private func updateProgress(_ message: String, progress: Double = 0.0) async {
        await MainActor.run {
            self.progressMessage = message
            self.progress = progress
        }
    }
    
    private func selectOutputFolder() async -> URL? {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.canCreateDirectories = true
                panel.message = "Select output folder for the final video"
                panel.prompt = "Select Folder"
                
                panel.begin { response in
                    if response == .OK, let folderURL = panel.url {
                        // Create output file URL with default name and timestamp
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyyMMdd_HHmmss"
                        let timestamp = formatter.string(from: Date())
                        let outputURL = folderURL.appendingPathComponent("AutoPodCut_\(timestamp).mp4")
                        continuation.resume(returning: outputURL)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}

// MARK: - Speaker Segment Model

enum Speaker {
    case videoOne
    case videoTwo
    case hostLeft
    case hostRight
    case guest // equivalent to videoTwo in semantics usually, but distinct enum handles clarity
    case none // For segments where no video is available
}

struct SpeakerSegment {
    let speaker: Speaker
    let startTime: Double
    let endTime: Double
}

// MARK: - Processing Errors

enum ProcessingError: LocalizedError {
    case noAudioTrack
    case noVideoTrack
    case audioExtractionFailed
    case exportFailed(String)
    case compositionFailed
    
    var errorDescription: String? {
        switch self {
        case .noAudioTrack:
            return "No audio track found in asset"
        case .noVideoTrack:
            return "No video track found in asset"
        case .audioExtractionFailed:
            return "Failed to extract audio data"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .compositionFailed:
            return "Failed to compose video"
        }
    }
}

// MARK: - Video Cut Processor

class VideoCutProcessor {
    
    // MARK: - Audio Extraction
    
    /// Extracts specific tracks from the Sound Audio file
    /// Returns left channel (Video One speaker), right channel (Video Two speaker), and sample rate
    func extractSelectedChannels(from asset: AVAsset, leftIndex: Int, rightIndex: Int) async throws -> (left: [Float], right: [Float], sampleRate: Float) {
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw ProcessingError.noAudioTrack
        }
        
        // Create an asset reader to read audio samples
        let reader = try AVAssetReader(asset: asset)
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var leftSamples: [Float] = []
        var rightSamples: [Float] = []
        var sampleRate: Float = 44100
        var channelCount: Int = 2
        var isFormatRead = false
        
        // Read all sample buffers
        while let sampleBuffer = output.copyNextSampleBuffer() {
            // Get format description to extract sample rate
            if !isFormatRead, let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)
                if let asbd = audioStreamBasicDescription?.pointee {
                    sampleRate = Float(asbd.mSampleRate)
                    channelCount = Int(asbd.mChannelsPerFrame)
                    isFormatRead = true
                }
            }
            
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
            
            var length = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
            
            guard let data = dataPointer else { continue }
            
            // Convert to float samples (interleaved stereo: L, R, L, R, ...)
            let floatCount = length / MemoryLayout<Float>.size
            let floatPointer = data.withMemoryRebound(to: Float.self, capacity: floatCount) { $0 }
            
            let numFrames = floatCount / channelCount
            let lIdx = max(0, min(leftIndex - 1, channelCount - 1))
            let rIdx = max(0, min(rightIndex - 1, channelCount - 1))
            
            for frame in 0..<numFrames {
                let baseIndex = frame * channelCount
                leftSamples.append(floatPointer[baseIndex + lIdx])
                rightSamples.append(floatPointer[baseIndex + rIdx])
            }
        }
        
        print("Extracted \(leftSamples.count) samples per channel at \(sampleRate) Hz")
        return (leftSamples, rightSamples, sampleRate)
    }
    
    /// Extracts the Main channel and a group of all other available channels
    func extractMainAndGroupChannels(from asset: AVAsset, mainIndex: Int) async throws -> (main: [Float], group: [[Float]], sampleRate: Float) {
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw ProcessingError.noAudioTrack
        }
        
        let reader = try AVAssetReader(asset: asset)
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var mainSamples: [Float] = []
        var groupSamples: [[Float]] = []
        var sampleRate: Float = 44100
        var channelCount: Int = 2
        var isFormatRead = false
        
        while let sampleBuffer = output.copyNextSampleBuffer() {
            if !isFormatRead, let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)
                if let asbd = audioStreamBasicDescription?.pointee {
                    sampleRate = Float(asbd.mSampleRate)
                    channelCount = Int(asbd.mChannelsPerFrame)
                    
                    // Initialize group arrays
                    let numGroupChannels = max(1, channelCount - 1)
                    groupSamples = Array(repeating: [], count: numGroupChannels)
                    
                    isFormatRead = true
                }
            }
            
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
            
            var length = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
            
            guard let data = dataPointer else { continue }
            
            let floatCount = length / MemoryLayout<Float>.size
            let floatPointer = data.withMemoryRebound(to: Float.self, capacity: floatCount) { $0 }
            
            let numFrames = floatCount / channelCount
            let mIdx = max(0, min(mainIndex - 1, channelCount - 1))
            
            for frame in 0..<numFrames {
                let baseIndex = frame * channelCount
                mainSamples.append(floatPointer[baseIndex + mIdx])
                
                var groupIdx = 0
                for c in 0..<channelCount {
                    // Skip tracks 1 and 2 (indices 0 and 1) for the group mix, as well as the main track
                    if c != mIdx && c > 1 {
                        groupSamples[groupIdx].append(floatPointer[baseIndex + c])
                        groupIdx += 1
                    }
                }
            }
        }
        
        // Trim the groupSamples array to only hold the channels we actually extracted
        // This is necessary because we pre-allocated `channelCount - 1` earlier,
        // but now we are skipping indices 0 and 1.
        let actualGroupCount = groupSamples.filter { !$0.isEmpty }.count
        let finalGroupSamples = Array(groupSamples.prefix(actualGroupCount))
        
        print("Extracted Main channel and \(finalGroupSamples.count) Group channels with \(mainSamples.count) samples each at \(sampleRate) Hz")
        return (mainSamples, finalGroupSamples, sampleRate)
    }
    
    /// Extracts four specific tracks from the Sound Audio file
    func extractFourChannels(
        from asset: AVAsset,
        track1Index: Int,
        track2Index: Int,
        track3Index: Int,
        track4Index: Int
    ) async throws -> (track1: [Float], track2: [Float], track3: [Float], track4: [Float], sampleRate: Float) {
        
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw ProcessingError.noAudioTrack
        }
        
        let reader = try AVAssetReader(asset: asset)
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var t1Samples: [Float] = []
        var t2Samples: [Float] = []
        var t3Samples: [Float] = []
        var t4Samples: [Float] = []
        var sampleRate: Float = 44100
        var channelCount: Int = 2
        var isFormatRead = false
        
        while let sampleBuffer = output.copyNextSampleBuffer() {
            if !isFormatRead, let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)
                if let asbd = audioStreamBasicDescription?.pointee {
                    sampleRate = Float(asbd.mSampleRate)
                    channelCount = Int(asbd.mChannelsPerFrame)
                    isFormatRead = true
                }
            }
            
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
            
            var length = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
            
            guard let data = dataPointer else { continue }
            
            let floatCount = length / MemoryLayout<Float>.size
            let floatPointer = data.withMemoryRebound(to: Float.self, capacity: floatCount) { $0 }
            
            let numFrames = floatCount / channelCount
            let idx1 = max(0, min(track1Index - 1, channelCount - 1))
            let idx2 = max(0, min(track2Index - 1, channelCount - 1))
            let idx3 = max(0, min(track3Index - 1, channelCount - 1))
            let idx4 = max(0, min(track4Index - 1, channelCount - 1))
            
            for frame in 0..<numFrames {
                let baseIndex = frame * channelCount
                t1Samples.append(floatPointer[baseIndex + idx1])
                t2Samples.append(floatPointer[baseIndex + idx2])
                t3Samples.append(floatPointer[baseIndex + idx3])
                t4Samples.append(floatPointer[baseIndex + idx4])
            }
        }
        
        print("Extracted 4 channels with \(t1Samples.count) samples each at \(sampleRate) Hz")
        return (t1Samples, t2Samples, t3Samples, t4Samples, sampleRate)
    }
    
    /// Extracts mono audio from a video asset for synchronization purposes
    func extractMonoAudio(from asset: AVAsset) async throws -> [Float] {
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            // Return empty array if no audio track (will handle as missing video scenario)
            print("No audio track found in video asset")
            return []
        }
        
        let reader = try AVAssetReader(asset: asset)
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false,
            AVNumberOfChannelsKey: 1 // Convert to mono
        ]
        
        let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var samples: [Float] = []
        
        while let sampleBuffer = output.copyNextSampleBuffer() {
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
            
            var length = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
            
            guard let data = dataPointer else { continue }
            
            let floatCount = length / MemoryLayout<Float>.size
            let floatPointer = data.withMemoryRebound(to: Float.self, capacity: floatCount) { $0 }
            
            for i in 0..<floatCount {
                samples.append(floatPointer[i])
            }
        }
        
        print("Extracted \(samples.count) mono samples from video")
        return samples
    }
    
    /// Creates a mono mix from stereo channels (left + right averaged)
    /// This is used for synchronization since video cameras capture all room audio
    func createMonoMix(left: [Float], right: [Float]) -> [Float] {
        let count = min(left.count, right.count)
        var mono = [Float](repeating: 0, count: count)
        
        for i in 0..<count {
            mono[i] = (left[i] + right[i]) * 0.5
        }
        
        return mono
    }
    
    /// Creates a mono mix from main and group channels
    func createMonoMixGroup(main: [Float], group: [[Float]]) -> [Float] {
        let count = main.count
        var mono = [Float](repeating: 0, count: count)
        let totalChannels = Float(1 + group.count)
        
        for i in 0..<count {
            var sum = main[i]
            for g in group {
                if i < g.count {
                    sum += g[i]
                }
            }
            mono[i] = sum / totalChannels
        }
        
        return mono
    }
    
    // MARK: - Synchronization (GPU-Accelerated FFT Cross-Correlation)
    
    /// Find sync offset using FFT-based cross-correlation (GPU accelerated via Accelerate/vDSP)
    /// This is O(n log n) and uses hardware SIMD/GPU acceleration
    func findSyncOffset(
        videoAudio: [Float],
        referenceAudio: [Float],
        sampleRate: Float,
        videoName: String
    ) -> Double {
        print("\n========== \(videoName.uppercased()) SYNC (FFT-Accelerated) ==========")
        
        guard !videoAudio.isEmpty, !referenceAudio.isEmpty else {
            print("Empty audio, using zero offset")
            return 0.0
        }
        
        let videoDuration = Double(videoAudio.count) / Double(sampleRate)
        let refDuration = Double(referenceAudio.count) / Double(sampleRate)
        print("Video: \(String(format: "%.1f", videoDuration))s, Reference: \(String(format: "%.1f", refDuration))s")
        
        // Downsample for speed (8kHz is enough for speech sync)
        let targetSampleRate: Float = 8000
        let downsampleFactor = max(1, Int(sampleRate / targetSampleRate))
        let effectiveSampleRate = sampleRate / Float(downsampleFactor)
        
        let videoDS = downsample(videoAudio, factor: downsampleFactor)
        let refDS = downsample(referenceAudio, factor: downsampleFactor)
        
        print("Downsampled to \(String(format: "%.0f", effectiveSampleRate))Hz: video=\(videoDS.count), ref=\(refDS.count)")
        
        // Create energy envelopes (100ms windows for better resolution)
        let windowSamples = Int(effectiveSampleRate * 0.1)
        var videoEnv = computeEnergyEnvelope(videoDS, windowSize: windowSamples)
        var refEnv = computeEnergyEnvelope(refDS, windowSize: windowSamples)
        let envRate = effectiveSampleRate / Float(windowSamples)
        
        print("Envelopes: video=\(videoEnv.count), ref=\(refEnv.count) (rate: \(String(format: "%.1f", envRate))/s)")
        
        // Normalize using vDSP (GPU accelerated)
        normalizeInPlace(&videoEnv)
        normalizeInPlace(&refEnv)
        
        // FFT-based cross-correlation (O(n log n), GPU accelerated)
        print("Computing FFT cross-correlation...")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let (correlationResult, bestLag) = fftCrossCorrelation(signal: videoEnv, reference: refEnv)
        
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("FFT correlation computed in \(String(format: "%.3f", elapsed))s")
        
        // Convert lag to seconds
        // Positive lag means video envelope peak comes AFTER reference peak at that lag
        // So video started (lag) samples before reference in envelope time
        let offsetEnvPoints = bestLag
        let offsetSeconds = Double(offsetEnvPoints) / Double(envRate)
        
        // Get correlation value at best lag
        let corrValue = correlationResult[bestLag + refEnv.count - 1]
        let normalizedCorr = corrValue / Float(min(videoEnv.count, refEnv.count))
        
        print("\(videoName) RESULT:")
        print("  Offset: \(String(format: "%.2f", offsetSeconds)) seconds")
        print("  Correlation: \(String(format: "%.4f", normalizedCorr))")
        
        if offsetSeconds >= 0 {
            print("  → Video started \(String(format: "%.1f", offsetSeconds))s BEFORE Sound Audio")
        } else {
            print("  → Video started \(String(format: "%.1f", abs(offsetSeconds)))s AFTER Sound Audio")
        }
        print("=====================================================")
        
        return offsetSeconds
    }
    
    /// Downsample signal by taking every Nth sample
    private func downsample(_ signal: [Float], factor: Int) -> [Float] {
        guard factor > 1 else { return signal }
        return stride(from: 0, to: signal.count, by: factor).map { signal[$0] }
    }
    
    /// Normalize signal in place using vDSP (GPU accelerated)
    private func normalizeInPlace(_ signal: inout [Float]) {
        guard !signal.isEmpty else { return }
        
        // Compute mean using vDSP
        var mean: Float = 0
        vDSP_meanv(signal, 1, &mean, vDSP_Length(signal.count))
        
        // Subtract mean
        var negMean = -mean
        vDSP_vsadd(signal, 1, &negMean, &signal, 1, vDSP_Length(signal.count))
        
        // Compute standard deviation
        var sumSq: Float = 0
        vDSP_svesq(signal, 1, &sumSq, vDSP_Length(signal.count))
        let std = sqrt(sumSq / Float(signal.count))
        
        // Divide by std
        if std > 0 {
            var invStd = 1.0 / std
            vDSP_vsmul(signal, 1, &invStd, &signal, 1, vDSP_Length(signal.count))
        }
    }
    
    /// FFT-based cross-correlation using Accelerate framework (GPU accelerated)
    /// Returns (correlation array, best lag index)
    private func fftCrossCorrelation(signal: [Float], reference: [Float]) -> ([Float], Int) {
        // Pad to power of 2 for FFT efficiency
        let outputLength = signal.count + reference.count - 1
        let fftLength = nextPowerOf2(outputLength)
        let log2n = vDSP_Length(log2(Float(fftLength)))
        
        // Create FFT setup
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            print("Failed to create FFT setup")
            return ([], 0)
        }
        defer { vDSP_destroy_fftsetup(fftSetup) }
        
        // Pad signals to fftLength
        var signalPadded = [Float](repeating: 0, count: fftLength)
        var refPadded = [Float](repeating: 0, count: fftLength)
        
        for i in 0..<signal.count {
            signalPadded[i] = signal[i]
        }
        for i in 0..<reference.count {
            refPadded[i] = reference[i]
        }
        
        // Prepare split complex arrays for FFT
        var signalReal = [Float](repeating: 0, count: fftLength / 2)
        var signalImag = [Float](repeating: 0, count: fftLength / 2)
        var refReal = [Float](repeating: 0, count: fftLength / 2)
        var refImag = [Float](repeating: 0, count: fftLength / 2)
        
        // Convert to split complex format
        signalPadded.withUnsafeBufferPointer { signalPtr in
            signalReal.withUnsafeMutableBufferPointer { realPtr in
                signalImag.withUnsafeMutableBufferPointer { imagPtr in
                    var splitSignal = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                    vDSP_ctoz(UnsafePointer<DSPComplex>(OpaquePointer(signalPtr.baseAddress!)),
                              2, &splitSignal, 1, vDSP_Length(fftLength / 2))
                }
            }
        }
        
        refPadded.withUnsafeBufferPointer { refPtr in
            refReal.withUnsafeMutableBufferPointer { realPtr in
                refImag.withUnsafeMutableBufferPointer { imagPtr in
                    var splitRef = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                    vDSP_ctoz(UnsafePointer<DSPComplex>(OpaquePointer(refPtr.baseAddress!)),
                              2, &splitRef, 1, vDSP_Length(fftLength / 2))
                }
            }
        }
        
        // Forward FFT
        signalReal.withUnsafeMutableBufferPointer { signalRealPtr in
            signalImag.withUnsafeMutableBufferPointer { signalImagPtr in
                refReal.withUnsafeMutableBufferPointer { refRealPtr in
                    refImag.withUnsafeMutableBufferPointer { refImagPtr in
                        var splitSignal = DSPSplitComplex(realp: signalRealPtr.baseAddress!, imagp: signalImagPtr.baseAddress!)
                        var splitRef = DSPSplitComplex(realp: refRealPtr.baseAddress!, imagp: refImagPtr.baseAddress!)
                        
                        vDSP_fft_zrip(fftSetup, &splitSignal, 1, log2n, FFTDirection(FFT_FORWARD))
                        vDSP_fft_zrip(fftSetup, &splitRef, 1, log2n, FFTDirection(FFT_FORWARD))
                    }
                }
            }
        }
        
        // Multiply signal FFT by complex conjugate of reference FFT
        // This gives cross-correlation in frequency domain
        var resultReal = [Float](repeating: 0, count: fftLength / 2)
        var resultImag = [Float](repeating: 0, count: fftLength / 2)
        
        // Complex multiplication: (a+bi) * (c-di) = (ac+bd) + (bc-ad)i
        for i in 0..<fftLength / 2 {
            let a = signalReal[i]
            let b = signalImag[i]
            let c = refReal[i]
            let d = refImag[i]
            resultReal[i] = a * c + b * d  // Real part
            resultImag[i] = b * c - a * d  // Imag part
        }
        
        // Inverse FFT
        var correlation = [Float](repeating: 0, count: fftLength)
        resultReal.withUnsafeMutableBufferPointer { resultRealPtr in
            resultImag.withUnsafeMutableBufferPointer { resultImagPtr in
                var splitResult = DSPSplitComplex(realp: resultRealPtr.baseAddress!, imagp: resultImagPtr.baseAddress!)
                vDSP_fft_zrip(fftSetup, &splitResult, 1, log2n, FFTDirection(FFT_INVERSE))
                
                // Convert back to real array
                correlation.withUnsafeMutableBufferPointer { corrPtr in
                    vDSP_ztoc(&splitResult, 1,
                              UnsafeMutablePointer<DSPComplex>(OpaquePointer(corrPtr.baseAddress!)),
                              2, vDSP_Length(fftLength / 2))
                }
            }
        }
        
        // Scale by fftLength (vDSP convention)
        var scale = 1.0 / Float(fftLength)
        vDSP_vsmul(correlation, 1, &scale, &correlation, 1, vDSP_Length(fftLength))
        
        // Find the peak in the valid range
        // The correlation output has the zero-lag at index 0
        // Negative lags are wrapped to the end
        
        // Rearrange so negative lags come first
        let validLength = outputLength
        var rearranged = [Float](repeating: 0, count: validLength)
        
        // Copy positive lags (0 to signal.count-1)
        let positiveLags = min(signal.count, validLength - reference.count + 1)
        for i in 0..<positiveLags {
            let destIdx = reference.count - 1 + i
            if destIdx < validLength && i < correlation.count {
                rearranged[destIdx] = correlation[i]
            }
        }
        
        // Copy negative lags (wrapped at end of FFT output)
        for i in 0..<(reference.count - 1) {
            let srcIdx = fftLength - (reference.count - 1) + i
            if srcIdx < correlation.count && i < validLength {
                rearranged[i] = correlation[srcIdx]
            }
        }
        
        // Find peak
        var maxVal: Float = 0
        var maxIdx: vDSP_Length = 0
        vDSP_maxvi(rearranged, 1, &maxVal, &maxIdx, vDSP_Length(validLength))
        
        // Convert index to lag (relative to center which is zero lag)
        let bestLag = Int(maxIdx) - (reference.count - 1)
        
        return (rearranged, bestLag)
    }
    
    /// Find next power of 2 >= n
    private func nextPowerOf2(_ n: Int) -> Int {
        var p = 1
        while p < n {
            p *= 2
        }
        return p
    }
    
    /// Legacy function - kept for compatibility
    func findSyncOffsetWithConfidence(videoAudio: [Float], referenceAudio: [Float], sampleRate: Float) -> (offset: Double, confidence: Float) {
        // If video audio is empty, return 0 (no sync possible, will use fallback)
        guard !videoAudio.isEmpty, !referenceAudio.isEmpty else {
            print("Empty audio for sync, using zero offset")
            return (0.0, 0.0)
        }
        
        // Step 1: Preprocess audio - normalize and compute envelope
        print("Preprocessing audio for sync...")
        
        // Normalize both audio streams (remove DC offset and normalize amplitude)
        let videoNormalized = normalizeAudio(videoAudio)
        let referenceNormalized = normalizeAudio(referenceAudio)
        
        // Downsample for faster initial search
        let downsampleFactor = 8
        let effectiveSampleRate = sampleRate / Float(downsampleFactor)
        
        let videoDownsampled = stride(from: 0, to: videoNormalized.count, by: downsampleFactor).map { videoNormalized[$0] }
        let referenceDownsampled = stride(from: 0, to: referenceNormalized.count, by: downsampleFactor).map { referenceNormalized[$0] }
        
        // Compute energy envelopes (100ms windows) - this captures speech patterns
        let windowSamples = Int(effectiveSampleRate * 0.1) // 100ms windows
        print("Computing energy envelopes (window: \(windowSamples) samples = 100ms)...")
        
        let videoEnvelope = computeEnergyEnvelope(videoDownsampled, windowSize: windowSamples)
        let referenceEnvelope = computeEnergyEnvelope(referenceDownsampled, windowSize: windowSamples)
        
        // Normalize envelopes to [0,1] range for better correlation
        let videoEnvNorm = normalizeEnvelope(videoEnvelope)
        let refEnvNorm = normalizeEnvelope(referenceEnvelope)
        
        print("Video envelope: \(videoEnvNorm.count) points, Reference envelope: \(refEnvNorm.count) points")
        
        // Extended search range: +/- 10 minutes to handle very early starts
        let maxLagSeconds: Double = 600.0 // 10 minutes
        let envelopeRate = effectiveSampleRate / Float(windowSamples)
        let maxLagEnvelopePoints = Int(maxLagSeconds * Double(envelopeRate))
        
        print("Searching for best sync offset (range: +/- \(maxLagSeconds) seconds)...")
        
        // Step 2: Coarse search with normalized energy envelopes
        let coarseStepSize = max(1, maxLagEnvelopePoints / 6000) // ~100ms steps
        var candidates: [(offset: Int, correlation: Float)] = []
        
        for offsetPoints in stride(from: -maxLagEnvelopePoints, to: maxLagEnvelopePoints, by: coarseStepSize) {
            let correlation = computeNormalizedCorrelation(
                signal1: videoEnvNorm,
                signal2: refEnvNorm,
                offset: offsetPoints,
                windowSize: min(videoEnvNorm.count, Int(30 * Double(envelopeRate))) // 30 seconds window
            )
            
            candidates.append((offset: offsetPoints, correlation: correlation))
        }
        
        // Sort by correlation and get top candidates
        candidates.sort { $0.correlation > $1.correlation }
        let topCandidates = Array(candidates.prefix(5))
        
        print("Top 5 coarse candidates:")
        for (i, candidate) in topCandidates.enumerated() {
            let offsetSec = Double(candidate.offset) / Double(envelopeRate)
            print("  \(i+1). offset=\(String(format: "%.1f", offsetSec))s, correlation=\(String(format: "%.4f", candidate.correlation))")
        }
        
        // Step 3: Fine search for each top candidate using actual audio samples
        var bestFinalCorrelation: Float = -Float.infinity
        var bestFinalOffset: Double = 0
        
        // Less aggressive downsampling for fine search
        let fineDownsampleFactor = 2
        let fineSampleRate = sampleRate / Float(fineDownsampleFactor)
        let videoFine = stride(from: 0, to: videoNormalized.count, by: fineDownsampleFactor).map { videoNormalized[$0] }
        let referenceFine = stride(from: 0, to: referenceNormalized.count, by: fineDownsampleFactor).map { referenceNormalized[$0] }
        
        for candidate in topCandidates {
            let centerOffsetSeconds = Double(candidate.offset) / Double(envelopeRate)
            let centerOffsetSamples = Int(centerOffsetSeconds * Double(fineSampleRate))
            
            // Fine search +/- 5 seconds around this candidate
            let fineSearchRange = Int(5.0 * fineSampleRate)
            let fineStepSize = max(1, Int(0.05 * fineSampleRate)) // 50ms steps
            
            // Use multiple 10-second windows at different positions in the video
            let windowSize = Int(10 * fineSampleRate)
            let testPositions = [0, videoFine.count / 4, videoFine.count / 2, 3 * videoFine.count / 4]
            
            for testOffset in stride(from: centerOffsetSamples - fineSearchRange,
                                      to: centerOffsetSamples + fineSearchRange,
                                      by: fineStepSize) {
                var totalCorrelation: Float = 0
                var validWindows = 0
                
                for startPos in testPositions {
                    if startPos + windowSize > videoFine.count { continue }
                    
                    let corr = computeNormalizedCorrelationAtPosition(
                        signal1: videoFine,
                        signal2: referenceFine,
                        offset: testOffset,
                        startPosition: startPos,
                        windowSize: windowSize
                    )
                    
                    if corr > 0 {
                        totalCorrelation += corr
                        validWindows += 1
                    }
                }
                
                if validWindows > 0 {
                    let avgCorr = totalCorrelation / Float(validWindows)
                    if avgCorr > bestFinalCorrelation {
                        bestFinalCorrelation = avgCorr
                        bestFinalOffset = Double(testOffset) / Double(fineSampleRate)
                    }
                }
            }
        }
        
        print("Best sync offset: \(String(format: "%.2f", bestFinalOffset)) seconds (correlation: \(String(format: "%.4f", bestFinalCorrelation)))")
        print("Interpretation: Video started \(String(format: "%.1f", abs(bestFinalOffset))) seconds \(bestFinalOffset >= 0 ? "BEFORE" : "AFTER") Sound Audio")
        
        // Warn if correlation is low
        if bestFinalCorrelation < 0.3 {
            print("⚠️ WARNING: Low correlation (\(String(format: "%.4f", bestFinalCorrelation))) - sync may be unreliable!")
            print("   Consider checking if video audio matches the Sound Audio source.")
        } else if bestFinalCorrelation >= 0.5 {
            print("✓ Good correlation - sync should be reliable")
        }
        
        // Verify sync with multiple checkpoints throughout the video
        let verificationResult = verifySyncWithMultipleCheckpoints(
            videoAudio: videoFine,
            referenceAudio: referenceFine,
            initialOffset: Int(bestFinalOffset * Double(fineSampleRate)),
            sampleRate: fineSampleRate
        )
        
        if verificationResult.isConsistent {
            print("✓ Sync verified across \(verificationResult.checkpoints.count) checkpoints (avg correlation: \(String(format: "%.4f", verificationResult.averageCorrelation)))")
            return (verificationResult.refinedOffset, verificationResult.averageCorrelation)
        } else {
            print("⚠️ Sync verification: using best single-point offset")
        }
        
        return (bestFinalOffset, bestFinalCorrelation)
    }
    
    /// Finds sync offset by searching around a reference offset (used when initial sync fails)
    /// This is useful when one video synced successfully and we can use it as a reference for the other
    func findSyncOffsetWithReference(
        videoAudio: [Float],
        referenceAudio: [Float],
        sampleRate: Float,
        referenceOffset: Double,
        searchRange: Double
    ) -> (offset: Double, confidence: Float) {
        guard !videoAudio.isEmpty, !referenceAudio.isEmpty else {
            return (referenceOffset, 0.0)
        }
        
        print("Searching for sync around reference offset \(String(format: "%.2f", referenceOffset))s (+/- \(searchRange)s)...")
        
        // Normalize audio
        let videoNormalized = normalizeAudio(videoAudio)
        let referenceNormalized = normalizeAudio(referenceAudio)
        
        // Use moderate downsampling for good balance of speed and accuracy
        let downsampleFactor = 2
        let effectiveSampleRate = sampleRate / Float(downsampleFactor)
        
        let videoDownsampled = stride(from: 0, to: videoNormalized.count, by: downsampleFactor).map { videoNormalized[$0] }
        let referenceDownsampled = stride(from: 0, to: referenceNormalized.count, by: downsampleFactor).map { referenceNormalized[$0] }
        
        let centerOffsetSamples = Int(referenceOffset * Double(effectiveSampleRate))
        let searchRangeSamples = Int(searchRange * Double(effectiveSampleRate))
        let stepSize = max(1, Int(0.1 * effectiveSampleRate)) // 100ms steps
        
        var bestCorrelation: Float = -Float.infinity
        var bestOffset: Int = centerOffsetSamples
        
        // Test at multiple positions throughout the video for robustness
        let windowSize = Int(15 * effectiveSampleRate) // 15 second windows
        let testPositions: [Int] = [
            0,
            videoDownsampled.count / 5,
            2 * videoDownsampled.count / 5,
            3 * videoDownsampled.count / 5,
            4 * videoDownsampled.count / 5
        ]
        
        var progressCounter = 0
        let totalSteps = (2 * searchRangeSamples) / stepSize
        
        for testOffset in stride(from: centerOffsetSamples - searchRangeSamples,
                                  to: centerOffsetSamples + searchRangeSamples,
                                  by: stepSize) {
            var totalCorrelation: Float = 0
            var validWindows = 0
            
            for startPos in testPositions {
                if startPos + windowSize > videoDownsampled.count { continue }
                
                let corr = computeNormalizedCorrelationAtPosition(
                    signal1: videoDownsampled,
                    signal2: referenceDownsampled,
                    offset: testOffset,
                    startPosition: startPos,
                    windowSize: windowSize
                )
                
                if corr > 0 {
                    totalCorrelation += corr
                    validWindows += 1
                }
            }
            
            if validWindows > 0 {
                let avgCorr = totalCorrelation / Float(validWindows)
                if avgCorr > bestCorrelation {
                    bestCorrelation = avgCorr
                    bestOffset = testOffset
                }
            }
            
            progressCounter += 1
            if progressCounter % 100 == 0 {
                print("  Searched \(progressCounter)/\(totalSteps) offsets...")
            }
        }
        
        let bestOffsetSeconds = Double(bestOffset) / Double(effectiveSampleRate)
        print("  Best offset from reference search: \(String(format: "%.2f", bestOffsetSeconds))s (correlation: \(String(format: "%.4f", bestCorrelation)))")
        
        // Verify with checkpoints
        let verificationResult = verifySyncWithMultipleCheckpoints(
            videoAudio: videoDownsampled,
            referenceAudio: referenceDownsampled,
            initialOffset: bestOffset,
            sampleRate: effectiveSampleRate
        )
        
        if verificationResult.isConsistent {
            print("  ✓ Reference-based sync verified (avg correlation: \(String(format: "%.4f", verificationResult.averageCorrelation)))")
            return (verificationResult.refinedOffset, verificationResult.averageCorrelation)
        }
        
        return (bestOffsetSeconds, bestCorrelation)
    }
    
    /// Normalizes audio by removing DC offset and scaling to [-1, 1]
    private func normalizeAudio(_ samples: [Float]) -> [Float] {
        guard !samples.isEmpty else { return samples }
        
        // Remove DC offset (mean)
        var mean: Float = 0
        vDSP_meanv(samples, 1, &mean, vDSP_Length(samples.count))
        
        var normalized = samples.map { $0 - mean }
        
        // Find max absolute value
        var maxVal: Float = 0
        vDSP_maxmgv(normalized, 1, &maxVal, vDSP_Length(normalized.count))
        
        // Scale to [-1, 1]
        if maxVal > 0 {
            var scale = 1.0 / maxVal
            vDSP_vsmul(normalized, 1, &scale, &normalized, 1, vDSP_Length(normalized.count))
        }
        
        return normalized
    }
    
    /// Normalizes envelope to [0, 1] range
    private func normalizeEnvelope(_ envelope: [Float]) -> [Float] {
        guard !envelope.isEmpty else { return envelope }
        
        var maxVal: Float = 0
        vDSP_maxv(envelope, 1, &maxVal, vDSP_Length(envelope.count))
        
        if maxVal > 0 {
            return envelope.map { $0 / maxVal }
        }
        return envelope
    }
    
    /// Computes energy envelope of audio signal
    private func computeEnergyEnvelope(_ samples: [Float], windowSize: Int) -> [Float] {
        guard windowSize > 0 && !samples.isEmpty else { return [] }
        
        var envelope: [Float] = []
        let hopSize = windowSize // No overlap for speed
        
        for i in stride(from: 0, to: samples.count - windowSize, by: hopSize) {
            let window = Array(samples[i..<min(i + windowSize, samples.count)])
            let energy = calculateRMS(window)
            envelope.append(energy)
        }
        
        return envelope
    }
    
    /// Computes normalized cross-correlation between two signals at a given offset
    private func computeNormalizedCorrelation(signal1: [Float], signal2: [Float], offset: Int, windowSize: Int) -> Float {
        var correlation: Float = 0
        var norm1: Float = 0
        var norm2: Float = 0
        var count = 0
        
        let actualWindowSize = min(windowSize, signal1.count)
        
        for i in 0..<actualWindowSize {
            let idx2 = i - offset
            if idx2 >= 0 && idx2 < signal2.count {
                let v1 = signal1[i]
                let v2 = signal2[idx2]
                correlation += v1 * v2
                norm1 += v1 * v1
                norm2 += v2 * v2
                count += 1
            }
        }
        
        if count == 0 || norm1 == 0 || norm2 == 0 {
            return 0
        }
        
        return correlation / sqrt(norm1 * norm2)
    }
    
    /// Computes normalized correlation at a specific position in the signal
    private func computeNormalizedCorrelationAtPosition(
        signal1: [Float],
        signal2: [Float],
        offset: Int,
        startPosition: Int,
        windowSize: Int
    ) -> Float {
        var correlation: Float = 0
        var norm1: Float = 0
        var norm2: Float = 0
        var count = 0
        
        for i in 0..<windowSize {
            let idx1 = startPosition + i
            let idx2 = idx1 - offset
            
            if idx1 < signal1.count && idx2 >= 0 && idx2 < signal2.count {
                let v1 = signal1[idx1]
                let v2 = signal2[idx2]
                correlation += v1 * v2
                norm1 += v1 * v1
                norm2 += v2 * v2
                count += 1
            }
        }
        
        if count < windowSize / 2 || norm1 == 0 || norm2 == 0 {
            return 0
        }
        
        return correlation / sqrt(norm1 * norm2)
    }
    
    /// Verifies sync by checking correlation at multiple time points throughout the video
    private func verifySyncWithMultipleCheckpoints(
        videoAudio: [Float],
        referenceAudio: [Float],
        initialOffset: Int,
        sampleRate: Float
    ) -> (isConsistent: Bool, averageCorrelation: Float, checkpoints: [Float], refinedOffset: Double) {
        
        let videoDuration = Double(videoAudio.count) / Double(sampleRate)
        let checkpointInterval: Double = 60.0 // Check every 1 minute
        let checkpointWindow = Int(10 * sampleRate) // 10 seconds at each checkpoint
        
        var checkpointCorrelations: [Float] = []
        var checkpointOffsets: [Int] = []
        
        var currentTime: Double = 30 // Start 30 seconds in to avoid potential silence at start
        
        while currentTime < videoDuration - 15 {
            let videoStart = Int(currentTime * Double(sampleRate))
            
            if videoStart + checkpointWindow > videoAudio.count {
                break
            }
            
            // Fine-tune offset around initial offset at this checkpoint
            let searchRange = Int(1.0 * sampleRate) // +/- 1 second
            let searchStep = max(1, Int(0.05 * sampleRate)) // 50ms steps
            
            var bestLocalCorr: Float = -1
            var bestLocalOffset = initialOffset
            
            for testOffset in stride(from: initialOffset - searchRange,
                                      to: initialOffset + searchRange,
                                      by: searchStep) {
                let corr = computeNormalizedCorrelationAtPosition(
                    signal1: videoAudio,
                    signal2: referenceAudio,
                    offset: testOffset,
                    startPosition: videoStart,
                    windowSize: checkpointWindow
                )
                
                if corr > bestLocalCorr {
                    bestLocalCorr = corr
                    bestLocalOffset = testOffset
                }
            }
            
            if bestLocalCorr > 0.1 { // Only count if correlation is reasonable
                checkpointCorrelations.append(bestLocalCorr)
                checkpointOffsets.append(bestLocalOffset)
                print("  Checkpoint at \(Int(currentTime))s: correlation=\(String(format: "%.4f", bestLocalCorr)), offset=\(String(format: "%.2f", Double(bestLocalOffset)/Double(sampleRate)))s")
            }
            
            currentTime += checkpointInterval
        }
        
        if checkpointCorrelations.count < 2 {
            return (false, 0, [], Double(initialOffset) / Double(sampleRate))
        }
        
        // Calculate average correlation
        let avgCorrelation = checkpointCorrelations.reduce(0, +) / Float(checkpointCorrelations.count)
        
        // Calculate median offset (more robust than average)
        let sortedOffsets = checkpointOffsets.sorted()
        let medianOffset = sortedOffsets[sortedOffsets.count / 2]
        let refinedOffsetSeconds = Double(medianOffset) / Double(sampleRate)
        
        // Check consistency
        let maxOffsetDiff = checkpointOffsets.max()! - checkpointOffsets.min()!
        let maxOffsetDiffSeconds = Double(maxOffsetDiff) / Double(sampleRate)
        
        // More lenient consistency check
        let isConsistent = avgCorrelation > 0.25 && maxOffsetDiffSeconds < 2.0
        
        if !isConsistent {
            print("  Note: avgCorr=\(String(format: "%.4f", avgCorrelation)), maxOffsetDiff=\(String(format: "%.2f", maxOffsetDiffSeconds))s")
        }
        
        return (isConsistent, avgCorrelation, checkpointCorrelations, refinedOffsetSeconds)
    }
    
    // MARK: - Speaker Analysis
    
    /// Analyzes which speaker is dominant at each point in time
    /// Returns segments indicating which video to show and when
    func analyzeSpeakerDominance(
        leftChannel: [Float],
        rightChannel: [Float],
        sampleRate: Float,
        duration: Double,
        minimumShotLength: Double
    ) -> [SpeakerSegment] {
        
        // Analysis window size (100ms windows for loudness analysis)
        let windowSize = Int(sampleRate * 0.1)
        let windowCount = min(leftChannel.count, rightChannel.count) / windowSize
        
        // Calculate RMS for each window and channel
        var leftRMS: [Float] = []
        var rightRMS: [Float] = []
        
        for i in 0..<windowCount {
            let startIndex = i * windowSize
            let endIndex = min(startIndex + windowSize, min(leftChannel.count, rightChannel.count))
            
            let leftWindow = Array(leftChannel[startIndex..<endIndex])
            let rightWindow = Array(rightChannel[startIndex..<endIndex])
            
            leftRMS.append(calculateRMS(leftWindow))
            rightRMS.append(calculateRMS(rightWindow))
        }
        
        // Determine dominant speaker for each window
        var dominantSpeakers: [Speaker] = []
        for i in 0..<windowCount {
            // Add a small threshold to avoid switching on very quiet sections
            let threshold: Float = 0.01
            if leftRMS[i] < threshold && rightRMS[i] < threshold {
                // Both quiet, maintain previous or default to video one
                dominantSpeakers.append(dominantSpeakers.last ?? .videoOne)
            } else if leftRMS[i] > rightRMS[i] {
                dominantSpeakers.append(.videoOne)
            } else {
                dominantSpeakers.append(.videoTwo)
            }
        }
        
        // Convert windows to time and apply minimum shot length constraint
        let windowDuration = Double(windowSize) / Double(sampleRate)
        var segments: [SpeakerSegment] = []
        var currentSpeaker = dominantSpeakers.first ?? .videoOne
        var segmentStartTime = 0.0
        var lastSwitchTime = 0.0
        
        for (index, speaker) in dominantSpeakers.enumerated() {
            let currentTime = Double(index) * windowDuration
            
            // Check if speaker changed and minimum shot length is satisfied
            if speaker != currentSpeaker {
                let timeSinceLastSwitch = currentTime - lastSwitchTime
                
                if timeSinceLastSwitch >= minimumShotLength {
                    // Create segment for previous speaker
                    segments.append(SpeakerSegment(
                        speaker: currentSpeaker,
                        startTime: segmentStartTime,
                        endTime: currentTime
                    ))
                    
                    // Start new segment
                    currentSpeaker = speaker
                    segmentStartTime = currentTime
                    lastSwitchTime = currentTime
                }
                // If minimum shot length not satisfied, continue with current speaker
            }
        }
        
        // Add final segment
        segments.append(SpeakerSegment(
            speaker: currentSpeaker,
            startTime: segmentStartTime,
            endTime: duration
        ))
        
        return segments
    }
    
    /// Analyzes speaker segments strictly following the "Main Speaker" paradigm.
    /// Main Speaker (MainChannel) holds the view until they are silent for `silenceDuration` seconds.
    func analyzeMainSpeakerSwitch(
        mainChannel: [Float],
        otherChannel: [Float],
        sampleRate: Float,
        duration: Double,
        silenceDuration: Double
    ) -> [SpeakerSegment] {
        
        // 100ms analysis windows
        let windowSize = Int(sampleRate * 0.1)
        let windowCount = min(mainChannel.count, otherChannel.count) / windowSize
        
        var mainRMS: [Float] = []
        var otherRMS: [Float] = []
        for i in 0..<windowCount {
            let startIndex = i * windowSize
            let endIndex = min(startIndex + windowSize, min(mainChannel.count, otherChannel.count))
            mainRMS.append(calculateRMS(Array(mainChannel[startIndex..<endIndex])))
            otherRMS.append(calculateRMS(Array(otherChannel[startIndex..<endIndex])))
        }
        
        // Dynamically calculate noise floor and peak
        let sortedMain = mainRMS.sorted()
        let noiseFloor = sortedMain[max(0, sortedMain.count / 20)] // 5th percentile
        let peakRMS = sortedMain[min(sortedMain.count - 1, Int(Double(sortedMain.count) * 0.95))] // 95th percentile
        
        // The silence threshold is dynamically set at 15% of the dynamic range above noise floor
        let silenceThreshold = noiseFloor + (peakRMS - noiseFloor) * 0.15
        
        print("Main Speaker Config - Noise Floor: \(noiseFloor), Peak: \(peakRMS), Silence Threshold: \(silenceThreshold)")
        
        let windowDuration = Double(windowSize) / Double(sampleRate)
        
        var segments: [SpeakerSegment] = []
        var currentSpeaker: Speaker = .videoOne // Default to Main Speaker
        var segmentStartTime = 0.0
        var lastSwitchTime = 0.0
        let minimumShotLength = 1.0 // 1 second minimum shot length
        
        for i in 0..<windowCount {
            let mRMS = mainRMS[i]
            let oRMS = otherRMS[i]
            let currentTime = Double(i) * windowDuration
            
            let mainIsLoud = mRMS > silenceThreshold
            let otherIsLoud = oRMS > silenceThreshold
            
            var targetSpeaker = currentSpeaker
            
            if otherIsLoud && oRMS > (mRMS * 1.5) {
                targetSpeaker = .videoTwo
            } else if mainIsLoud && mRMS > (oRMS * 1.5) {
                targetSpeaker = .videoOne
            } else if mainIsLoud && otherIsLoud {
                targetSpeaker = (mRMS >= oRMS) ? .videoOne : .videoTwo
            } else {
                // If neither is clearly loud, keep the current speaker's camera
                targetSpeaker = currentSpeaker
            }
            
            if targetSpeaker != currentSpeaker {
                let timeSinceLastSwitch = currentTime - lastSwitchTime
                if timeSinceLastSwitch >= minimumShotLength {
                    if i > 0 { // Avoid zero-length first segment
                        segments.append(SpeakerSegment(
                            speaker: currentSpeaker,
                            startTime: segmentStartTime,
                            endTime: currentTime
                        ))
                    }
                    currentSpeaker = targetSpeaker
                    segmentStartTime = currentTime
                    lastSwitchTime = currentTime
                }
            }
        }
        
        // Final segment
        segments.append(SpeakerSegment(
            speaker: currentSpeaker,
            startTime: segmentStartTime,
            endTime: duration
        ))
        
        return segments
    }
    
    /// Analyzes speaker segments matching 1 Main Speaker against an Auto-Group of other speakers
    func analyzeMainSpeakerSwitchGroup(
        mainChannel: [Float],
        groupChannels: [[Float]],
        sampleRate: Float,
        duration: Double,
        silenceDuration: Double
    ) -> [SpeakerSegment] {
        
        // 100ms analysis windows
        let windowSize = Int(sampleRate * 0.1)
        let windowCount = mainChannel.count / windowSize
        
        var mainRMS: [Float] = []
        var maxGroupRMS: [Float] = [] // We care about the maximum volume among the group
        
        for i in 0..<windowCount {
            let startIndex = i * windowSize
            let endIndex = min(startIndex + windowSize, mainChannel.count)
            mainRMS.append(calculateRMS(Array(mainChannel[startIndex..<endIndex])))
            
            var maxG: Float = 0
            for groupChannel in groupChannels {
                let endG = min(startIndex + windowSize, groupChannel.count)
                if startIndex < endG {
                    let gRms = calculateRMS(Array(groupChannel[startIndex..<endG]))
                    maxG = max(maxG, gRms)
                }
            }
            maxGroupRMS.append(maxG)
        }
        
        // Dynamically calculate noise floor and peak
        let sortedMain = mainRMS.sorted()
        let noiseFloor = sortedMain[max(0, sortedMain.count / 20)] // 5th percentile
        let peakRMS = sortedMain[min(sortedMain.count - 1, Int(Double(sortedMain.count) * 0.95))] // 95th percentile
        
        // The silence threshold is dynamically set at 15% of the dynamic range above noise floor
        let silenceThreshold = noiseFloor + (peakRMS - noiseFloor) * 0.15
        
        print("Main Group Config - Noise Floor: \(noiseFloor), Peak: \(peakRMS), Silence Threshold: \(silenceThreshold)")
        
        let windowDuration = Double(windowSize) / Double(sampleRate)
        
        var segments: [SpeakerSegment] = []
        var currentSpeaker: Speaker = .videoOne // Default to Main Speaker
        var segmentStartTime = 0.0
        var lastSwitchTime = 0.0
        let minimumShotLength = 1.0 // 1 second minimum shot length
        
        for i in 0..<windowCount {
            let mRMS = mainRMS[i]
            let oRMS = maxGroupRMS[i] // Use max group volume instead of single "other" track
            let currentTime = Double(i) * windowDuration
            
            let mainIsLoud = mRMS > silenceThreshold
            let groupIsLoud = oRMS > silenceThreshold
            
            var targetSpeaker = currentSpeaker
            
            if groupIsLoud && oRMS > (mRMS * 1.5) {
                targetSpeaker = .videoTwo
            } else if mainIsLoud && mRMS > (oRMS * 1.5) {
                targetSpeaker = .videoOne
            } else if mainIsLoud && groupIsLoud {
                targetSpeaker = (mRMS >= oRMS) ? .videoOne : .videoTwo
            } else {
                // If neither is clearly loud, keep the current speaker's camera
                targetSpeaker = currentSpeaker
            }
            
            if targetSpeaker != currentSpeaker {
                let timeSinceLastSwitch = currentTime - lastSwitchTime
                if timeSinceLastSwitch >= minimumShotLength {
                    if i > 0 { // Avoid zero-length first segment
                        segments.append(SpeakerSegment(
                            speaker: currentSpeaker,
                            startTime: segmentStartTime,
                            endTime: currentTime
                        ))
                    }
                    currentSpeaker = targetSpeaker
                    segmentStartTime = currentTime
                    lastSwitchTime = currentTime
                }
            }
        }
        
        // Final segment
        segments.append(SpeakerSegment(
            speaker: currentSpeaker,
            startTime: segmentStartTime,
            endTime: duration
        ))
        
        return segments
    }
    
    /// Analyzes speaker segments for the Three Host Panel mode
    func analyzeThreeHostPanel(
        hostLeftChannel: [Float],
        hostMiddleChannel: [Float],
        hostRightChannel: [Float],
        guestChannel: [Float],
        sampleRate: Float,
        duration: Double,
        silenceDuration: Double
    ) -> [SpeakerSegment] {
        
        // 100ms analysis windows
        let windowSize = Int(sampleRate * 0.1)
        let windowCount = guestChannel.count / windowSize
        
        var hlRMS: [Float] = []
        var hmRMS: [Float] = []
        var hrRMS: [Float] = []
        var gRMS: [Float] = []
        
        for i in 0..<windowCount {
            let startIndex = i * windowSize
            let endIndex = min(startIndex + windowSize, guestChannel.count)
            hlRMS.append(calculateRMS(Array(hostLeftChannel[startIndex..<endIndex])))
            hmRMS.append(calculateRMS(Array(hostMiddleChannel[startIndex..<endIndex])))
            hrRMS.append(calculateRMS(Array(hostRightChannel[startIndex..<endIndex])))
            gRMS.append(calculateRMS(Array(guestChannel[startIndex..<endIndex])))
        }
        
        // Dynamic noise floor based on Guest track as baseline
        let sortedG = gRMS.sorted()
        let noiseFloor = sortedG[max(0, sortedG.count / 20)] // 5th percentile
        let peakRMS = sortedG[min(sortedG.count - 1, Int(Double(sortedG.count) * 0.95))]
        let silenceThreshold = noiseFloor + (peakRMS - noiseFloor) * 0.15
        
        let windowDuration = Double(windowSize) / Double(sampleRate)
        
        var segments: [SpeakerSegment] = []
        var currentSpeaker: Speaker = .hostLeft // Default to Left Host
        var segmentStartTime = 0.0
        var lastSwitchTime = 0.0
        let minimumShotLength = 1.0
        
        for i in 0..<windowCount {
            let hl = hlRMS[i]
            let hm = hmRMS[i]
            let hr = hrRMS[i]
            let g = gRMS[i]
            let currentTime = Double(i) * windowDuration
            
            var targetSpeaker = currentSpeaker
            
            // Guest dominates
            if g > silenceThreshold && g > (hl * 1.5) && g > (hr * 1.5) && g > (hm * 1.5) {
                targetSpeaker = .guest
            } else if hm > silenceThreshold && hm > hl && hm > hr && hm > g {
                // Middle host dominates. Keep current host side, or default Left.
                if currentSpeaker == .guest {
                    targetSpeaker = .hostLeft // Fallback
                } else {
                    targetSpeaker = currentSpeaker // Stay on Left or Right
                }
            } else if hl > silenceThreshold && hl > hr && hl > g {
                targetSpeaker = .hostLeft
            } else if hr > silenceThreshold && hr > hl && hr > g {
                targetSpeaker = .hostRight
            }
            // else stay
            
            if targetSpeaker != currentSpeaker {
                let timeSinceLastSwitch = currentTime - lastSwitchTime
                if timeSinceLastSwitch >= minimumShotLength {
                    if i > 0 {
                        segments.append(SpeakerSegment(
                            speaker: currentSpeaker,
                            startTime: segmentStartTime,
                            endTime: currentTime
                        ))
                    }
                    currentSpeaker = targetSpeaker
                    segmentStartTime = currentTime
                    lastSwitchTime = currentTime
                }
            }
        }
        
        segments.append(SpeakerSegment(
            speaker: currentSpeaker,
            startTime: segmentStartTime,
            endTime: duration
        ))
        
        return segments
    }
    
    /// Calculates Root Mean Square of audio samples
    private func calculateRMS(_ samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }
        var sumSquares: Float = 0
        vDSP_svesq(samples, 1, &sumSquares, vDSP_Length(samples.count))
        return sqrt(sumSquares / Float(samples.count))
    }
    
    // MARK: - Video Composition
    
    /// Creates the final video composition with all segments
    func composeVideo(
        videoOneAsset: AVAsset,
        videoTwoAsset: AVAsset,
        soundAudioAsset: AVAsset,
        videoOneOffset: Double,
        videoTwoOffset: Double,
        videoOneCrop: CropPreset,
        videoTwoCrop: CropPreset,
        speakerSegments: [SpeakerSegment],
        outputSize: CGSize,
        soundAudioDuration: CMTime,
        cutMode: CutMode,
        hostLeftCrop: CGRect?,
        hostRightCrop: CGRect?
    ) async throws -> (composition: AVMutableComposition, videoComposition: AVMutableVideoComposition) {
        
        let composition = AVMutableComposition()
        
        // Create tracks in composition
        guard let compVideoOneTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw ProcessingError.compositionFailed
        }
        
        guard let compVideoTwoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw ProcessingError.compositionFailed
        }
        
        guard let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw ProcessingError.compositionFailed
        }
        
        // Get video tracks from source assets
        let videoOneTracks = try await videoOneAsset.loadTracks(withMediaType: .video)
        let videoTwoTracks = try await videoTwoAsset.loadTracks(withMediaType: .video)
        let soundAudioTracks = try await soundAudioAsset.loadTracks(withMediaType: .audio)
        
        let videoOneTrack = videoOneTracks.first
        let videoTwoTrack = videoTwoTracks.first
        
        guard let soundAudioTrack = soundAudioTracks.first else {
            throw ProcessingError.noAudioTrack
        }
        
        // Add the complete Sound Audio track to the composition
        // This is the master audio that plays throughout
        try compositionAudioTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: soundAudioDuration),
            of: soundAudioTrack,
            at: .zero
        )
        
        var videoOneAssetDuration: CMTime
        var videoTwoAssetDuration: CMTime
        if #available(macOS 12.0, *) {
            videoOneAssetDuration = try await videoOneAsset.load(.duration)
            videoTwoAssetDuration = try await videoTwoAsset.load(.duration)
        } else {
            videoOneAssetDuration = videoOneAsset.duration
            videoTwoAssetDuration = videoTwoAsset.duration
        }
        let v1DurSecs = CMTimeGetSeconds(videoOneAssetDuration)
        let v2DurSecs = CMTimeGetSeconds(videoTwoAssetDuration)
        
        // --- NEW CONTINUOUS TRACK INJECTION LOGIC ---
        // Instead of injecting piecemeal segments (which causes black frames if gaps exist),
        // we inject the entirety of Video 1 and Video 2 into their respective tracks as base layers.
        // We will then use VideoCompositionInstructions to toggle opacity.
        
        if let track = videoOneTrack {
            var v1StartOffset = CMTime(seconds: videoOneOffset, preferredTimescale: 600)
            var v1CompStart = CMTime.zero
            
            if videoOneOffset < 0 {
                // Video starts AFTER audio. So it starts at composition time abs(offset).
                v1CompStart = CMTime(seconds: -videoOneOffset, preferredTimescale: 600)
                v1StartOffset = .zero
            }
            
            let sourceDuration = CMTimeSubtract(videoOneAssetDuration, v1StartOffset)
            if sourceDuration > .zero {
                try compVideoOneTrack.insertTimeRange(
                    CMTimeRange(start: v1StartOffset, duration: sourceDuration),
                    of: track,
                    at: v1CompStart
                )
            }
        }
        
        if let track = videoTwoTrack {
            var v2StartOffset = CMTime(seconds: videoTwoOffset, preferredTimescale: 600)
            var v2CompStart = CMTime.zero
            
            if videoTwoOffset < 0 {
                v2CompStart = CMTime(seconds: -videoTwoOffset, preferredTimescale: 600)
                v2StartOffset = .zero
            }
            
            let sourceDuration = CMTimeSubtract(videoTwoAssetDuration, v2StartOffset)
            if sourceDuration > .zero {
                try compVideoTwoTrack.insertTimeRange(
                    CMTimeRange(start: v2StartOffset, duration: sourceDuration),
                    of: track,
                    at: v2CompStart
                )
            }
        }
        
        // Resolve segments to prevent black frames when a video runs out of duration
        var resolvedSegments: [SpeakerSegment] = []
        for segment in speakerSegments {
            var currentTime = segment.startTime
            let endTime = segment.endTime
            
            while currentTime < endTime {
                if (endTime - currentTime) < 0.001 { break } // Avoid micro-segments
                
                let remainingDuration = endTime - currentTime
                let primarySpeaker = segment.speaker
                let secondarySpeaker: Speaker = (primarySpeaker == .videoOne) ? .videoTwo : .videoOne
                
                func availableDuration(for speaker: Speaker, at time: Double) -> Double {
                    guard speaker != .none else { return 0 }
                    let isVideoOne = (speaker == .videoOne || speaker == .hostLeft || speaker == .hostRight)
                    let offset = isVideoOne ? videoOneOffset : videoTwoOffset
                    let srcTime = time + offset
                    let maxDur = isVideoOne ? v1DurSecs : v2DurSecs
                    if srcTime >= 0 && srcTime < maxDur {
                        return maxDur - srcTime
                    }
                    return 0
                }
                
                let primaryAvailable = availableDuration(for: primarySpeaker, at: currentTime)
                
                if primaryAvailable >= remainingDuration - 0.001 {
                    resolvedSegments.append(SpeakerSegment(speaker: primarySpeaker, startTime: currentTime, endTime: endTime))
                    currentTime = endTime
                } else if primaryAvailable > 0.01 {
                    let partialEndTime = currentTime + primaryAvailable
                    resolvedSegments.append(SpeakerSegment(speaker: primarySpeaker, startTime: currentTime, endTime: partialEndTime))
                    currentTime = partialEndTime
                } else {
                    let secondaryAvailable = availableDuration(for: secondarySpeaker, at: currentTime)
                    if secondaryAvailable >= remainingDuration - 0.001 {
                        resolvedSegments.append(SpeakerSegment(speaker: secondarySpeaker, startTime: currentTime, endTime: endTime))
                        currentTime = endTime
                    } else if secondaryAvailable > 0.01 {
                        let partialEndTime = currentTime + secondaryAvailable
                        resolvedSegments.append(SpeakerSegment(speaker: secondarySpeaker, startTime: currentTime, endTime: partialEndTime))
                        currentTime = partialEndTime
                    } else {
                        resolvedSegments.append(SpeakerSegment(speaker: .none, startTime: currentTime, endTime: endTime))
                        currentTime = endTime
                    }
                }
            }
        }
        // This makes sense if both videos are requested to be cropped.
        let isHalfWidthOutput = (videoOneCrop != .full && videoTwoCrop != .full)
        let renderSize = isHalfWidthOutput ? CGSize(width: outputSize.width / 2, height: outputSize.height) : outputSize
        
        // Create video composition for proper rendering
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30 fps
        
        // Build individual instructions per segment to avoid empty track crashes
        var instructions: [AVMutableVideoCompositionInstruction] = []
        
        for segment in resolvedSegments {
            let segmentStart = CMTime(seconds: segment.startTime, preferredTimescale: 600)
            let segmentEnd = CMTime(seconds: segment.endTime, preferredTimescale: 600)
            let rawSegmentDuration = CMTimeSubtract(segmentEnd, segmentStart)
            
            // Skip invalid or negative duration segments
            guard rawSegmentDuration > .zero else { continue }
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: segmentStart, duration: rawSegmentDuration)
            
            // Construct persistent Layer Instructions
            let layer1 = AVMutableVideoCompositionLayerInstruction(assetTrack: compVideoOneTrack)
            var transform1 = CGAffineTransform.identity
            if #available(macOS 12.0, *) {
                if let track = try? await videoOneAsset.loadTracks(withMediaType: .video).first {
                    transform1 = (try? await track.load(.preferredTransform)) ?? .identity
                }
            } else {
                if let track = videoOneAsset.tracks(withMediaType: .video).first {
                    transform1 = track.preferredTransform
                }
            }
            
            if cutMode == .threeHostPanel {
                if segment.speaker == .hostLeft, let crop = hostLeftCrop {
                    let scaleX = outputSize.width / crop.width
                    let scaleY = outputSize.height / crop.height
                    let scale = max(scaleX, scaleY) // fill 4K screen
                    
                    let translateX = -crop.origin.x * scale
                    let translateY = -crop.origin.y * scale
                    
                    let finalTransform = transform1
                        .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                        .concatenating(CGAffineTransform(translationX: translateX, y: translateY))
                    
                    layer1.setTransform(finalTransform, at: segmentStart)
                } else if segment.speaker == .hostRight, let crop = hostRightCrop {
                    let scaleX = outputSize.width / crop.width
                    let scaleY = outputSize.height / crop.height
                    let scale = max(scaleX, scaleY)
                    
                    let translateX = -crop.origin.x * scale
                    let translateY = -crop.origin.y * scale
                    
                    let finalTransform = transform1
                        .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                        .concatenating(CGAffineTransform(translationX: translateX, y: translateY))
                    
                    layer1.setTransform(finalTransform, at: segmentStart)
                } else {
                    layer1.setTransform(transform1, at: segmentStart)
                }
            } else if isHalfWidthOutput {
                let offsetTransform = videoOneCrop == .rightHalf ? CGAffineTransform(translationX: -outputSize.width / 2, y: 0) : .identity
                layer1.setTransform(transform1.concatenating(offsetTransform), at: segmentStart)
            } else {
                if videoOneCrop == .leftHalf {
                    layer1.setCropRectangle(CGRect(x: 0, y: 0, width: outputSize.width / 2, height: outputSize.height), at: segmentStart)
                } else if videoOneCrop == .rightHalf {
                    layer1.setCropRectangle(CGRect(x: outputSize.width / 2, y: 0, width: outputSize.width / 2, height: outputSize.height), at: segmentStart)
                }
                layer1.setTransform(transform1, at: segmentStart)
            }
            
            let layer2 = AVMutableVideoCompositionLayerInstruction(assetTrack: compVideoTwoTrack)
            var transform2 = CGAffineTransform.identity
            if #available(macOS 12.0, *) {
                if let track = try? await videoTwoAsset.loadTracks(withMediaType: .video).first {
                    transform2 = (try? await track.load(.preferredTransform)) ?? .identity
                }
            } else {
                if let track = videoTwoAsset.tracks(withMediaType: .video).first {
                    transform2 = track.preferredTransform
                }
            }
            
            if isHalfWidthOutput {
                let offsetTransform = videoTwoCrop == .rightHalf ? CGAffineTransform(translationX: -outputSize.width / 2, y: 0) : .identity
                layer2.setTransform(transform2.concatenating(offsetTransform), at: segmentStart)
            } else {
                if videoTwoCrop == .leftHalf {
                    layer2.setCropRectangle(CGRect(x: 0, y: 0, width: outputSize.width / 2, height: outputSize.height), at: segmentStart)
                } else if videoTwoCrop == .rightHalf {
                    layer2.setCropRectangle(CGRect(x: outputSize.width / 2, y: 0, width: outputSize.width / 2, height: outputSize.height), at: segmentStart)
                }
                layer2.setTransform(transform2, at: segmentStart)
            }
            
            // Set opacity based on active speaker
            if cutMode == .threeHostPanel {
                if segment.speaker == .hostLeft || segment.speaker == .hostRight {
                    layer1.setOpacity(1.0, at: segmentStart)
                    layer2.setOpacity(0.0, at: segmentStart)
                    instruction.layerInstructions = [layer1, layer2]
                } else if segment.speaker == .guest {
                    layer1.setOpacity(0.0, at: segmentStart)
                    layer2.setOpacity(1.0, at: segmentStart)
                    instruction.layerInstructions = [layer2, layer1]
                } else {
                    layer1.setOpacity(1.0, at: segmentStart)
                    layer2.setOpacity(0.0, at: segmentStart)
                    instruction.layerInstructions = [layer1, layer2]
                }
            } else {
                if segment.speaker == .videoOne {
                    layer1.setOpacity(1.0, at: segmentStart)
                    layer2.setOpacity(0.0, at: segmentStart)
                    instruction.layerInstructions = [layer1, layer2] // videoOne is on top
                } else if segment.speaker == .videoTwo {
                    layer1.setOpacity(0.0, at: segmentStart)
                    layer2.setOpacity(1.0, at: segmentStart)
                    instruction.layerInstructions = [layer2, layer1] // videoTwo is on top
                } else {
                    // If neither, show videoOne but let it fall back
                    layer1.setOpacity(1.0, at: segmentStart)
                    layer2.setOpacity(0.0, at: segmentStart)
                    instruction.layerInstructions = [layer1, layer2]
                }
            }
            
            instructions.append(instruction)
        }
        
        videoComposition.instructions = instructions
        
        return (composition, videoComposition)
    }
    
    // MARK: - Export
    
    /// Exports the composition to a file with H.265 codec
    func exportVideo(
        composition: AVMutableComposition,
        videoComposition: AVMutableVideoComposition,
        to outputURL: URL
    ) async throws {
        // Remove existing file if present
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHEVCHighestQuality // H.265 codec
        ) else {
            throw ProcessingError.exportFailed("Could not create export session")
        }
        
        exportSession.videoComposition = videoComposition
        exportSession.shouldOptimizeForNetworkUse = false
        
        print("Starting export to: \(outputURL.path)")
        
        // Use the new async throwing export API (macOS 15+)
        do {
            try await exportSession.export(to: outputURL, as: .mp4)
            print("Export completed successfully")
        } catch {
            print("Export failed: \(error.localizedDescription)")
            throw ProcessingError.exportFailed(error.localizedDescription)
        }
    }
}

// MARK: - Crop Preset

enum CropPreset: String, CaseIterable {
    case full = "Full Video"
    case leftHalf = "Left Half"
    case rightHalf = "Right Half"
}

// MARK: - Preview

#Preview {
    ContentView()
}
