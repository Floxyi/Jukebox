//
//  StatusBarInformation.swift
//  Jukebox
//
//  Created by Florian Winkler on 02.08.23.
//

import Foundation
import SwiftUI
import AppKit

class StatusBarInformation: NSView {
    
    @AppStorage("showAnimation") private var showAnimation = true
    @AppStorage("statusTextStyle") private var statusTextStyle = StatusTextStyle.titleWithArtist
    @AppStorage("statusBarWidthLimit") private var statusBarWidthLimit = 200.0
    @AppStorage("statusBarTextSpeed") private var statusBarTextSpeed = 80.0
    
    // Invalidating Variables
    var menubarIsDarkAppearance: Bool {
        didSet {
            animate()
            self.needsDisplay = true
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            animate()
            self.needsDisplay = true
        }
    }
    
    var menuText: String = "" {
        didSet {
            animate()
            self.needsDisplay = true
        }
    }
    
    // Computed Properties
    private var backgroundColor: CGColor {
        menubarIsDarkAppearance ? NSColor.white.cgColor : NSColor.black.cgColor
    }
    
    // Properties
    private var bars = [CALayer]()
    private var menubarHeight: Double
    
    // Overrides
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    let barHeights = [5.0, 7.0, 9.0, 6.0]
    let barDurations = [0.6, 0.3, 0.5, 0.7]
    
    init(menubarAppearance: NSAppearance, menubarHeight: Double, isPlaying: Bool) {
        self.menubarIsDarkAppearance = menubarAppearance.name == .vibrantDark ? true : false
        self.isPlaying = isPlaying
        self.menubarHeight = menubarHeight
        
        super.init(frame: CGRect(
            x: Constants.StatusBar.statusBarButtonPadding,
            y: 0,
            width: Constants.StatusBar.statusBarMaxWidth,
            height: menubarHeight))
        self.wantsLayer = true
        
        animate()
    }
    
    func animate() {
        self.layer?.sublayers?.removeAll()
        bars.removeAll()
        
        if isPlaying {
            let mainLayer = CALayer()

            for i in 0..<barHeights.count {
                let bar = CALayer()
                bar.backgroundColor = backgroundColor
                bar.cornerRadius = 1
                bar.cornerCurve = .continuous
                let barHeight = barHeights[i]
                let barX = Double(i) * 3.5
                let barY = (menubarHeight / 2) - 5

                bar.anchorPoint = .zero
                bar.frame = CGRect(x: barX, y: barY, width: 2, height: barHeight)
                
                if showAnimation {
                    addPlayingAnimation(layer: bar, duration: barDurations[i], beginTime: CACurrentMediaTime() - Double(i))
                }

                mainLayer.addSublayer(bar)
                bars.append(bar)
            }

            let textLayer = composeTextLayer()
            mainLayer.addSublayer(textLayer)

            self.layer?.addSublayer(mainLayer)
            return
        }
        
        if !isPlaying {
            let mainLayer = CALayer()
            
            let symbolLayer = createPauseSymbolLayer()
            let textLayer = composeTextLayer()

            mainLayer.addSublayer(symbolLayer)
            mainLayer.addSublayer(textLayer)

            self.layer?.addSublayer(mainLayer)
            return
        }
        
        self.layer?.addSublayer(createMusicBoxSymbolLayer())
    }
    
    func addPlayingAnimation(layer: CALayer, duration: TimeInterval, beginTime: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
        animation.fromValue = layer.bounds
        animation.toValue = CGRect(origin: .zero, size: CGSize(width: layer.bounds.width, height: 2))
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .greatestFiniteMagnitude
        animation.beginTime = beginTime
        layer.add(animation, forKey: nil)
    }
    
