import SwiftUI
import AVKit
import AVFoundation
import AppKit

struct CropSelectionView: View {
    let videoURL: URL
    let title: String
    @Binding var cropRect: CGRect?
    @Binding var isPresented: Bool
    
    var onSave: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
    @State private var player: AVPlayer?
    @State private var currentCrop: CGRect = CGRect(x: 0, y: 0, width: 960, height: 540)
    @State private var videoSize: CGSize = .zero
    @State private var viewSize: CGSize = .zero
    
    // We force a 16:9 crop aspect ratio
    private let aspect: CGFloat = 16.0 / 9.0
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .padding()
            
            GeometryReader { geo in
                ZStack {
                    if let player = player {
                        if #available(macOS 14.0, *) {
                            VideoPlayer(player: player)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .onAppear {
                                    self.viewSize = geo.size
                                    calculateInitialCrop()
                                }
                                .onChange(of: geo.size) { oldSize, newSize in
                                    self.viewSize = newSize
                                }
                        } else {
                            VideoPlayer(player: player)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .onAppear {
                                    self.viewSize = geo.size
                                    calculateInitialCrop()
                                }
                                .onChange(of: geo.size, perform: { newSize in
                                    self.viewSize = newSize
                                })
                        }
                    } else {
                        Color.black
                    }
                    
                    // The crop overlay
                    if videoSize != .zero && viewSize != .zero {
                        CropOverlay(
                            videoSize: videoSize,
                            viewSize: viewSize,
                            crop: $currentCrop,
                            aspect: aspect
                        )
                    }
                }
            }
            .frame(minWidth: 600, minHeight: 400)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                    onCancel?()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                if #available(macOS 12.0, *) {
                    Button("Save Crop") {
                        cropRect = currentCrop
                        isPresented = false
                        onSave?()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Save Crop") {
                        cropRect = currentCrop
                        isPresented = false
                        onSave?()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
        }
        .frame(
            width: (NSScreen.main?.visibleFrame.width ?? 1440) * 0.85,
            height: (NSScreen.main?.visibleFrame.height ?? 900) * 0.85
        )
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        let asset = AVURLAsset(url: videoURL)
        Task {
            if #available(macOS 12.0, *) {
                if let track = try? await asset.loadTracks(withMediaType: .video).first {
                    if let size = try? await track.load(.naturalSize) {
                        await MainActor.run {
                            self.videoSize = size
                            self.player = AVPlayer(url: videoURL)
                            self.player?.isMuted = true
                            calculateInitialCrop()
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
                let tracks = asset.tracks(withMediaType: .video)
                if let track = tracks.first {
                    DispatchQueue.main.async {
                        self.videoSize = track.naturalSize
                        self.player = AVPlayer(url: videoURL)
                        self.player?.isMuted = true
                        calculateInitialCrop()
                    }
                }
            }
        }
    }
    
    private func calculateInitialCrop() {
        guard videoSize != .zero else { return }
        
        // If we already have a crop, use it
        if let existing = cropRect {
            currentCrop = existing
        } else {
            // Default: a 16:9 box in the center, half the size of the video
            let h = videoSize.height / 2
            let w = h * aspect
            let x = (videoSize.width - w) / 2
            let y = (videoSize.height - h) / 2
            currentCrop = CGRect(x: x, y: y, width: w, height: h)
        }
    }
}

// A view that allows dragging and resizing a crop rectangle over a scaled video space
struct CropOverlay: View {
    let videoSize: CGSize
    let viewSize: CGSize
    @Binding var crop: CGRect // In video coordinates
    let aspect: CGFloat
    
    @State private var isDragging = false
    @State private var dragStartCrop: CGRect = .zero
    
    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / videoSize.width
            let scaleY = geo.size.height / videoSize.height
            let scale = min(scaleX, scaleY)
            
            let drawWidth = videoSize.width * scale
            let drawHeight = videoSize.height * scale
            let offsetX = (geo.size.width - drawWidth) / 2
            let offsetY = (geo.size.height - drawHeight) / 2
            
            // Map crop (video coords) to view coords
            let rectX = offsetX + crop.origin.x * scale
            let rectY = offsetY + crop.origin.y * scale
            let rectW = crop.size.width * scale
            let rectH = crop.size.height * scale
            
            ZStack {
                // Dimmed background outside crop
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: geo.size))
                    path.addRect(CGRect(x: rectX, y: rectY, width: rectW, height: rectH))
                }
                .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))
                .allowsHitTesting(false)
                
                // Crop box
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: rectW, height: rectH)
                    .position(x: rectX + rectW/2, y: rectY + rectH/2)
                
                // Visible bounding box for dragging
                Rectangle()
                    .fill(Color.white.opacity(0.01))
                    .frame(width: rectW, height: rectH)
                    .position(x: rectX + rectW/2, y: rectY + rectH/2)
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                if !isDragging {
                                    isDragging = true
                                    dragStartCrop = crop
                                }
                                
                                // Drag delta in video coords
                                let dx = val.translation.width / scale
                                let dy = val.translation.height / scale
                                
                                var newX = dragStartCrop.origin.x + dx
                                var newY = dragStartCrop.origin.y + dy
                                
                                // Clamp
                                newX = max(0, min(newX, videoSize.width - dragStartCrop.width))
                                newY = max(0, min(newY, videoSize.height - dragStartCrop.height))
                                
                                crop.origin = CGPoint(x: newX, y: newY)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                
                // Bottom-right resize handle
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 16, height: 16)
                    .position(x: rectX + rectW, y: rectY + rectH)
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                if !isDragging {
                                    isDragging = true
                                    dragStartCrop = crop
                                }
                                
                                // Drag delta in video coords
                                let dx = val.translation.width / scale
                                
                                // Always maintain aspect ratio (16:9)
                                var newW = dragStartCrop.width + dx
                                var newH = newW / aspect
                                
                                // Clamp to video boundaries
                                if dragStartCrop.origin.x + newW > videoSize.width {
                                    newW = videoSize.width - dragStartCrop.origin.x
                                    newH = newW / aspect
                                }
                                if dragStartCrop.origin.y + newH > videoSize.height {
                                    newH = videoSize.height - dragStartCrop.origin.y
                                    newW = newH * aspect
                                }
                                
                                // Minimum size
                                if newW < 160 {
                                    newW = 160
                                    newH = newW / aspect
                                }
                                
                                crop.size = CGSize(width: newW, height: newH)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
        }
    }
}
