//
//  ContentView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

struct ContentView: View {
    
    // User Defaults
    @AppStorage("visualizerStyle") private var visualizerStyle: VisualizerStyle = .albumArt
    @AppStorage("connectedApp") private var connectedApp: ConnectedApps = .spotify
    
    // View Model
    @ObservedObject var contentViewVM: ContentViewModel
    
    // States for animations
    @State private var isShowingPlaybackControls = false
    
    @State private var isDraggingSeeker = false
    @State private var currentSeekerPosition: CGFloat = 0
    @State private var draggingSeekerProgress: Double = 0
    
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isUpdatingPosition = false
    @State private var newPosition: Double = 0
    
    // Constants
    let primaryOpacity = 0.8
    let primaryOpacity2 = 0.6
    let secondaryOpacity = 0.4
    let ternaryOpacity = 0.2
    
    fileprivate func renderPreviousTrackButton() -> some View {
        return Button {
            contentViewVM.previousTrack()
        } label: {
            Image(systemName: "backward.end.fill")
                .font(.system(size: 16))
                .foregroundColor(.primary.opacity(primaryOpacity))
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderPlayButton() -> some View {
        return Button {
            contentViewVM.togglePlayPause()
        } label: {
            Image(systemName: contentViewVM.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 26))
                .foregroundColor(.primary.opacity(primaryOpacity))
                .frame(width: 25, height: 25)
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderNextTrackButton() -> some View {
        return Button {
            contentViewVM.nextTrack()
        } label: {
            Image(systemName: "forward.end.fill")
                .font(.system(size: 16))
                .foregroundColor(.primary.opacity(primaryOpacity))
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderAppleShuffleButton(_ shuffling: Bool?) -> some View {
        return Button {
            contentViewVM.appleMusicApp?.setShuffleEnabled?(!shuffling!)
        } label: {
            Image(systemName: shuffling! ? "shuffle.circle.fill" : "shuffle.circle")
                .font(.system(size: 14))
                .foregroundColor(.primary.opacity(primaryOpacity))
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderSpotifyShuffleButton(_ shuffling: Bool?) -> some View {
        return Button {
            contentViewVM.spotifyApp?.setShuffling?(!shuffling!)
        } label: {
            Image(systemName: shuffling! ? "shuffle.circle.fill" : "shuffle.circle")
                .font(.system(size: 14))
                .foregroundColor(.primary.opacity(primaryOpacity))
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderSpotifyRepeatButton(_ repeating: Bool?) -> some View {
        return Button {
            contentViewVM.spotifyApp?.setRepeating?(!repeating!)
        } label: {
            Image(systemName: repeating! ? "repeat.circle.fill" : "repeat.circle")
                .font(.system(size: 14))
                .foregroundColor(.primary.opacity(primaryOpacity))
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderAppleRepeatButton(_ repeating: MusicERpt?) -> some View {
        return Button {
            if repeating == .all {
                contentViewVM.appleMusicApp?.setSongRepeat!(.one)
            } else if repeating == .one {
                contentViewVM.appleMusicApp?.setSongRepeat!(.off)
            } else if repeating == .off {
                contentViewVM.appleMusicApp?.setSongRepeat!(.all)
            } else {
                contentViewVM.appleMusicApp?.setSongRepeat!(.off)
            }
        } label: {
            Image(systemName: repeating! == .all ? "repeat.circle.fill" : repeating! == .one ? "repeat.1.circle.fill" : "repeat.circle")
                .font(.system(size: 14))
                .foregroundColor(.primary.opacity(primaryOpacity))
        }
        .pressButtonStyle()
    }
    
    fileprivate func renderPlaceholder() -> some View {
        return Text("Play something on \(contentViewVM.name)")
            .foregroundColor(.primary.opacity(secondaryOpacity))
            .font(.system(size: 24, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }
    
    fileprivate func renderPlaybackButtons() -> some View {
        return HStack(spacing: 6) {
            if case connectedApp = ConnectedApps.spotify {
                renderSpotifyShuffleButton(contentViewVM.spotifyApp?.shuffling)
                Spacer().frame(width: 2)
            }
            
            if case connectedApp = ConnectedApps.appleMusic {
                renderAppleShuffleButton(contentViewVM.appleMusicApp?.shuffleEnabled)
                Spacer().frame(width: 2)
            }
            
            renderPreviousTrackButton()
            
            renderPlayButton()
            
            renderNextTrackButton()
            
            if case connectedApp = ConnectedApps.spotify {
                Spacer().frame(width: 2)
                renderSpotifyRepeatButton(contentViewVM.spotifyApp?.repeating)
            }
            
            if case connectedApp = ConnectedApps.appleMusic {
                Spacer().frame(width: 2)
                renderAppleRepeatButton(contentViewVM.appleMusicApp?.songRepeat)
            }
            
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
        .cornerRadius(100)
        .opacity(isShowingPlaybackControls ? 1 : 0)
    }
    
    @ViewBuilder
    func renderAlbumArtBackground() -> some View {
        Image(nsImage: contentViewVM.track.albumArt)
            .resizable()
            .scaledToFill()
            .padding(-12)
        VisualEffectView(material: .popover, blendingMode: .withinWindow)
            .padding(-12)
    }
    
    @ViewBuilder
        func renderAlbumArt() -> some View {
            Rectangle()
                .foregroundColor(
                    visualizerStyle != .none
                    ? .white.opacity(ternaryOpacity)
                    : .primary.opacity(ternaryOpacity))
                .frame(width: 240, height: 240)
                .cornerRadius(8)
            
            Image(nsImage: contentViewVM.track.albumArt)
                .resizable()
                .scaledToFill()
                .frame(width: 240, height: 240)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    
    fileprivate func renderTrackTitleAndArtist() -> some View {
        return HStack(alignment: .center) {
            Text(contentViewVM.track.title)
                .foregroundColor(.primary.opacity(primaryOpacity))
                .font(.system(size: 15, weight: .bold))
                .lineLimit(1)
            
            if contentViewVM.track.artist != "" {
                Circle()
                    .foregroundColor(.primary)
                    .frame(width: 4, height: 4)
                Text(contentViewVM.track.artist)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary.opacity(primaryOpacity2))
            }
            
        }
        .padding(.top, 10)
    }
    
    fileprivate func renderMusicControl() -> HStack<TupleView<(Button<some View>, Button<some View>)>> {
        return HStack(spacing: 2) {
            Button(action: {
                contentViewVM.setPlayerVolume(contentViewVM.getPlayerVolume() - 10)
            }) {
                Image(systemName: "speaker.wave.1.fill")
                    .frame(width: 8, height: 8)
            }
            
            Button(action: {
                contentViewVM.setPlayerVolume(contentViewVM.getPlayerVolume() + 10)
            }) {
                Image(systemName: "speaker.wave.3.fill")
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    fileprivate func renderLiveStateText() -> some View {
        return HStack(spacing: 5) {
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
            Text("Live")
                .foregroundColor(.primary.opacity(primaryOpacity2))
                .font(.system(size: 12))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(6)
    }
    
    fileprivate func renderProgressText() -> Text {
        return Text(!isDraggingSeeker ? "\(formatSecondsForDisplay(contentViewVM.seekerPosition)) / \(formatSecondsForDisplay(contentViewVM.trackDuration))" : "\(formatSecondsForDisplay(contentViewVM.trackDuration * draggingSeekerProgress)) / \(formatSecondsForDisplay(contentViewVM.trackDuration))")
            .foregroundColor(.primary.opacity(primaryOpacity2))
            .font(.system(size: 12))
    }
    
    fileprivate func renderOpenSpotifyButton() -> Button<some View> {
        return Button(action: {
            let spotifyURL = URL(string: "spotify://")!
            NSWorkspace.shared.open(spotifyURL)
        }) {
            Image(systemName: "arrow.up.forward.app.fill")
                .frame(width: 34, height: 8)
        }
    }
    
    fileprivate func renderOpenAppleButton() -> Button<some View> {
        return Button(action: {
            if let appleMusicURL = URL(string: "music://") {
                NSWorkspace.shared.open(appleMusicURL)
            }
        }) {
            Image(systemName: "arrow.up.forward.app.fill")
                .frame(width: 34, height: 8)
        }
    }
    
    fileprivate func renderLoveMusicButton() -> Button<some View> {
        return Button(action: {
            contentViewVM.appleMusicApp?.currentTrack?.setLoved!(!(contentViewVM.appleMusicApp?.currentTrack?.loved)!)
        }) {
            Image(systemName: (contentViewVM.appleMusicApp?.currentTrack?.loved)! ? "heart.fill" : "heart").frame(width: 34, height: 8)
        }
    }
    
    fileprivate func renderDisabledProgressBar() -> some View {
        return RoundedRectangle(cornerRadius: 8).foregroundColor(.gray.opacity(0.4)).frame(height: 6)
    }
    
    fileprivate func renderEmptyProgressBar(geometry: GeometryProxy) -> some View {
        return RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.gray.opacity(0.4))
            .frame(height: 6)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    isDraggingSeeker = true
                    NSCursor.pointingHand.set()
                    
                    currentSeekerPosition = min(max(value.location.x, 0), geometry.size.width)
                    
                    draggingSeekerProgress = Double(currentSeekerPosition / geometry.size.width)
                })
                    .onEnded({ value in
                        currentSeekerPosition = min(max(value.location.x, 0), geometry.size.width)
                        let newPosition = currentSeekerPosition / geometry.size.width * contentViewVM.trackDuration
                        contentViewVM.seekerPosition = newPosition
                        
                        if case connectedApp = ConnectedApps.spotify {
                            contentViewVM.spotifyApp?.setPlayerPosition?(newPosition)
                        }
                        
                        if case connectedApp = ConnectedApps.appleMusic {
                            contentViewVM.appleMusicApp?.setPlayerPosition?(newPosition)
                        }
                        
                        NSCursor.arrow.set()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isDraggingSeeker = false
                        }
                    })
            )
    }
    
    fileprivate func renderFilledProgressBar(geometry: GeometryProxy) -> some View {
        return RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.white)
            .frame(width: isDraggingSeeker ? currentSeekerPosition : geometry.size.width * CGFloat(isDraggingSeeker ? draggingSeekerProgress : (contentViewVM.seekerPosition / contentViewVM.trackDuration)), height: 6)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        isDraggingSeeker = true
                        NSCursor.pointingHand.set()
                        
                        currentSeekerPosition = min(max(value.location.x, 0), geometry.size.width)
                        
                        draggingSeekerProgress = Double(currentSeekerPosition / geometry.size.width)
                    })
                    .onEnded({ value in
                        currentSeekerPosition = min(max(value.location.x, 0), geometry.size.width)
                        let newPosition = currentSeekerPosition / geometry.size.width * contentViewVM.trackDuration
                        contentViewVM.seekerPosition = newPosition
                        
                        if case connectedApp = ConnectedApps.spotify {
                            contentViewVM.spotifyApp?.setPlayerPosition?(newPosition)
                        }
                        
                        if case connectedApp = ConnectedApps.appleMusic {
                            contentViewVM.appleMusicApp?.setPlayerPosition?(newPosition)
                        }
                        
                        NSCursor.arrow.set()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isDraggingSeeker = false
                        }
                    })
            )
    }
    
    fileprivate func renderDraggingCircle(geometry: GeometryProxy) -> some View {
        return Circle()
            .foregroundColor(.white)
            .frame(width: 10, height: 10)
            .offset(x: isDraggingSeeker ? currentSeekerPosition - 8 : (geometry.size.width * CGFloat(contentViewVM.seekerPosition / contentViewVM.trackDuration) - 8))
            .gesture(DragGesture()
                .onChanged({ value in
                    isDraggingSeeker = true
                    NSCursor.pointingHand.set()
                    
                    currentSeekerPosition = min(max(value.location.x, 0), geometry.size.width)
                    
                    draggingSeekerProgress = Double(currentSeekerPosition / geometry.size.width)
                })
                    .onEnded({ value in
                        currentSeekerPosition = min(max(value.location.x, 0), geometry.size.width)
                        let newPosition = currentSeekerPosition / geometry.size.width * contentViewVM.trackDuration
                        contentViewVM.seekerPosition = newPosition
                        
                        if case connectedApp = ConnectedApps.spotify {
                            contentViewVM.spotifyApp?.setPlayerPosition?(newPosition)
                        }
                        
                        if case connectedApp = ConnectedApps.appleMusic {
                            contentViewVM.appleMusicApp?.setPlayerPosition?(newPosition)
                        }
                        
                        NSCursor.arrow.set()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isDraggingSeeker = false
                        }
                    })
            )
    }
    
    fileprivate func renderProgressBar() -> some View {
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if contentViewVM.trackDuration == 0 && contentViewVM.seekerPosition == 0 {
                    renderDisabledProgressBar()
                } else {
                    renderEmptyProgressBar(geometry: geometry)
                    renderFilledProgressBar(geometry: geometry)
                    renderDraggingCircle(geometry: geometry)
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    fileprivate func renderBottomBar() -> some View {
        return HStack(alignment: .center) {
            renderMusicControl()
            
            Spacer()
            
            if contentViewVM.trackDuration == 0 && contentViewVM.seekerPosition == 0 {
                renderLiveStateText()
            } else {
                renderProgressText()
            }
            
            Spacer()
            
            if case connectedApp = ConnectedApps.spotify {
                renderOpenSpotifyButton()
            }
            
            if case connectedApp = ConnectedApps.appleMusic {
                if contentViewVM.appleMusicApp?.currentTrack?.loved != nil {
                    renderLoveMusicButton()
                } else {
                    renderOpenAppleButton()
                }
            }
        }
        .padding(10)
        .padding(.bottom, 5)
    }
    
    var body: some View {
        ZStack {
            if !contentViewVM.isRunning {
                renderPlaceholder()
            }
            
            if contentViewVM.isRunning {
                
                if visualizerStyle == .albumArt {
                    renderAlbumArtBackground()
                }
                
                VStack(spacing: 0) {
                    VStack {
                        ZStack {
                            renderAlbumArt()
                            renderPlaybackButtons()
                        }
                        .onHover { _ in
                            withAnimation(.linear(duration: 0.1)) {
                                self.isShowingPlaybackControls.toggle()
                            }
                        }
                        
                        Spacer().frame(height: 15)
                        
                        VStack(alignment: .center) {
                            renderTrackTitleAndArtist()

                            renderProgressBar()
                            
                            Spacer(minLength: 15)
                            
                            renderBottomBar()
                        }
                        .frame(width: 216, height: 78, alignment: .center)
                        .offset(y: 1)
                        .padding(12)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .onReceive(contentViewVM.timer) { _ in
            contentViewVM.getCurrentSeekerPosition()
        }
    }
    
    private func formatSecondsForDisplay(_ seconds: Double) -> String {
        let date = Date(timeIntervalSince1970: seconds)
        let hours = Int(seconds / 3600)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        if (hours > 0) { formatter.dateFormat = "H:m:ss" }
        else { formatter.dateFormat = "m:ss" }

        return formatter.string(from: date)
    }
}