    func createMusicBoxSymbolLayer() -> CALayer {
        let mainLayer = CALayer()

        let symbolLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: -2, y: 1, width: 12, height: 16), cornerWidth: 2, cornerHeight: 2)
        symbolLayer.path = path
        symbolLayer.fillColor = NSColor.labelColor.cgColor
        
        symbolLayer.frame = CGRect(
            x: 2,
            y: 2,
            width: 20,
            height: 20)
        
        let backgroundLayer = CAShapeLayer()
        let bg = CGMutablePath()
        bg.addRoundedRect(in: CGRect(x: -2, y: 1, width: 12, height: 16), cornerWidth: 2, cornerHeight: 2)
        backgroundLayer.path = bg
        backgroundLayer.fillColor = NSColor.labelColor.withAlphaComponent(0.2).cgColor
        
        backgroundLayer.frame = CGRect(
            x: 2,
            y: 2,
            width: 20,
            height: 20)
        
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        maskPath.addRect(CGRect(x: -2, y: 1, width: 12, height: 16))
        maskPath.addRoundedRect(in: CGRect(x: 0, y: 2.5, width: 8, height: 8), cornerWidth: 4, cornerHeight: 4)
        maskPath.addRoundedRect(in: CGRect(x: 2, y: 11.5, width: 4, height: 4), cornerWidth: 2, cornerHeight: 2)
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        
        symbolLayer.mask = maskLayer
        
        mainLayer.addSublayer(backgroundLayer)
        mainLayer.addSublayer(symbolLayer)
        
        return mainLayer
    }

    func composeTextLayer() -> CALayer {
        let mainLayer = CALayer()
        
        if menuText.isEmpty { return mainLayer }
        
        let firstTextLayer = createTextLayer(x: 21, y: -2)
        let secondTextLayer = createTextLayer(x: 21 + statusBarWidthLimit, y: -2)
        
        let stringWidth = menuText.stringWidth(with: Constants.StatusBar.marqueeFont)
        
        if stringWidth > statusBarWidthLimit - 18 {
            if isPlaying {
                addPlayAnimation(layer: firstTextLayer, x: statusBarWidthLimit, y: statusBarWidthLimit, delay: false)
                addPlayAnimation(layer: secondTextLayer, x: 0, y: 0, delay: true)
            } else {
                addPauseAnimation(layer: firstTextLayer)
            }
        }
        
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 20, y: 0, width: statusBarWidthLimit - 18, height: menubarHeight)
        maskLayer.backgroundColor = NSColor.black.cgColor
        
        mainLayer.addSublayer(firstTextLayer)
        mainLayer.addSublayer(secondTextLayer)
        mainLayer.mask = maskLayer
        
        return mainLayer
    }
    
    func createTextLayer(x: Double, y: Double) -> CATextLayer {
        let text = CATextLayer()
        
        let stringWidth = menuText.stringWidth(with: Constants.StatusBar.marqueeFont)
        let backingScaleFactor = NSScreen.main?.backingScaleFactor ?? 1.0
        
        text.string = menuText
        text.foregroundColor = NSColor.labelColor.cgColor
        text.fontSize = 14
        text.alignmentMode = .left
        text.frame = CGRect(x: x, y: y, width: stringWidth, height: menubarHeight)
        
        text.contentsScale = backingScaleFactor
        text.rasterizationScale = backingScaleFactor
        text.font = Constants.StatusBar.marqueeFont
        text.shouldRasterize = true
        text.rasterizationScale = backingScaleFactor
        
        return text
    }
    
    func addPlayAnimation(layer: CALayer, x: Double, y: Double, delay: Bool) {
        let stringWidth = menuText.stringWidth(with: Constants.StatusBar.marqueeFont)
        let textPadding = Constants.StatusBar.statusBarTextPadding
        
        let startX = layer.position.x + x
        let endX = layer.position.x + y - 2*stringWidth - textPadding
        
        let speed = statusBarTextSpeed
        let distance = startX - endX
        let duration = distance / speed
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = NSValue(point: CGPoint(x: startX, y: layer.position.y))
        animation.toValue = NSValue(point: CGPoint(x: endX, y: layer.position.y))
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.beginTime = delay ? CACurrentMediaTime() + duration / 2 : 0
        
        layer.add(animation, forKey: "marqueeAnimation")
    }
    
    func addPauseAnimation(layer: CALayer) {
        let stringWidth = menuText.stringWidth(with: Constants.StatusBar.marqueeFont)
        let startX = layer.position.x + 5
        let endX = layer.position.x + statusBarWidthLimit - stringWidth - 21 - 5
        
        let speed = statusBarTextSpeed
        let distance = startX - endX
        let duration = distance / speed
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = NSValue(point: CGPoint(x: startX, y: layer.position.y))
        animation.toValue = NSValue(point: CGPoint(x: endX, y: layer.position.y))
        animation.duration = duration * 2
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        layer.add(animation, forKey: "marqueeAnimation")
    }

    func createPauseSymbolLayer() -> CAShapeLayer {
        let symbolLayer = CAShapeLayer()
        
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: 0, y: -1, width: 3, height: 12), cornerWidth: 1.5, cornerHeight: 1.5)
        path.addRoundedRect(in: CGRect(x: 5, y: -1, width: 3, height: 12), cornerWidth: 1.5, cornerHeight: 1.5)
        symbolLayer.path = path
        symbolLayer.fillColor = NSColor.labelColor.cgColor
        
        symbolLayer.frame = CGRect(
            x: 2,
            y: (menubarHeight / 2) - 5,
            width: Constants.StatusBar.statusBarSymbolWidth,
            height: menubarHeight)
        
        return symbolLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayer() {
        for bar in bars {
            bar.backgroundColor = backgroundColor
        }
    }
    
}
