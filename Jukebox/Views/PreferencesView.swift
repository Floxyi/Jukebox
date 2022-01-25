//
//  PreferencesView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import SwiftUI
import LaunchAtLogin

struct PreferencesView: View {
    
    private weak var parentWindow: PreferencesWindow!
    
    @AppStorage("visualizerStyle") private var visualizerStyle = VisualizerStyle.albumArt
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    @State private var showingPopover = false

    private var name: Text {
        Text(connectedApp.localizedName)
    }
    
    init(parentWindow: PreferencesWindow) {
        self.parentWindow = parentWindow
    }
    
    // MARK: - Main Body
    var body: some View {
        
        VStack(spacing: 0) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                closeButton
                appInfo
            }
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .center)
            .offset(y: 1) // Looked like it was off center
            
            Divider()
            
            preferencePanes
        }
        .ignoresSafeArea()
        
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    parentWindow.close()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.leading, 12)
                Spacer()
            }
            Spacer()
        }
    }
    
    // MARK: - App Info
    private var appInfo: some View {
        HStack(spacing: 8) {
            HStack {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Jukebox").font(.headline)
                    Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading)
            
            Spacer()
            
            HStack {
                Button {
                    NSWorkspace.shared.open(Constants.AppInfo.repo)
                } label: {
                    Text("GitHub").font(.system(size: 12))
                }
                .buttonStyle(LinkButtonStyle())
                
                Button {
                    NSWorkspace.shared.open(Constants.AppInfo.website)
                } label: {
                    Text("Website").font(.system(size: 12))
                }
                .buttonStyle(LinkButtonStyle())
                .disabled(true)
            }
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - Preference Panes
    private var preferencePanes: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // General Pane
            VStack(alignment: .leading) {
                Text("General")
                    .font(.title2)
                    .fontWeight(.semibold)
                LaunchAtLogin.Toggle()
                HStack {
                    Picker("Connect Jukebox to", selection: $connectedApp) {
                        ForEach(ConnectedApps.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                    Button {
                        showingPopover = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $showingPopover) {
                        Text("If an alert doesn't show to connect \(name) after trying to play a song, please go to System Preferences > Security & Privacy > Privacy > Automation, and check \(name) under Jukebox")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .frame(width: 180, height: 80)
                            .padding()
                    }

                }
                
            }
            .padding()
            
            Divider()
            
            // Visualizer Pane
            VStack(alignment: .leading) {
                Text("Background")
                    .font(.title2)
                    .fontWeight(.semibold)
                Picker("Style", selection: $visualizerStyle) {
                    ForEach(VisualizerStyle.allCases, id: \.self) { value in
                        Text(value.localizedName).tag(value)
                    }
                }
            }
            .padding()
            
        }
    }
    
}
