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
    
    // Constants
    let primaryOpacity = 0.8
    let primaryOpacity2 = 0.6
    let secondaryOpacity = 0.4
    let ternaryOpacity = 0.2
    
    var body: some View {
        
        ZStack {
            if visualizerStyle == .albumArt && contentViewVM.isRunning {
                Image(nsImage: contentViewVM.track.albumArt)
                    .resizable()
                    .scaledToFill()
                    .padding(-12)
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
                    .padding(-12)
            }
            
            if !contentViewVM.isRunning {
                Text("Play something on \(contentViewVM.name)")
                    .foregroundColor(.primary.opacity(secondaryOpacity))
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 0) {
                    // Media details
                    VStack {
                        // Album art image
                        ZStack {
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
                            
                            // Playback Buttons
                            HStack(spacing: 6) {
                                if case connectedApp = ConnectedApps.spotify {
                                    let shuffling = contentViewVM.spotifyApp?.shuffling
                                    
                                    Button {
                                        contentViewVM.spotifyApp?.setShuffling?(!shuffling!)
                                    } label: {
                                        Image(systemName: shuffling! ? "shuffle.circle.fill" : "shuffle.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary.opacity(primaryOpacity))
                                    }
                                    .pressButtonStyle()
                                    
                                    Spacer().frame(width: 2)
                                }
                                
                                if case connectedApp = ConnectedApps.appleMusic {
                                    let shuffling = contentViewVM.appleMusicApp?.shuffleEnabled
                                    
                                    Button {
                                        contentViewVM.appleMusicApp?.setShuffleEnabled?(!shuffling!)
                                    } label: {
                                        Image(systemName: shuffling! ? "shuffle.circle.fill" : "shuffle.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary.opacity(primaryOpacity))
                                    }
                                    .pressButtonStyle()
                                    
                                    Spacer().frame(width: 2)
                                }
                                
                                Button {
                                    contentViewVM.previousTrack()
                                } label: {
                                    Image(systemName: "backward.end.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary.opacity(primaryOpacity))
                                }
                                .pressButtonStyle()
                                
                                Button {
                                    contentViewVM.togglePlayPause()
                                } label: {
                                    Image(systemName: contentViewVM.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.primary.opacity(primaryOpacity))
                                        .frame(width: 25, height: 25)
                                }
                                .pressButtonStyle()
                                
                                Button {
                                    contentViewVM.nextTrack()
                                } label: {
                                    Image(systemName: "forward.end.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary.opacity(primaryOpacity))
                                }
                                .pressButtonStyle()
                                
                                if case connectedApp = ConnectedApps.spotify {
                                    let repeating = contentViewVM.spotifyApp?.repeating
                                    
                                    Spacer().frame(width: 2)
                                    
                                    Button {
                                        contentViewVM.spotifyApp?.setRepeating?(!repeating!)
                                    } label: {
                                        Image(systemName: repeating! ? "repeat.circle.fill" : "repeat.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary.opacity(primaryOpacity))
                                    }
                                    .pressButtonStyle()
                                }
                                
                                if case connectedApp = ConnectedApps.appleMusic {
                                    let repeating = contentViewVM.appleMusicApp?.songRepeat
                                    
                                    Spacer().frame(width: 2)
                                    
                                    Button {
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
                                
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                            .cornerRadius(100)
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                            
                        }
                        .onHover { _ in
                            withAnimation(.linear(duration: 0.1)) {
                                self.isShowingPlaybackControls.toggle()
                            }
                            
                        }
                        
                        Spacer()
                        
                        // Track details
                        VStack(alignment: .center) {
                            Text(contentViewVM.track.title)
                                .foregroundColor(.primary.opacity(primaryOpacity))
                                .font(.system(size: 15, weight: .bold))
                                .lineLimit(1)
                            Text(contentViewVM.track.artist)
                                .font(.headline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .foregroundColor(.primary.opacity(primaryOpacity2))
                            Text("\(formatSecondsForDisplay(contentViewVM.seekerPosition)) / \(formatSecondsForDisplay(contentViewVM.trackDuration))")
                                .foregroundColor(.primary.opacity(primaryOpacity2))
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                        .frame(width: 216, height: 68, alignment: .center)
                        .offset(y: 1)
                        .padding(.horizontal, 8)
                        
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
